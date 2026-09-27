#!/usr/bin/env bash
# Plays keystroke golf in the demo session. Each hole is one exercise: every
# method plays it from a fresh copy, the ledger counts the keys, and the card
# names the method with the fewest.
#
#   ./demo.sh        every hole
#   ./demo.sh 3      start at hole 3, for a retake
#
# The slides call this. It rebuilds the demo session, switches the presenter's
# client to it, and opens a floating caption card there. The card runs this
# script again with --play: it names the next method, waits for Space, and then
# types its keys into the demo nvim one at a time. q quits, and the client
# returns to the slides when the card closes.
#
# Exercises load over RPC (nvim --server), which types nothing, so the ledger
# counts only the keys a method plays.
#
# PACE scales every pause, so PACE=1.5 slows the typing and the beats down.
set -euo pipefail

session="multicursor-demo"
dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
pace="${PACE:-1}"
holes=5
# One demo nvim per tmux server, so two servers never drive each other's.
server="$(tmux display-message -p '#{pid}' 2>/dev/null || true)"
sock="${XDG_RUNTIME_DIR:-/tmp}/multicursor-demo-${server}.sock"
work="${XDG_RUNTIME_DIR:-/tmp}/multicursor-demo-${server}"

# Sleeps for a number of seconds scaled by PACE.
pause() {
	sleep "$(awk -v s="$1" -v p="${pace}" 'BEGIN { print s * p }')"
}

# Reports whether a pane still exists.
pane_alive() {
	tmux list-panes -a -F '#{pane_id}' | grep -qxF -- "$1"
}

# ---- caption card (runs inside the floating pane) ----------------------------

# Draws the card: hole and try, the method, its keys, one line of meaning,
# and the footer.
card() {
	printf '\e[?25l\e[2J\e[H'
	printf ' \e[90m%s\e[0m\n' "$1"
	printf ' \e[1;36m%s\e[0m\n' "$2"
	printf ' \e[1;33m%s\e[0m\n' "$3"
	printf ' \e[37m%s\e[0m\n\n' "$4"
	printf ' \e[36m%s\e[0m' "$5"
}

# Waits for a key. q ends the demo.
wait_key() {
	local key
	IFS= read -rsn1 key || true
	[[ ${key} == q ]] && exit 0
	return 0
}

# Shows the next method and waits for Space.
scene() {
	step="$1" method="$2" keys="$3" text="$4"
	card "${step}" "${method}" "${keys}" "${text}" "space ▸ play    q ▸ quit"
	wait_key
	card "${step}" "${method}" "${keys}" "${text}" "▶ playing"
}

# Updates the footer while a method plays.
beat() {
	card "${step}" "${method}" "${keys}" "${text}" "▶ $1"
}

# Shows a failure and waits, so the presenter can read it before leaving.
fail() {
	card "error" "$1" "" "Press any key to return to the slides" ""
	IFS= read -rsn1 _ || true
	exit 1
}

# ---- demo nvim ---------------------------------------------------------------

# Evaluates a Lua call from demo-init.lua in the demo nvim and prints the
# result. stdin stays off the card's terminal: on a terminal the client starts
# a UI of its own and draws over the card.
rpc() {
	nvim --server "${sock}" --remote-expr "luaeval('$1')" </dev/null 2>/dev/null
}

# Runs a Lua call in the demo nvim for its effect. Nothing is typed.
nv() {
	rpc "$1" >/dev/null || fail "the demo nvim did not answer on ${sock}"
}

# Copies an exercise and opens it above its goal, with the ledger below.
exercise() {
	local name="$1"
	current="${work}/${name}.txt"
	cp "${dir}/exercises/${name}.before" "${current}"
	nv "Demo.load(\"${current}\", \"${dir}/exercises/${name}.solution\")"
	pause 0.5
}

