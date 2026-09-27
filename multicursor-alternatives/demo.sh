#!/usr/bin/env bash
# Plays one demo segment in the demo session, one scene per key press.
#
#   ./demo.sh classic | placing | scripted | editing | golf
#
# The slides call this. It rebuilds the demo session, switches the presenter's
# client to it, and opens a floating caption card there. The card runs this
# script again with --play: it names the next edit, waits for Space, and then
# types its keys into the demo nvim one at a time. q quits, and the client
# returns to the slides when the card closes.
#
# Exercises load over RPC (nvim --server), which types nothing, so the
# keystroke golf ledger counts only the keys a scene plays.
#
# PACE scales every pause, so PACE=1.5 slows the typing and the beats down.
set -euo pipefail

session="multicursor-demo"
dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
pace="${PACE:-1}"
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

# Draws the card: step counter, the keys, one line of meaning, footer.
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

# ---- demo nvim ---------------------------------------------------------------

# Runs a Lua call from demo-init.lua in the demo nvim. Nothing is typed.
nv() {
	nvim --server "${sock}" --remote-expr "luaeval('$1')" >/dev/null ||
		fail "the demo nvim did not answer on ${sock}"
}

# Copies an exercise and opens it above its goal; the ledger shows in golf.
# "free" leaves the goal out, for a scene that ends somewhere else.
exercise() {
	local name="$1" goal="${dir}/exercises/$1.solution"
	[[ ${2:-} == free ]] && goal=""
	current="${work}/${name}.txt"
	cp "${dir}/exercises/${name}.before" "${current}"
	nv "Demo.load(\"${current}\", \"${goal}\", ${ledger})"
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
count_keys() {
	local stripped
	stripped="$(sed -E 's/<(Esc|CR|BS|Space|C-[A-Za-z])>/k/g' <<<"$1")"
	if ((${#stripped} == 1)); then
		printf '1 key'
	else
		printf '%s keys' "${#stripped}"
	fi
}

# Prints a check mark once the edit copy matches the goal.
goal_mark() {
	[[ "$(nvim --server "${sock}" --remote-expr "luaeval('Demo.solved()')")" == 1 ]] &&
		printf '    ✓ goal'
	return 0
}

# One scene: name the keys, wait for Space, type them, and show the count.
play_keys() {
	scene "$1" "$2" "$3"
	[[ ${ledger} == true ]] && nv 'Demo.golf_toggle()'
	type_keys "$2"
	pause 0.6
	[[ ${ledger} == true ]] && nv 'Demo.golf_toggle()'
	beat "$(count_keys "$2")$(goal_mark)"
	pause 1.5
}

# The methods Neovim had before multicursor, one exercise each.
classic() {
	exercise 01-add-prefix
	play_keys "1/6 · visual block" "<C-V>GI- <Esc>" "The same column on every line"
	exercise 02-log-levels
	play_keys "2/6 · :norm" ":%norm xf]D<CR>" "Normal-mode keys on each line"
	exercise 08-conditional-prefix
	play_keys "3/6 · :v" ":v/:/norm I[ok] <CR>" "Only lines without a colon"
	exercise 09-snake-to-camel
	play_keys "4/6 · :s" ':%s/_\(\w\)/\u\1/g<CR>' "Every match, uppercased"
	exercise 06-wrap-parens
	play_keys "5/6 · macro" "qqwi(<Esc>A)<Esc>q" "Record the edit on line one"
	# shellcheck disable=SC2016 # $ is vim's last line, typed as is.
	play_keys "6/6 · macro" ':2,$norm @q<CR>' "Replay it on the rest"
}

# Three ways to place cursors: a selection, by hand, and search matches.
placing() {
	exercise 05-add-semicolons
	play_keys "1/6 · {Visual}Q" "VGQ" "A cursor on each selected line"
	play_keys "2/6" "A;<Esc>" "Typing lands at every cursor"
	exercise 01-add-prefix free
	play_keys "3/6 · Q" "QjjQ" "A cursor where you stand"
	play_keys "4/6" "I- <Esc>" "Only the lines you picked"
	exercise 09-snake-to-camel
	play_keys "5/6 · [count]Q" "/_<CR>1Q" "A cursor on every match"
	play_keys "6/6" "x~" "Several cursors on one line"
}

# A command picks the spots, then the edit is typed live at all of them.
scripted() {
	exercise 08-conditional-prefix
	play_keys "1/4 · :v + Q" ":v/:/normal! Q<CR>" "Cursors on lines without a colon"
	play_keys "2/4" "I[ok] <Esc>" "Type the prefix once"
	exercise 02-log-levels free
	play_keys "3/4 · :g + Q" ':g/ERROR\|CRITICAL/normal! f]Q<CR>' "After the ] on the worst lines"
	play_keys "4/4" "a ALERT:<Esc>" "Only those lines change"
}

# What each cursor keeps for itself: motions, registers, a counter, undo.
editing() {
	exercise 04-first-field
	play_keys "1/6 · motions" "VGQf,D" "f, finds each line's own comma"
	play_keys "2/6 · undo" "u" "One undo for every cursor"
	exercise 07-flip-assignment
	play_keys "3/6 · registers" "VGQdt=" "Each cursor cuts to its own register"
	play_keys "4/6" "A=<Esc>p0x" "p pastes each line's own word"
	exercise 01-add-prefix free
	play_keys "5/6 · counter" "VGQg<C-A>" "g CTRL-A numbers the cursors"
	play_keys "6/6" "i. <Esc>" "A numbered list"
}

# Head to head on the ledger: a built-in tool, then multicursor.
golf_round() {
	local name="$1"
	nv 'Demo.golf_reset()'
	exercise "${name}"
	play_keys "${name} · $2" "$3" "$4"
	nv 'Demo.reset()'
	play_keys "${name} · multicursor" "$5" "$6"
}

golf() {
	golf_round 03-brackets-to-quotes ":s" ':%s/\v\[|\]/"/g<CR>' "Both brackets become quotes" \
		'VGQr"f]r"' "Replace, find, replace"
	golf_round 08-conditional-prefix ":v" ":v/:/norm I[ok] <CR>" "Lines without a colon" \
		'/^\w*$<CR>1QI[ok] <Esc>' "Cursors on one-word lines"
	golf_round 01-add-prefix "visual block" "<C-V>GI- <Esc>" "A column insert" \
		"VGQI- <Esc>" "A cursor per line"
}

# Runs inside the floating card: plays the scenes, then closes the card.
play() {
	local segment="$1"
	demo_pane="$2"
	step="" keys="" text="" current="" ledger=false
	trap 'printf "\e[?25h"' EXIT
	case "${segment}" in
	classic) classic ;;
	placing) placing ;;
	scripted) scripted ;;
	editing) editing ;;
	golf)
		ledger=true
		golf
		;;
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
	classic | placing | scripted | editing | golf) ;;
	*)
		printf 'usage: demo.sh classic|placing|scripted|editing|golf\n' >&2
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
	# The card sits top right, beside the exercise text, which stays under
	# 55 columns.
	width="$(tmux display-message -p -t "${demo_pane}" '#{window_width}')"
	card_width=$((width * 40 / 100))
	((card_width < 42)) && card_width=42
	card_pane="$(tmux new-pane -P -F '#{pane_id}' -t "${demo_pane}" \
		-x "${card_width}" -y 7 -X "$((width - card_width - 2))" -Y 1 -T ' demo ' \
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
	launch "${1:?usage: demo.sh classic|placing|scripted|editing|golf}"
fi
