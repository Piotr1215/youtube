#!/usr/bin/env bash
# Plays one demo segment in the demo session, one scene per key press.
#
#   ./demo.sh teaser | copy-mode | atoms
#
# The slides call this. It rebuilds the demo session, switches the presenter's
# client to it, and opens a floating caption card there. The card runs this
# script again with --play: it names the next step, waits for Space, and then
# plays that step. q quits, and the client returns to the slides when the card
# closes.
#
# The plugin opens its picker with display-popup, and a popup has no pane id.
# Keys sent with `send-keys -K` arrive flagged as sent, and a popup drops them,
# so a replay cannot type into it. The demo runs the plugin's own prompt,
# `pane_regex.py --prompt`, in a floating pane shaped like the popup instead.
# Matching, highlighting, and the paste are the plugin's; only the frame differs.
#
# PACE scales every pause, so PACE=1.5 slows the typing and the beats down.
set -euo pipefail

session="pane-regex-demo"
dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
pace="${PACE:-1}"

# Sleeps for a number of seconds scaled by PACE.
pause() {
	sleep "$(awk -v s="$1" -v p="${pace}" 'BEGIN { print s * p }')"
}

# Reports whether a pane still exists.
pane_alive() {
	tmux list-panes -a -F '#{pane_id}' | grep -qxF -- "$1"
}

# ---- caption card (runs inside the floating pane) ----------------------------

# Draws the card: step counter, the keys or query, one line of meaning, footer.
card() {
	printf '\e[?25l\e[2J\e[H'
	printf ' \e[90m%s\e[0m\n' "$1"
	printf ' \e[1;33m%s\e[0m\n' "$2"
	printf ' \e[37m%s\e[0m\n\n' "$3"
	printf ' \e[36m%s\e[0m' "$4"
}

# Shows the next step and waits for Space. q ends the demo.
scene() {
	local key
	step="$1" keys="$2" text="$3"
	card "${step}" "${keys}" "${text}" "space ▸ play    q ▸ quit"
	IFS= read -rsn1 key || true
	[[ ${key} == q ]] && exit 0
	card "${step}" "${keys}" "${text}" "▶ playing"
}

# Updates the footer while a step plays.
beat() {
	card "${step}" "${keys}" "${text}" "▶ $1"
}

# Shows a failure and waits, so the presenter can read it before leaving.
fail() {
	card "error" "$1" "Press any key to return to the slides" ""
	IFS= read -rsn1 _ || true
	exit 1
}

# Opens the plugin's prompt in a floating pane where its popup would sit:
# centered, 90% wide, 7 rows at the top. The state directory mirrors the one
# the plugin creates for the popup, since the prompt refuses any other.
picker_open() {
	local script width
	script="$(tmux show-option -gqv @pane-regex-script)"
	[[ -n ${script} ]] || fail "@pane-regex-script is unset: load the plugin first"
	state="$(mktemp -d "${TMPDIR:-/tmp}/pane-regex-expand-XXXXXXXX")"
	printf '^' >"${state}/query"
	width="$(tmux display-message -p -t "${demo_pane}" '#{window_width}')"
	picker="$(tmux new-pane -P -F '#{pane_id}' -t "${demo_pane}" \
		-x "$((width * 90 / 100))" -y 7 -X "$((width * 5 / 100))" -Y 0 -T ' pane regex ' \
		"'${script}' --prompt '${demo_pane}' '${state}' 0")" || fail "the picker did not open"
	tmux set-option -p -t "${picker}" remain-on-exit off
	pause 1
}

