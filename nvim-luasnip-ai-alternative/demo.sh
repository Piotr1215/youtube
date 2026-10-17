#!/usr/bin/env bash
# Opens one Neovim demo with a list of steps beside it.
#
#   ./demo.sh tree | search | diagnostics | triage
#
# The slides call this. It rebuilds the demo session (your Neovim with
# demo-init.lua on top), switches the presenter's client to it, and opens a
# floating card listing the segment's steps. The card never takes focus: the
# presenter types every key into nvim, at their own pace, and may do anything
# else in the file. Quitting nvim (:qa!) returns the client to the slides.
set -euo pipefail

session="ast-grep-demo"
dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
segments="tree|search|diagnostics|triage"
# Each launch gets its own demo nvim socket; the card receives it as --card's
# second argument. setup-demo.sh says why the path is never reused.
sock="${XDG_RUNTIME_DIR:-/tmp}/ast-grep-demo-$$.sock"

# Prints a segment's steps, one "keys|what it shows" per line. The patterns
# are typed as written, so their $ metavariables stay in single quotes.
# shellcheck disable=SC2016
steps() {
	case "$1" in
	tree)
		printf '%s\n' \
			']d|jump to the bare return from First Look' \
			':InspectTree|open the syntax tree of this buffer' \
			'j j j j|walk the nodes; the code under each lights up' \
			'q|close the tree' \
			'v an an an an|select the node, then each parent'
		;;
	search)
		printf '%s\n' \
			'Space s g|open grug-far with the ast-grep engine' \
			'fmt.Errorf($MSG, $$$ARGS)|type it; the matches update as it grows' \
			'Esc cc|clear the pattern line' \
			'if $ERR != nil { return nil, $ERR }|one pattern, three lines per match'
		;;
	diagnostics)
		printf '%s\n' \
			']d|next finding, its message under the cursor' \
			']d|a %v where the rule wants %w' \
			'gra|the code actions: each matching rule'"'"'s fix' \
			'Enter|apply the first, the %w fix'
		;;
	triage)
		printf '%s\n' \
			':Classif|a yes/no question above each call; the answer gates the fix' \
			'u, then Ctrl-r|undo shows the call before the fix; redo puts it back' \
			':Classif pick|classif picks one fix for saveUser among the rules' \
			'Enter in the list, then gra|jump onto a call; gra lists every rule'"'"'s fix'
		;;
	esac
}

# ---- card (runs inside the floating pane) ------------------------------------

# Evaluates a Lua expression in the demo nvim and prints the result. stdin
# stays off the card's terminal: on a terminal the client starts a UI of its
# own and draws over the card.
rpc() {
	nvim --server "${sock}" --remote-expr "luaeval('$1')" </dev/null 2>/dev/null
}

# Rewrites the card's first line: the segment name and the demo's state.
status() {
	printf '\e[1;1H\e[2K \e[1;36m%s\e[0m  %b' "${segment}" "$1"
}

# Draws the steps, then reports when the ast-grep language server has
# published its findings, so the presenter knows ]d has something to visit.
# The card then waits until the demo session closes it.
card() {
	segment="$1"
	sock="$2"
	local n=0 keys text i
	printf '\e[?25l\e[2J\n'
	while IFS='|' read -r keys text; do
		n=$((n + 1))
		printf '\n \e[33m%d\e[0m  \e[1;33m%s\e[0m\n    \e[37m%s\e[0m\n' "${n}" "${keys}" "${text}"
	done < <(steps "${segment}")
	printf '\n \e[36m:qa! returns to the slides\e[0m'
	status '\e[90mwaiting for ast-grep\e[0m'
	for ((i = 0; i < 100; i++)); do
		if [[ "$(rpc 'Demo.findings()' || true)" =~ ^[1-9] ]]; then
			status '\e[32mready\e[0m'
			break
		fi
		sleep 0.1
	done
	((i < 100)) || status '\e[31mast-grep reported no findings\e[0m'
	exec sleep infinity
}

# ---- launcher (runs from the slides) -----------------------------------------

# Reports whether a pane exists and its program still runs.
pane_running() {
	[[ "$(tmux display-message -p -t "$1" '#{pane_dead}' 2>/dev/null)" == 0 ]]
}

# Hands the client back to the slides and closes the demo session. A later
# launch replaces the session, so both act only on the session this launch
# made, by id.
finish() {
	if [[ "$(tmux display-message -p -c "${client}" '#{session_id}' 2>/dev/null)" == "${session_id}" ]]; then
		tmux switch-client -c "${client}" -t "=${home_session}" 2>/dev/null || true
	fi
	tmux kill-session -t "${session_id}" 2>/dev/null || true
}

launch() {
	local segment="$1" demo_pane width height card_width card_height card_y card_pane keys text
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
	session_id="$(tmux display-message -p -t "=${session}:" '#{session_id}')"
	trap finish EXIT
	tmux switch-client -c "${client}" -t "${session_id}"
	sleep 0.5

	# The card fits its longest line: two rows per step, plus the status,
	# the footer and the blank lines between them.
	card_width=30
	card_height=4
	while IFS='|' read -r keys text; do
		((${#keys} + 6 > card_width)) && card_width=$((${#keys} + 6))
		((${#text} + 6 > card_width)) && card_width=$((${#text} + 6))
		card_height=$((card_height + 3))
	done < <(steps "${segment}")

	# The window takes the client's size on switch, so measure it after.
	# The card sits bottom right, above the statusline: code and the grug-far
	# inputs live at the top, and long lines rarely reach that corner. In the
	# triage demo the quickfix list fills the bottom, so the card goes top
	# right, beside the short package and import lines.
	width="$(tmux display-message -p -t "${demo_pane}" '#{window_width}')"
	height="$(tmux display-message -p -t "${demo_pane}" '#{window_height}')"
	card_y=$((height - card_height - 4))
	[[ ${segment} == triage ]] && card_y=1
	card_pane="$(tmux new-pane -d -P -F '#{pane_id}' -t "${demo_pane}" \
		-x "${card_width}" -y "${card_height}" \
		-X "$((width - card_width - 2))" -Y "${card_y}" \
		"'${dir}/demo.sh' --card '${segment}' '${sock}'")"
	# new-pane takes no -T since tmux 3.7, so the title is set afterwards.
	# select-pane also makes the card current, so focus goes back to nvim.
	tmux select-pane -t "${card_pane}" -T ' demo '
	tmux set-option -p -t "${card_pane}" remain-on-exit off
	tmux select-pane -t "${demo_pane}"

	while pane_running "${demo_pane}"; do
		sleep 0.3
	done
	printf 'Demo finished\n'
}

if [[ ${1:-} == --card ]]; then
	card "$2" "$3"
else
	launch "${1:?usage: demo.sh ${segments}}"
fi
