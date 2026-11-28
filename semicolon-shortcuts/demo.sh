#!/usr/bin/env bash
# Runs the deck's demos. The slides call it from hidden lines of code blocks
# marked +exec +acquire_terminal: Ctrl+E hands the slide's terminal to a demo
# shell, and Ctrl+D in it brings the slide back.
#
#   ./demo.sh shell <<'EOF'           the presenter's regular zsh in the dotfiles
#   bat ;;dot                         repo, with the slide's commands waiting at
#   curl -sI   # a cue                one prompt after another, each cut at its
#   # a cue alone, never typed        first ;; (AutoKey only sees real keys, so
#   EOF                               the presenter types the trigger)
#   ./demo.sh register                adds the ;;docs trigger for lists/docs
#   ./demo.sh registered              exits 0 while register's changes are in
#                                      place, 1 when not
#   ./demo.sh unregister              removes what register added, nothing else
#   ./demo.sh clip-demo               swaps the presenter's clipboard history for
#                                      an empty one for the demo
#   ./demo.sh clip-own                brings the presenter's history back
#   ./demo.sh clip-swapped            exits 0 while the empty one stands in
set -euo pipefail

dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo="${HOME}/dev/dotfiles"
engine="${HOME}/.claude/skills/semicolon-shortcuts/scripts/manage_shortcut.sh"
bindings="${repo}/scripts/__show_autokey_bindings.sh"
sets="${VALUE_SETS_DIR:-${HOME}/.config/value-sets}"
label='project page URL (picker)'
# What register added, one word per line; unregister removes only these.
state="${dir}/.registered"
# The stand-in clipboard manager's own data folder, history included.
clips="${dir}/.clipboard"

# Starts the demo shell with the slide's commands queued at the prompt. They
# arrive on stdin, so the shell reads its keys from the terminal.
shell() {
	cd "${repo}"
	DEMO_PRELOAD="$(preload)" ZDOTDIR="${dir}/zdot" exec zsh -i </dev/tty
}

# The slide's commands, one per line: each cut at its first ;; and before a
# "  # cue", and ending in a space so the next key starts a new word. A line
# that is only a cue is for the viewer and never reaches the prompt.
preload() {
	local line text cut=';;'
	while IFS= read -r line; do
		[[ ${line} == '#'* ]] && continue
		text="${line%%"${cut}"*}"
		text="${text%%  #*}"
		text="${text%"${text##*[! ]}"}"
		printf '%s \n' "${text}"
	done
}

# The ;;docs line AutoKey lists, when one exists. grep reads the whole list,
# since -q would close the pipe early and pipefail would fail on a match.
trigger() {
	"${bindings}" --bang-plain 2>/dev/null | grep -E '^;;docs +→ ' || true
}

# Whether register has added anything that unregister has not taken back.
registered() {
	[[ -f "${state}" ]]
}

# Copies the demo list into the value sets and points ;;docs at it, noting each
# change in the state file. A docs list or ;;docs trigger that was there before
# stops it before any change.
register() {
	if ! registered; then
		if [[ -e "${sets}/docs" || -n $(trigger) ]]; then
			printf 'demo.sh: a docs list or ;;docs trigger already exists\n' >&2
			exit 1
		fi
		cp "${dir}/lists/docs" "${sets}/docs"
		printf 'list\n' >"${state}"
	fi
	if ! grep -qx trigger "${state}"; then
		"${engine}" add-picker docs_picker ';;docs' docs "${label}" >/dev/null
		printf 'trigger\n' >>"${state}"
	fi
	printf '\e[32m✓ %s\e[0m\n' ';;docs → ~/.config/value-sets/docs'
}

# Takes back what the state file says register added, and only while it is
# still the deck's: a trigger or list replaced since then stays.
unregister() {
	registered || return 0
	if grep -qx trigger "${state}" && [[ $(trigger) == *"→ ${label}" ]]; then
		"${engine}" remove ';;docs' >/dev/null
	fi
	if grep -qx list "${state}" && cmp -s "${dir}/lists/docs" "${sets}/docs"; then
		rm -f "${sets}/docs"
	fi
	rm -f "${state}"
}

# Whether the demo clipboard manager stands in for the presenter's.
clip_swapped() {
	[[ -f "${clips}/pid" ]]
}

# Waits up to three seconds for a process to exit.
gone() {
	local i
	for ((i = 0; i < 30; i++)); do
		kill -0 "$1" 2>/dev/null || return 0
		sleep 0.1
	done
	return 1
}

# Stands an empty clipboard history in for the presenter's, so the demo shows
# only what the deck copies, from its own folders. Only one parcellite runs at a time (a second one
# hands off to the first and exits), so the presenter's stops until clip-own.
# Its history stays on disk.
clip_demo() {
	local own pid d i
	clip_swapped && return 0
	mkdir -p "${clips}/data" "${clips}/config/parcellite"
	for d in fonts icons; do
		if [[ -d "${HOME}/.local/share/${d}" ]]; then
			ln -sfn "${HOME}/.local/share/${d}" "${clips}/data/${d}"
		fi
	done
	for d in gtk-3.0 dconf; do
		if [[ -d "${HOME}/.config/${d}" ]]; then
			ln -sfn "${HOME}/.config/${d}" "${clips}/config/${d}"
		fi
	done
	# The presenter's settings, except that it records copies (C writes the
	# clipboard), skips mouse selections and keeps two entries, so the demo's two
	# copies push out whatever it found at start. The presenter's file stays as is.
	sed -E 's/^use_copy=.*/use_copy=true/; s/^use_primary=.*/use_primary=false/; s/^history_limit=.*/history_limit=2/' \
		"${HOME}/.config/parcellite/parcelliterc" >"${clips}/config/parcellite/parcelliterc"
	for own in $(pgrep -x -u "${USER}" parcellite || true); do
		touch "${clips}/own"
		kill "${own}"
		gone "${own}"
	done
	XDG_DATA_HOME="${clips}/data" XDG_CONFIG_HOME="${clips}/config" setsid -f parcellite >/dev/null 2>&1 </dev/null
	for ((i = 0; i < 30; i++)); do
		pid="$(pgrep -x -u "${USER}" parcellite || true)"
		[[ -n ${pid} ]] && break
		sleep 0.1
	done
	printf '%s\n' "${pid}" >"${clips}/pid"
}

# Stops the stand-in, told apart by the data folder in its environment, and
# starts the presenter's parcellite again when one ran before.
clip_own() {
	local pid
	clip_swapped || return 0
	pid="$(<"${clips}/pid")"
	if [[ -n ${pid} ]] && tr '\0' '\n' <"/proc/${pid}/environ" 2>/dev/null |
		grep -x "XDG_DATA_HOME=${clips}/data" >/dev/null; then
		kill "${pid}"
		gone "${pid}"
	fi
	if [[ -f "${clips}/own" ]] && ! pgrep -x -u "${USER}" parcellite >/dev/null; then
		setsid -f parcellite >/dev/null 2>&1 </dev/null
	fi
	rm -rf "${clips}"
}

case "${1:-}" in
shell | preload | register | registered | unregister) "$1" ;;
clip-demo | clip-own | clip-swapped) "${1//-/_}" ;;
*)
	printf 'usage: demo.sh shell|preload|register|registered|unregister|clip-demo|clip-own|clip-swapped\n' >&2
	exit 2
	;;
esac