# Types keys in vim notation into the demo nvim, one key at a time, so viewers
# can read along. <Esc>, <CR>, <BS>, <Space> and <C-x> become tmux key names.
type_keys() {
	local all="$1" i=0 token char named='^<(Esc|CR|BS|Space|C-[A-Za-z])>'
	while ((i < ${#all})); do
		token=""
		[[ ${all:i} =~ ${named} ]] && token="${BASH_REMATCH[0]}"
		case "${token}" in
		"<Esc>") tmux send-keys -t "${demo_pane}" Escape ;;
		"<CR>") tmux send-keys -t "${demo_pane}" Enter ;;
		"<BS>") tmux send-keys -t "${demo_pane}" BSpace ;;
		"<Space>") tmux send-keys -t "${demo_pane}" Space ;;
		"<C-"*)
			char="${token:3:1}"
			tmux send-keys -t "${demo_pane}" "C-${char,,}"
			;;
		*)
			char="${all:i:1}"
			# tmux reads a bare ; as its command separator.
			[[ ${char} == ";" ]] && char='\;'
			tmux send-keys -t "${demo_pane}" -l -- "${char}"
			;;
		esac
		if [[ -n ${token} ]]; then
			i=$((i + ${#token}))
			pause 0.25
		else
			i=$((i + 1))
			pause 0.14
		fi
	done
}

# Counts keys the way the ledger does: a <...> name is one key.
key_count() {
	local stripped
	stripped="$(sed -E 's/<(Esc|CR|BS|Space|C-[A-Za-z])>/k/g' <<<"$1")"
	printf '%s' "${#stripped}"
}

# Plays one method while the ledger records, then shows its count and whether
# the copy reached the goal.
play_keys() {
	scene "$1" "$2" "$3" "$4"
	nv 'Demo.golf_toggle()'
	type_keys "${keys}"
	pause 0.6
	nv 'Demo.golf_toggle()'
	solved=false
	[[ "$(rpc 'Demo.solved()')" == 1 ]] && solved=true
	if ${solved}; then
		beat "$(key_count "${keys}") keys    ✓ goal"
	else
		beat "$(key_count "${keys}") keys    ✗ missed the goal"
	fi
	pause 1.5
}

# One hole: the exercise, then every method as name, keys, and meaning, each
# from a fresh copy. The fewest keys that reach the goal win.
hole() {
	local number="$1" name="$2" title="$3" total i=0 count best="" fewest=0
	shift 3
	((number < start)) && return 0
	total=$(($# / 3))
	nv 'Demo.golf_reset()'
	exercise "${name}"
	while (($# >= 3)); do
		i=$((i + 1))
		((i > 1)) && nv 'Demo.reset()'
		play_keys "hole ${number}/${holes} · ${title} · ${i}/${total}" "$1" "$2" "$3"
		count="$(key_count "$2")"
		if ${solved} && { [[ -z ${best} ]] || ((count < fewest)); }; then
			best="$1" fewest="${count}"
		fi
		shift 3
	done
	if [[ -n ${best} ]]; then
		card "hole ${number}/${holes} · ${title}" "🏆 ${best}" "${fewest} keys" \
			"The fewest keys to the goal" "space ▸ next    q ▸ quit"
	else
		card "hole ${number}/${holes} · ${title}" "no winner" "" \
			"No method reached the goal" "space ▸ next    q ▸ quit"
	fi
	wait_key
}

# The course. Each hole lists its methods as name, keys, and meaning; every
# key sequence is checked against the exercise's goal in solutions.md.
course() {
	hole 1 01-add-prefix "add prefix" \
		"visual block" "<C-V>GI- <Esc>" "Insert into a column" \
		":norm" ":%norm I- <CR>" "The same keys on every line" \
		"multicursor" "VGQI- <Esc>" "A cursor per line, then type"
	hole 2 06-wrap-parens "wrap parens" \
		":s" ':%s/ \zs.*/(&)<CR>' "Wrap what follows the space" \
		"macro" "qqwi(<Esc>A)<Esc>+q4@q" "Record line one, replay four" \
		"multicursor" "VGQwi(<Esc>A)<Esc>" "Type the edit once, live"
	hole 3 07-flip-assignment "flip assignment" \
		":s" ':%s/\v(.*)\=(.*)/\2=\1<CR>' "Swap two capture groups" \
		"macro" "qqdt=A=<Esc>p0xjq4@q" "Cut, append, paste, replay" \
		"multicursor" "VGQdt=A=<Esc>p0x" "Each cursor pastes its own cut"
	hole 4 09-snake-to-camel "snake to camel" \
		":s" ':%s/\v_(.)/\u\1/g<CR>' "Uppercase the letter after _" \
		"multicursor" "/_<CR>1Qx~" "A cursor on every _ match"
	hole 5 08-conditional-prefix "conditional prefix" \
		":v" ":v/:/s/^/[ok] <CR>" "Lines without a colon" \
		"search + Q" '/^\w*$<CR>1QI[ok] <Esc>' "A cursor on every one-word line" \
		":v + Q" ":v/:/norm! Q<CR>I[ok] <Esc>" "A command places, you type"
}

# Runs inside the floating card: plays the course, then closes the card.
play() {
	start="$1"
	demo_pane="$2"
	step="" method="" keys="" text="" current="" solved=false
	trap 'printf "\e[?25h"' EXIT
	course
	card "done" "Back to the slides" "" "" "any key ▸ close"
	IFS= read -rsn1 _ || true
}

# ---- launcher (runs from the slides) -----------------------------------------

# Hands the client back to the slides, even when the demo fails.
finish() {
	tmux switch-client -c "${client}" -t "=${home_session}" 2>/dev/null || true
}

launch() {
	local start="$1" demo_pane width card_width card_pane
	if ! [[ ${start} =~ ^[1-9]$ ]] || ((start > holes)); then
		printf 'usage: demo.sh [hole], a hole from 1 to %s\n' "${holes}" >&2
		exit 2
	fi
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
	# The card sits top right, beside the exercise text, which stays under
	# 55 columns.
	width="$(tmux display-message -p -t "${demo_pane}" '#{window_width}')"
	card_width=$((width * 40 / 100))
	((card_width < 42)) && card_width=42
	card_pane="$(tmux new-pane -P -F '#{pane_id}' -t "${demo_pane}" \
		-x "${card_width}" -y 8 -X "$((width - card_width - 2))" -Y 1 -T ' keystroke golf ' \
		"PACE='${pace}' '${dir}/demo.sh' --play '${start}' '${demo_pane}'")"
	tmux set-option -p -t "${card_pane}" remain-on-exit off

	while pane_alive "${card_pane}"; do
		sleep 0.3
	done
	printf 'Demo finished\n'
}

if [[ ${1:-} == --play ]]; then
	play "$2" "$3"
else
	launch "${1:-1}"
fi