# Types into the picker one character at a time, so viewers can read along.
picker_type() {
	local text="$1" i
	for ((i = 0; i < ${#text}; i++)); do
		tmux send-keys -t "${picker}" -l "${text:i:1}"
		pause 0.09
	done
}

# Sends named keys such as Up, Enter, or C-y to the picker.
picker_key() {
	tmux send-keys -t "${picker}" "$@"
}

# Waits for the picker to close, cleans up after it as the plugin's popup
# wrapper does, and gives the keyboard back to the card.
picker_closed() {
	local i
	for ((i = 0; i < 50; i++)); do
		pane_alive "${picker}" || break
		sleep 0.1
	done
	tmux send-keys -X -t "${demo_pane}" cancel 2>/dev/null || true
	rm -rf "${state}"
	tmux select-pane -t "${TMUX_PANE}"
}

# Clears whatever a step left on the demo prompt.
clear_prompt() {
	tmux send-keys -t "${demo_pane}" C-c
	pause 0.5
}

# Accepts the match, lets the paste sit on the prompt, then clears it.
paste_and_clear() {
	beat "Enter ▸ paste"
	picker_key Enter
	picker_closed
	pause 3
	clear_prompt
}

# One scene: name the query, open the picker, type it, and paste the match.
query_scene() {
	scene "$1" "$2" "$3"
	picker_open
	picker_type "${2#^}"
	pause 2.5
	paste_and_clear
}

teaser() {
	query_scene "1/2" '^helm up$$' "A wrapped command, back as one line"
	query_scene "2/2" '^ERROR.*5432' "From ERROR to the port, mid-line"
}

# The built-in way, for contrast: every step steers the copy mode cursor.
copy_mode() {
	scene "1/6" "prefix [" "The pane becomes a view of its history"
	tmux copy-mode -t "${demo_pane}"
	scene "2/6" "?ERROR  Enter" "Search back for a word in the text you want"
	tmux send-keys -X -t "${demo_pane}" search-backward "ERROR"
	scene "3/6" "Space" "Start the selection"
	tmux send-keys -X -t "${demo_pane}" begin-selection
	scene "4/6" "E E E E E E  h" "Steer to the end, one word at a time"
	for _ in 1 2 3 4 5 6; do
		tmux send-keys -X -t "${demo_pane}" next-space-end
		pause 0.5
	done
	tmux send-keys -X -t "${demo_pane}" cursor-left
	scene "5/6" "Enter" "Copy and leave copy mode"
	tmux send-keys -X -t "${demo_pane}" copy-selection-and-cancel
	scene "6/6" "prefix ]" "Paste at the prompt"
	tmux paste-buffer -p -t "${demo_pane}"
	pause 1
}

# The vim atoms, each on the scrollback it was made for.
atoms() {
	query_scene "1/6" '^limits.*256Mi' "A range across lines keeps its indentation"

	scene "2/6" '^connection refused$' "Up and Down walk older and newer matches"
	picker_open
	picker_type 'connection refused$'
	pause 2
	beat "Up ▸ older"
	picker_key Up
	pause 1.5
	picker_key Up
	pause 1.5
	beat "Down ▸ newer"
	picker_key Down
	pause 1.5
	paste_and_clear

	scene "3/6" '^helm up.*--set\3t' "Stop before the third --set, like vim's 3t"
	picker_open
	picker_type 'helm up.*--set\3t'
	pause 2.5
	beat "\\2t ▸ one --set earlier"
	picker_key BSpace BSpace
	pause 0.8
	picker_type '2t'
	pause 2.5
	paste_and_clear

	query_scene "4/6" '^\S+\ze +0/1' "\\ze ends the paste early: the pod name"
	query_scene "5/6" '^tag=\zs[0-9.]+' "\\zs starts it late: the version"

	scene "6/6" '^\u' "The newest URL, Up for an older one, Ctrl-Y copies"
	picker_open
	picker_type '\u'
	pause 2
	beat "Up ▸ older URL"
	picker_key Up
	pause 2
	beat "Ctrl-Y ▸ clipboard"
	picker_key C-y
	picker_closed
	pause 1
	tmux send-keys -t "${demo_pane}" -l 'xclip -o -selection clipboard'
	pause 1
	tmux send-keys -t "${demo_pane}" Enter
	pause 1
}

# Runs inside the floating card: plays the scenes, then closes the card.
play() {
	segment="$1"
	demo_pane="$2"
	picker="" state=""
	step="" keys="" text=""
	trap 'printf "\e[?25h"; [[ -n ${state} ]] && rm -rf "${state}"' EXIT
	case "${segment}" in
	teaser) teaser ;;
	copy-mode) copy_mode ;;
	atoms) atoms ;;
	*) fail "unknown segment: ${segment}" ;;
	esac
	card "done" "Back to the slides" "" "any key ▸ close"
	IFS= read -rsn1 _ || true
}

# ---- launcher (runs from the slides) -----------------------------------------

# Hands the client back to the slides, even when the demo fails.
finish() {
	tmux switch-client -c "${client}" -t "=${home_session}" 2>/dev/null || true
}

launch() {
	local segment="$1" demo_pane width card_width card_pane
	case "${segment}" in
	teaser | copy-mode | atoms) ;;
	*)
		printf 'usage: demo.sh teaser|copy-mode|atoms\n' >&2
		exit 2
		;;
	esac
	if [[ -z ${TMUX:-} ]]; then
		printf 'Run the slides inside tmux: the demo switches the tmux client that shows them\n' >&2
		exit 1
	fi

	home_session="$(tmux display-message -p '#{session_name}')"
	client="$(tmux display-message -p '#{client_name}')"
	if [[ -z ${client} ]]; then
		printf 'No client is attached to %s\n' "${home_session}" >&2
		exit 1
	fi

	"${dir}/setup-demo.sh" >/dev/null
	demo_pane="$(tmux display-message -p -t "=${session}:" '#{pane_id}')"
	trap finish EXIT
	tmux switch-client -c "${client}" -t "=${session}"
	pause 0.5

	# The window takes the client's size on switch, so measure it after.
	width="$(tmux display-message -p -t "${demo_pane}" '#{window_width}')"
	card_width=$((width * 45 / 100))
	((card_width < 56)) && card_width=56
	# Below the picker, which sits in the top seven rows, and flush right.
	card_pane="$(tmux new-pane -P -F '#{pane_id}' -t "${demo_pane}" \
		-x "${card_width}" -y 7 -X "$((width - card_width - 2))" -Y 9 -T ' demo ' \
		"PACE='${pace}' '${dir}/demo.sh' --play '${segment}' '${demo_pane}'")"
	tmux set-option -p -t "${card_pane}" remain-on-exit off

	while pane_alive "${card_pane}"; do
		sleep 0.3
	done
	printf 'Demo finished\n'
}

if [[ ${1:-} == --play ]]; then
	play "$2" "$3"
else
	launch "${1:?usage: demo.sh teaser|copy-mode|atoms}"
fi
