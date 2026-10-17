#!/usr/bin/env bash
# Plays one Neovim demo segment in the demo session, one scene per key press.
#
#   ./demo.sh tree | search | diagnostics | triage
#
# The slides call this. It rebuilds the demo session (your Neovim with
# demo-init.lua on top), switches the presenter's client to it, and opens a
# floating caption card there. The card runs this script again with --play: it
# names the next keys, waits for Space, and then types them into the demo nvim
# one at a time, so the presenter needs no bindings in their head. q quits, and
# the client returns to the slides when the card closes.
#
# PACE scales every pause, so PACE=1.5 slows the typing and the beats down.
set -euo pipefail

session="ast-grep-demo"
dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
pace="${PACE:-1}"
segments="tree|search|diagnostics|triage"
# Each launch gets its own demo nvim socket; the card receives it as --play's
# third argument. setup-demo.sh says why the path is never reused.
sock="${XDG_RUNTIME_DIR:-/tmp}/ast-grep-demo-$$.sock"

# Sleeps for a number of seconds scaled by PACE.
pause() {
	sleep "$(awk -v s="$1" -v p="${pace}" 'BEGIN { print s * p }')"
}

# Reports whether a pane still exists.
pane_alive() {
	tmux list-panes -a -F '#{pane_id}' | grep -qxF -- "$1"
}

# ---- caption card (runs inside the floating pane) ----------------------------

# Draws the card: step counter, the keys, one line of meaning, and the footer.
card() {
	printf '\e[?25l\e[2J\e[H'
	printf ' \e[90m%s\e[0m\n' "$1"
	printf ' \e[1;33m%s\e[0m\n' "$2"
	printf ' \e[37m%s\e[0m\n\n' "$3"
	printf ' \e[36m%s\e[0m' "$4"
}

# Waits for a key. q ends the demo.
wait_key() {
	local key
	IFS= read -rsn1 key || true
	[[ ${key} == q ]] && exit 0
	return 0
}

# Shows the next keys and waits for Space.
scene() {
	step="$1" keys="$2" text="$3"
	card "${step}" "${keys}" "${text}" "space ▸ play    q ▸ quit"
	wait_key
	card "${step}" "${keys}" "${text}" "▶ playing"
}

# Updates the footer while a scene plays.
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

# Evaluates a Lua expression in the demo nvim and prints the result. stdin
# stays off the card's terminal: on a terminal the client starts a UI of its
# own and draws over the card. Neovim answers only once it is idle, so a call
# made while a shell command runs waits for that command.
rpc() {
	nvim --server "${sock}" --remote-expr "luaeval('$1')" </dev/null 2>/dev/null
}

# Waits for the ast-grep language server to publish its findings, so the
# first scene never plays over a bare sign column.
wait_findings() {
	local i count
	for ((i = 0; i < 100; i++)); do
		count="$(rpc 'Demo.findings()' || true)"
		[[ ${count} =~ ^[1-9] ]] && return 0
		sleep 0.1
	done
	fail "ast-grep reported no findings on ${sock}"
}

# Types keys in vim notation into the demo nvim, one key at a time, so viewers
# can read along. <Esc>, <CR> and <Space> become tmux key names, and
# <Hold> waits long enough for which-key to show what the prefix offers. The
# optional second argument sets the pause between plain characters.
type_keys() {
	local all="$1" gap="${2:-0.14}" i=0 token char named='^<(Esc|CR|Space|Hold)>'
	while ((i < ${#all})); do
		token=""
		[[ ${all:i} =~ ${named} ]] && token="${BASH_REMATCH[0]}"
		case "${token}" in
		"<Esc>") tmux send-keys -t "${demo_pane}" Escape ;;
		"<CR>") tmux send-keys -t "${demo_pane}" Enter ;;
		"<Space>") tmux send-keys -t "${demo_pane}" Space ;;
		"<Hold>") pause 1.6 ;;
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
			pause "${gap}"
		fi
	done
}

# ---- segments ----------------------------------------------------------------

# :InspectTree shows the tree Neovim parsed, and walking it lights up the code.
# v an then climbs the same tree from the cursor, one parent node per an.
tree() {
	scene "1/4" "]d" "The bare return from the last slides"
	type_keys "]d"
	pause 1.5
	scene "2/4" ":InspectTree" "The syntax tree of this buffer"
	type_keys ":InspectTree<CR>"
	pause 2
	scene "3/4" "j  j  j  j" "Walk the nodes; each one lights up its code"
	for _ in 1 2 3 4; do
		type_keys "j"
		pause 1.2
	done
	pause 1.5
	scene "4/4" "q  v  an  an  an  an" "Each an selects the parent: if, body, function"
	type_keys "q"
	pause 0.8
	type_keys "v"
	pause 0.6
	for _ in 1 2 3 4; do
		type_keys "an"
		pause 1.4
	done
	type_keys "<Esc>"
	pause 1
}

# grug-far runs ast-grep as you type, in a buffer you can edit. The patterns
# are typed as written, so their $ metavariables stay in single quotes.
# shellcheck disable=SC2016
search() {
	scene "1/3" "Space s g" "Open grug-far with the ast-grep engine"
	type_keys "<Space>s<Hold>g"
	pause 1.5
	scene "2/3" 'fmt.Errorf($MSG, $$$ARGS)' "Every match updates as the pattern grows"
	type_keys 'fmt.Errorf($MSG, $$$ARGS)' 0.09
	pause 3
	scene "3/3" 'if $ERR != nil { return nil, $ERR }' "One pattern, three lines per match"
	type_keys "<Esc>"
	pause 0.3
	type_keys "cc"
	pause 0.3
	type_keys 'if $ERR != nil { return nil, $ERR }' 0.07
	pause 4
}

