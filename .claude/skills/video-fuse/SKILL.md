---
name: video-fuse
description: "Fuse several takes or screen recordings into one video with lossless, near-seamless joins chosen from the speech and what is on screen. Use when Piotr says fuse, join, stitch, splice, merge or concatenate videos or recordings, wants a hiccup cut out between takes, or gives marks such as 'the first one should end at 9 minutes'. Not for summarizing a video (youtube-summary)."
---

# Video fuse

A talk gets recorded in takes: a hiccup stops one recording and the next picks up at an earlier moment. Piotr gives rough marks. The job is to find the real cut near each mark, so the joins read as one take, and to join without re-encoding. A mark is a starting point: move it a few seconds when that lands on a better sentence, and say so.

## Scripts

Run these instead of ffmpeg by hand. The Bash tool's shell is zsh, which does not split words as bash does, so an inline loop over times breaks, and a hand-written concat hits the timescale bug `fuse.sh` guards against.

```bash
S=.claude/skills/video-fuse/scripts
$S/cuts.sh stills take.mp4 <scratchpad> 536 541 545 552   # contact sheet, prints its path
$S/cuts.sh gaps   take.mp4 535 550                        # pauses, by audio level
$S/cuts.sh says   take.mp4 538 543.5                      # words in that range
$S/fuse.sh --stills <scratchpad> ~/Videos/talk-fused.mp4 take1.mp4,,543.5 take2.mp4,,266.66 take3.mp4
```

Times are seconds. A clip is `file[,start[,end]]`. Write the output under a new name and leave the takes untouched.

## Method

1. Transcribe every take with `~/.claude/skills/youtube-summary/scripts/watch.sh <file>`. It prints `timeline: <dir>/timeline.md`, and `<dir>/said.jsonl` holds `{"t","end","text"}` per segment. Read the speech around each mark and the opening of the next take.
2. Look at the screen with `cuts.sh stills`, every few seconds around each mark and at the start of the next take. The transcript misses what matters here: a run can start seconds before the error it causes.
3. Choose the join. Two kinds work:
   - Same state: the frame before the cut shows what the next take opens on, such as the same slide with the same status. Viewers see nothing. Cut before the screen leaves that state.
   - Time passing: the speech announces a wait ("This should take just a moment") and the next take opens on the result.
4. End on a complete sentence, and read it with the next take's first words so the join does not double a phrase.
5. Pin the time. Whisper's segment times are approximate, so take candidates from `cuts.sh gaps` around the sentence end, then run `cuts.sh says` on a range ending at each one to read the last word it keeps. On the first use, 543.95 ended on "complicated, so" and 543.50 on "complicated."
6. Run `fuse.sh`. It refuses mismatched takes and an existing output (`--force` replaces one), then checks the frame count, the video and audio lengths, and that each join decodes.
7. Read the join stills. Transcribe the fused file with `watch.sh` and read the speech across each join. For sync, compare a late sentence's time with its time in the last take: the difference should equal the last join.

## Report

Lead with the output path and length, then a table of joins: time in the final video, last words before, first words after. Name each mark you moved and why. Say what was not checked: nobody here can hear the file or watch it in a player. Flag anything readable on screen that should not be published, such as a join token or an internal URL in a terminal take.

## Limits

- A start cut moves back to the keyframe at or before it, up to about 4 seconds in an OBS recording, and that brings back speech. Keep a take's start where possible: the second of silence OBS records there plays as a natural pause at the join.
- An end cut keeps a frame or two past its time, from B-frame order. Use the join times `fuse.sh` prints.
- Takes must share codec, size, rate and headers. When they do not, re-encoding is Piotr's decision, since it costs quality and time.
