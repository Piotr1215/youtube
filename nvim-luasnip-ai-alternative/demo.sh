#!/usr/bin/env bash
# Opens one Neovim demo with a list of steps beside it.
#
#   ./demo.sh tree | rules
#
# The slides call this. It rebuilds the demo session (your Neovim with
# demo-init.lua on top), switches the presenter's client to it, and opens a
# floating card listing the segment's steps. The card never takes focus: the
# presenter types every key into nvim, at their own pace, and may do anything
# else in the file. Quitting nvim (:qa!) returns the client to the slides.
set -euo pipefail

session="ast-grep-demo"
dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
segments="tree|rules"
# Each launch gets its own demo nvim socket; the card receives it as --card's
# second argument. setup-demo.sh says why the path is never reused.
sock="${XDG_RUNTIME_DIR:-/tmp}/ast-grep-demo-$$.sock"

# Prints a segment's steps, the keys of one per line. The presenter says what
# each does; the card only shows what to type next.
steps() {
	case "$1" in
	tree)
		printf '%s\n' \
			'/got here, then Enter' \
			':InspectTree' \
			'j j j j' \
			'q' \
			'v an an an'
		;;
	rules)
		printf '%s\n' \
			']d' \
			'gra' \
			'Enter'
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
	local n=0 keys i
	printf '\e[?25l\e[2J'
	while IFS= read -r keys; do
		n=$((n + 1))
		printf '\n \e[33m%d\e[0m  \e[1;33m%s\e[0m' "${n}" "${keys}"
	done < <(steps "${segment}")
	printf '\n \e[36m:qa! back to the slides\e[0m'
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
	if tmux list-clients -t "${session_id}" -F '#{client_name}' 2>/dev/null | grep -qxF -- "${client}"; then
		tmux switch-client -c "${client}" -t "=${home_session}" 2>/dev/null || true
	fi
	tmux kill-session -t "${session_id}" 2>/dev/null || true
}

launch() {
	local segment="$1" demo_pane card_width card_height card_pane keys
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

	# The card fits its longest line: one row per step, plus the status and
	# the footer.
	card_width=30
	card_height=2
	while IFS= read -r keys; do
		((${#keys} + 6 > card_width)) && card_width=$((${#keys} + 6))
		card_height=$((card_height + 1))
	done < <(steps "${segment}")

	# The card sits top left, below the tabline: at recording size the code
	# fills the screen, and the top of the file holds only imports. The
	# search, the jump to a finding, the fix menu and the syntax tree all land
	# further down or on the right half.
	card_pane="$(tmux new-pane -d -P -F '#{pane_id}' -t "${demo_pane}" \
		-x "${card_width}" -y "${card_height}" \
		-X 1 -Y 2 \
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
