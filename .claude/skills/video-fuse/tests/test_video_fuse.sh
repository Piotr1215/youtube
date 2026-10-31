#!/usr/bin/env bash
# Pins the video-fuse scripts against small real videos built with ffmpeg: a cut clip
# joined to an untouched recording keeps every frame and stays in sync (the 1/60 against
# 1/15360 timescale bug), a start moves back to a keyframe, mismatched inputs and an
# overwrite are refused, and cuts.sh finds a pause and reads a transcript.
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FUSE="$root/scripts/fuse.sh"
CUTS="$root/scripts/cuts.sh"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

pass=0
fail=0

# $1: label, $2: expected, $3: actual
check() {
	if [[ "$2" == "$3" ]]; then
		pass=$((pass + 1))
	else
		fail=$((fail + 1))
		printf 'FAIL %s: expected [%s], got [%s]\n' "$1" "$2" "$3"
	fi
}

# $1: label, $2: needle, $3: haystack
contains() {
	if [[ "$3" == *"$2"* ]]; then
		pass=$((pass + 1))
	else
		fail=$((fail + 1))
		printf 'FAIL %s: [%s] not in [%s]\n' "$1" "$2" "$3"
	fi
}

# Build a recording shaped like OBS output: 1/60 timescale, B-frames, a keyframe a second.
# $1: output, $2: seconds, $3: size (optional)
recording() {
	ffmpeg -nostdin -v error -y -f lavfi -i "testsrc2=size=${3:-320x180}:rate=60:duration=$2" \
		-f lavfi -i "sine=frequency=440:sample_rate=48000:duration=$2" \
		-c:v libx264 -preset ultrafast -bf 2 -g 60 -keyint_min 60 -pix_fmt yuv420p \
		-c:a aac -video_track_timescale 60 "$1"
}

seconds() {
	ffprobe -v error -select_streams "$2" -show_entries stream=duration -of csv=p=0 "$1"
}

frames() {
	ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 "$1"
}

recording "$scratch/a.mp4" 6
recording "$scratch/b.mp4" 5
recording "$scratch/c.mp4" 8

report="$("$FUSE" --stills "$scratch/stills" "$scratch/out.mp4" "$scratch/a.mp4,,3.5" "$scratch/b.mp4,,2.5" "$scratch/c.mp4" 2>&1)"
check "fuse exit" 0 $?
# Each end cut also keeps the frames that display after it but decode before it: the
# two B-frames of reorder depth here, so 840 frames plus 2 for each of the 2 cuts.
check "frames all kept" 844 "$(frames "$scratch/out.mp4")"
check "video runs the whole length" 14.07 "$(printf '%.2f' "$(seconds "$scratch/out.mp4" v:0)")"
check "video and audio agree" 1 "$(awk -v v="$(seconds "$scratch/out.mp4" v:0)" -v a="$(seconds "$scratch/out.mp4" a:0)" 'BEGIN { d = v - a; print (d < 0.1 && d > -0.1) ? 1 : 0 }')"
check "frame rate survives" 60/1 "$(ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate -of csv=p=0 "$scratch/out.mp4")"
contains "first join reported" "join 1  0:03.5" "$report"
contains "second join reported" "join 2  0:06.0" "$report"
check "stills written" 4 "$(find "$scratch/stills" -name 'join*.png' | wc -l)"
check "no work directory left" 0 "$(find "$scratch" -maxdepth 1 -name '.fuse.*' | wc -l)"

report="$("$FUSE" "$scratch/start.mp4" "$scratch/a.mp4,2.5" "$scratch/b.mp4" 2>&1)"
check "start cut exit" 0 $?
contains "start moves back to the keyframe" "from 0:02.00" "$report"
check "start cut keeps from the keyframe" 540 "$(frames "$scratch/start.mp4")"
check "start cut stays in sync" 1 "$(awk -v v="$(seconds "$scratch/start.mp4" v:0)" -v a="$(seconds "$scratch/start.mp4" a:0)" 'BEGIN { d = v - a; print (d < 0.1 && d > -0.1) ? 1 : 0 }')"

"$FUSE" "$scratch/out.mp4" "$scratch/a.mp4" "$scratch/b.mp4" >/dev/null 2>&1
check "existing output refused" 1 $?
"$FUSE" --force "$scratch/out.mp4" "$scratch/a.mp4" "$scratch/b.mp4" >/dev/null 2>&1
check "force replaces it" 0 $?
"$FUSE" --force "$scratch/a.mp4" "$scratch/a.mp4" "$scratch/b.mp4" >/dev/null 2>&1
check "output as input refused" 1 $?
check "input kept after that refusal" 360 "$(frames "$scratch/a.mp4")"

recording "$scratch/big.mp4" 3 640x360
report="$("$FUSE" "$scratch/mixed.mp4" "$scratch/a.mp4" "$scratch/big.mp4" 2>&1)"
check "mismatched inputs refused" 1 $?
contains "refusal names the file" "big.mp4 does not match" "$report"
check "refusal writes no output" 0 "$(find "$scratch" -maxdepth 1 -name 'mixed.mp4' | wc -l)"

"$FUSE" "$scratch/x.mp4" "$scratch/a.mp4,,9:03" "$scratch/b.mp4" >/dev/null 2>&1
check "non-second time refused" 1 $?
"$FUSE" "$scratch/x.mp4" "$scratch/absent.mp4" "$scratch/b.mp4" >/dev/null 2>&1
check "missing input refused" 1 $?

# Tone, then 0.5 s of silence, then tone: the only pause sits at 2.0.
ffmpeg -nostdin -v error -y -f lavfi -i testsrc2=size=320x180:rate=60:duration=4.5 \
	-f lavfi -i "aevalsrc='if(between(t,2,2.5),0,0.3*sin(2*PI*440*t))':s=48000:d=4.5" \
	-c:v libx264 -preset ultrafast -pix_fmt yuv420p -c:a aac "$scratch/pause.mp4"
gaps="$("$CUTS" gaps "$scratch/pause.mp4" 1 4)"
check "one pause found" 1 "$(printf '%s\n' "$gaps" | grep -c ' to ')"
contains "pause starts near 2.0" "0:02.0" "$gaps"
contains "pause ends near 2.5" "to 0:02.5" "$gaps"

cat >"$scratch/watch" <<EOF
#!/usr/bin/env bash
mkdir -p "$scratch/cache"
printf '{"t":0,"end":1,"text":"first line"}\n{"t":1,"end":2,"text":"second line."}\n' >"$scratch/cache/said.jsonl"
echo "timeline: $scratch/cache/timeline.md"
EOF
chmod +x "$scratch/watch"
check "says joins the transcript" "first line second line." "$(VIDEO_FUSE_WATCH="$scratch/watch" "$CUTS" says "$scratch/pause.mp4" 0 2)"
check "says cleans the transcript cache" 0 "$(find "$scratch" -maxdepth 1 -name cache | wc -l)"

sheet="$("$CUTS" stills "$scratch/pause.mp4" "$scratch/sheet" 1 2.5)"
check "stills exit" 0 $?
check "sheet exists" 1 "$([[ -s "$sheet" ]] && echo 1 || echo 0)"

"$CUTS" nonsense >/dev/null 2>&1
check "unknown mode refused" 1 $?

printf 'video_fuse: %d passed, %d failed\n' "$pass" "$fail"
[[ $fail -eq 0 ]]
