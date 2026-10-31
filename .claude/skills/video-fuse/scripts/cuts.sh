#!/usr/bin/env bash
# Evidence for choosing where to cut a recording.
#
#   cuts.sh gaps   <file> <from> <to>            pauses in speech, from the audio level
#   cuts.sh says   <file> <from> <to>            the words spoken in that range
#   cuts.sh stills <file> <dir> <time>...        a contact sheet of those moments
#
# Times are seconds. gaps reads RMS level in 20 ms windows instead of silencedetect,
# which works on sample peaks: room noise after a word kept it from reporting the pause
# a cut needed. Some gaps are stops inside a word, so run says on a range ending at a
# candidate to read the last word it keeps.
set -euo pipefail

# Below this level, for at least this long, counts as a pause.
QUIET_DB=-28
MIN_GAP=0.12

WATCH="${VIDEO_FUSE_WATCH:-$HOME/.claude/skills/youtube-summary/scripts/watch.sh}"

die() {
	printf 'cuts: %s\n' "$*" >&2
	exit 1
}

gaps() {
	ffmpeg -nostdin -v error -ss "$2" -to "$3" -i "$1" -vn -af \
		"aresample=48000,asetnsamples=n=960:p=0,astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.RMS_level:file=-" \
		-f null - |
		awk -v from="$2" -v quiet="$QUIET_DB" -v min="$MIN_GAP" '
			function stamp(t) { return sprintf("%d:%05.2f", int(t / 60), t - 60 * int(t / 60)) }
			function close_gap() {
				if (end - start >= min)
					printf "%s to %s  %.2f s  %.0f dB  (%.2f)\n", stamp(start), stamp(end), end - start, low, start
				open = 0
			}
			/pts_time:/ { split($0, a, "pts_time:"); t = from + a[2]; next }
			/RMS_level=/ {
				split($0, a, "=")
				v = (a[2] ~ /inf/) ? -120 : a[2] + 0
				if (v < quiet) {
					if (!open) { open = 1; start = t; low = v }
					if (v < low) low = v
					end = t + 0.02
				} else if (open) close_gap()
			}
			END { if (open) close_gap() }'
}

says() {
	local work timeline
	work="$(mktemp -d)"
	trap 'rm -rf "$work"' RETURN
	ffmpeg -nostdin -v error -y -ss "$2" -to "$3" -i "$1" -vf scale=640:-2 \
		-c:v libx264 -preset ultrafast -pix_fmt yuv420p -c:a aac "$work/clip.mp4"
	timeline="$("$WATCH" "$work/clip.mp4" 2>/dev/null | sed -n 's/^timeline: //p')"
	[[ -n "$timeline" ]] || die "no transcript from $WATCH"
	jq -r .text "$(dirname "$timeline")/said.jsonl" | paste -sd ' ' -
	rm -rf "$(dirname "$timeline")"
}

stills() {
	local file="$1" dir="$2" name t
	shift 2
	mkdir -p "$dir"
	name="$(basename "${file%.*}")"
	local -a shots=()
	for t in "$@"; do
		ffmpeg -nostdin -v error -y -ss "$t" -i "$file" -frames:v 1 -vf scale=800:-1 "$dir/${name}_$t.png"
		shots+=("$dir/${name}_$t.png")
	done
	montage "${shots[@]}" -tile 2x -geometry +4+4 -background '#444' "$dir/$name-sheet-$1.png"
	printf '%s\n' "$dir/$name-sheet-$1.png"
}

mode="${1:-}"
shift || true
case "$mode" in
gaps | says)
	(($# == 3)) || die "usage: cuts.sh $mode <file> <from> <to>"
	[[ -f "$1" ]] || die "no such file: $1"
	"$mode" "$@"
	;;
stills)
	(($# >= 3)) || die "usage: cuts.sh stills <file> <dir> <time>..."
	[[ -f "$1" ]] || die "no such file: $1"
	stills "$@"
	;;
*) die "usage: cuts.sh gaps|says|stills ..." ;;
esac