# Rules show inline, and a rule's fix is a code action.
diagnostics() {
	scene "1/3" "]d" "Next finding, its message under the cursor"
	type_keys "]d"
	pause 2
	scene "2/3" "]d" "A %v where the rule wants %w"
	type_keys "]d"
	pause 2
	scene "3/3" "g r  a  Enter" "gr lists the LSP keys; gra lists each rule's fix"
	type_keys "gr<Hold>a"
	pause 1.5
	beat "Enter ▸ apply the first, the %w fix"
	pause 1
	type_keys "<CR>"
	pause 1.5
	beat "%v became %w, and the warning is gone"
	pause 2.5
}

# Types :Classif and waits until the run it starts has turned its verdicts
# into diagnostics. Demo.classified counts finished runs, so the count read
# before typing tells this run from the last one.
classify() {
	local i before
	before="$(rpc 'Demo.classified' || true)"
	type_keys ":Classif<CR>"
	beat "asking the local model"
	for ((i = 0; i < 300; i++)); do
		(("$(rpc 'Demo.classified' || echo 0)" > before)) && return 0
		sleep 0.2
	done
	fail "classif gave no verdict within a minute"
}

# vague-error-message marks every fmt.Errorf as a hint. :Classif opens a panel
# with the rule's question and each call it matched, and fills in classif's
# verdict on each: a vague message becomes a warning, a clear one gets a ✓.
# gra applies the rule's fix, built from the syntax tree, and a second
# :Classif asks the question again about the fixed text.
triage() {
	scene "1/4" ":Classif" "Ask the rule's question about every call it matched"
	classify
	beat "the panel: the question, each call, its verdict"
	pause 5
	scene "2/4" "53G  ]d" "The vague message is a warning now; ]d lands on it"
	type_keys "53G"
	pause 1
	type_keys "]d"
	pause 3
	scene "3/4" "g r  a  Enter" "The rule's fix puts the function name in the message"
	type_keys "gr<Hold>a"
	pause 1.5
	beat "Enter ▸ apply the fix"
	pause 1
	type_keys "<CR>"
	pause 2
	scene "4/4" ":Classif" "Ask again: does the fixed message name the operation?"
	classify
	beat "both cleared: the fix answered the question"
	pause 5
}

# Runs inside the floating card: plays the scenes, then closes the card.
play() {
	segment="$1"
	demo_pane="$2"
	sock="$3"
	step="" keys="" text=""
	trap 'printf "\e[?25h"' EXIT
	card "${segment}" "waiting for ast-grep" "" ""
	wait_findings
	case "${segment}" in
	tree) tree ;;
	search) search ;;
	diagnostics) diagnostics ;;
	triage) triage ;;
	*) fail "unknown segment: ${segment}" ;;
	esac
	card "done" "Back to the slides" "" "any key ▸ close"
	IFS= read -rsn1 _ || true
}

# ---- launcher (runs from the slides) -----------------------------------------

# Hands the client back to the slides, even when the demo fails, and closes
# the demo session so no nvim outlives its segment.
finish() {
	tmux switch-client -c "${client}" -t "=${home_session}" 2>/dev/null || true
	tmux kill-session -t "=${session}" 2>/dev/null || true
}

launch() {
	local segment="$1" demo_pane width height card_width card_height=7 card_pane
	if ! [[ ${segment} =~ ^(${segments})$ ]]; then
		printf 'usage: demo.sh %s\n' "${segments}" >&2
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

	"${dir}/setup-demo.sh" "${sock}" >/dev/null
	demo_pane="$(tmux display-message -p -t "=${session}:" '#{pane_id}')"
	trap finish EXIT
	tmux switch-client -c "${client}" -t "=${session}"
	pause 0.5

	# The window takes the client's size on switch, so measure it after.
	# The card sits bottom right, above the statusline: code and the grug-far
	# inputs live at the top, and long lines rarely reach that corner.
	width="$(tmux display-message -p -t "${demo_pane}" '#{window_width}')"
	height="$(tmux display-message -p -t "${demo_pane}" '#{window_height}')"
	card_width=$((width * 35 / 100))
	((card_width < 48)) && card_width=48
	card_pane="$(tmux new-pane -P -F '#{pane_id}' -t "${demo_pane}" \
		-x "${card_width}" -y "${card_height}" \
		-X "$((width - card_width - 2))" -Y "$((height - card_height - 4))" \
		"PACE='${pace}' '${dir}/demo.sh' --play '${segment}' '${demo_pane}' '${sock}'")"
	# new-pane takes no -T since tmux 3.7, so the title is set afterwards.
	tmux select-pane -t "${card_pane}" -T ' demo '
	tmux set-option -p -t "${card_pane}" remain-on-exit off

	while pane_alive "${card_pane}"; do
		sleep 0.3
	done
	printf 'Demo finished\n'
}

if [[ ${1:-} == --play ]]; then
	play "$2" "$3" "$4"
else
	launch "${1:?usage: demo.sh ${segments}}"
fi
