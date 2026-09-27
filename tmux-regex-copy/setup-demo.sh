#!/usr/bin/env bash
# Opens a fresh tmux session whose scrollback holds the output the demo
# queries select. Recreated on every run so each take starts from the same text.
set -euo pipefail

session="pane-regex-demo"
dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

tmux kill-session -t "=${session}" 2>/dev/null || true
tmux new-session -d -s "${session}" -c "${dir}"
tmux send-keys -t "=${session}:" "clear && command cat demo-scrollback.txt" C-m

printf 'Session %s ready: tmux switchc -t %s\n' "${session}" "${session}"
