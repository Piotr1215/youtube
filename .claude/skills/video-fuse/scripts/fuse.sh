#!/usr/bin/env bash
# Join clips from one recording setup into a single video without re-encoding.
#
#   fuse.sh [--force] [--stills DIR] <output.mp4> <file[,start[,end]]>...
#
# Times are seconds in that file; leave a field empty to keep the file's own edge:
# a.mp4,,543.5 keeps a.mp4 up to 543.5, b.mp4,12 keeps it from 12 on. An end can fall
# anywhere. A start needs a keyframe to decode from, so it moves back to the one at or
# before it, and the report says where the clip really starts.
#
# Every clip and the output keep the source's own video timescale. ffmpeg's default for a
# stream copy is 1/15360, and concat of that with an untouched 1/60 recording crushes the
# recording's frames into a few seconds while its audio plays on (ffmpeg 6.1.1). The
# check after the join catches that.
set -euo pipefail

die() {
	printf 'fuse: %s\n' "$*" >&2
	exit 1
}

# Print a stream's property; $1: file, $2: stream selector, $3: entry.
stream() {
	ffprobe -v error -select_streams "$2" -show_entries "stream=$3" -of default=nw=1:nk=1 "$1" | head -n 1
}

# Print everything the joined file must share, since it keeps the first clip's headers.
fingerprint() {
	ffprobe -v error -show_data_hash sha256 -of compact=p=0 -show_entries \
		stream=codec_type,codec_name,profile,width,height,pix_fmt,r_frame_rate,time_base,sample_rate,channels,extradata_hash "$1"
}

# Print the last keyframe time at or before $2 in file $1.
keyframe_at() {
	ffprobe -v error -select_streams v:0 -show_entries packet=pts_time,flags -of csv=p=0 "$1" |
		awk -F, -v t="$2" '$2 ~ /K/ && $1 + 0 <= t + 0 { k = $1 } END { printf "%.6f", k + 0 }'
}

# Print seconds as m:ss.ss.
stamp() {
	awk -v t="$1" 'BEGIN { m = int(t / 60); printf "%d:%05.2f", m, t - 60 * m }'
}

force=0
stills=""
while (($#)); do
	case "$1" in
	--force) force=1 ;;
	--stills)
		stills="${2:?--stills needs a directory}"
		shift
		;;
	-*) die "unknown option $1" ;;
	*) break ;;
	esac
	shift
done
(($# >= 3)) || die "usage: fuse.sh [--force] [--stills DIR] <output.mp4> <file[,start[,end]]>..."
for tool in ffmpeg ffprobe awk; do
	command -v "$tool" >/dev/null || die "$tool is not installed"
done

out="$1"
shift
out_real="$(realpath -m "$out")"
[[ -e "$out" && "$force" -eq 0 ]] && die "$out exists; pass --force to replace it"

declare -a files=() starts=() ends=()
for spec in "$@"; do
	IFS=, read -r file start end <<<"$spec"
	[[ -f "$file" ]] || die "no such file: $file"
	[[ "$(realpath "$file")" == "$out_real" ]] && die "the output is also an input: $file"
	for t in "${start:-0}" "${end:-0}"; do
		[[ "$t" =~ ^[0-9]+(\.[0-9]+)?$ ]] || die "times are seconds, got '$t' in $spec"
	done
	files+=("$file")
	starts+=("${start:-0}")
	ends+=("${end:-}")
done

first="$(fingerprint "${files[0]}")"
for file in "${files[@]}"; do
	[[ "$(fingerprint "$file")" == "$first" ]] || die "$file does not match ${files[0]} (codec, size, rate or headers); a lossless join needs identical settings"
done

scale="$(stream "${files[0]}" v:0 time_base | cut -d/ -f2)"
[[ "$scale" =~ ^[0-9]+$ ]] || die "no video stream in ${files[0]}"

work="$(mktemp -d "$(dirname "$out_real")/.fuse.XXXXXX")"
trap 'rm -rf "$work"' EXIT

joined=0
expected_frames=0
joins=()
: >"$work/list.txt"
for i in "${!files[@]}"; do
	file="${files[i]}"
	seg="seg$i.mp4"
	key=0
	args=()
	if [[ "${starts[i]}" != 0 ]]; then
		key="$(keyframe_at "$file" "${starts[i]}")"
		args+=(-ss "$key")
	fi
	args+=(-i "$file")
	[[ -n "${ends[i]}" ]] && args+=(-t "$(awk -v e="${ends[i]}" -v k="$key" 'BEGIN { printf "%.6f", e - k }')")
	ffmpeg -nostdin -v error -y "${args[@]}" -map 0 -c copy -video_track_timescale "$scale" "$work/$seg"
	printf "file '%s'\n" "$seg" >>"$work/list.txt"

	length="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$work/$seg")"
	frames="$(ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 "$work/$seg")"
	expected_frames=$((expected_frames + frames))
	printf 'clip %d  %s  from %s for %s\n' "$((i + 1))" "$(basename "$file")" "$(stamp "$key")" "$(stamp "$length")"
	joined="$(awk -v a="$joined" -v b="$length" 'BEGIN { printf "%.6f", a + b }')"
	joins+=("$joined")
done
unset 'joins[-1]'

# Written inside the work directory first, so a failed run leaves no output behind.
ffmpeg -nostdin -v error -y -f concat -i "$work/list.txt" -map 0 -c copy -video_track_timescale "$scale" -movflags +faststart "$work/out.mp4"

video="$(stream "$work/out.mp4" v:0 duration)"
audio="$(stream "$work/out.mp4" a:0 duration)"
frames="$(ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 "$work/out.mp4")"
[[ "$frames" == "$expected_frames" ]] || die "expected $expected_frames frames, got $frames"
if [[ -n "$audio" ]]; then
	awk -v v="$video" -v a="$audio" 'BEGIN { d = v - a; exit !(d < 0.25 && d > -0.25) }' ||
		die "video runs $(stamp "$video") but audio runs $(stamp "$audio"); timestamps broke in the join"
fi

for i in "${!joins[@]}"; do
	join="${joins[i]}"
	# A join can repeat one frame's timestamp, which the null muxer reports and players ignore.
	errors="$(ffmpeg -nostdin -v error -ss "$(awk -v j="$join" 'BEGIN { s = j - 6; printf "%.3f", s < 0 ? 0 : s }')" -t 12 -i "$work/out.mp4" -f null - 2>&1 | grep -v 'non monotonically' || true)"
	[[ -z "$errors" ]] || die "join $((i + 1)) does not decode: $errors"
	printf 'join %d  %s\n' "$((i + 1))" "$(stamp "$join")"
done

mv -f "$work/out.mp4" "$out_real"
printf 'output  %s  %s, %s frames\n' "$out" "$(stamp "$video")" "$frames"

if [[ -n "$stills" ]]; then
	mkdir -p "$stills"
	for i in "${!joins[@]}"; do
		for side in before after; do
			offset=-0.25
			[[ "$side" == after ]] && offset=0.25
			at="$(awk -v j="${joins[i]}" -v o="$offset" 'BEGIN { printf "%.3f", j + o }')"
			ffmpeg -nostdin -v error -y -ss "$at" -i "$out_real" -frames:v 1 -vf scale=900:-1 "$stills/join$((i + 1))-$side.png"
		done
	done
	printf 'stills  %s\n' "$stills"
fi
