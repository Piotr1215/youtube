#!/usr/bin/env bash
# Runs the deck's demos. The slides call it from hidden lines of +exec code
# blocks: Ctrl+E opens a new terminal window for the demo, and Ctrl+D in that
# window closes it and leaves the presenter on the slide.
#
#   ./demo.sh window <<<'nvim ;;dot'  a zsh window in the dotfiles repo with the
#                                      command typed up to its first ;; (AutoKey
#                                      only sees real keys, so the presenter
#                                      types the trigger)
#   ./demo.sh register                adds the ;;docs trigger for lists/docs
#   ./demo.sh registered              exits 0 while register's changes are in
#                                      place, 1 when not
#   ./demo.sh unregister              removes what register added, nothing else
set -euo pipefail

dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo="${HOME}/dev/dotfiles"
engine="${HOME}/.claude/skills/semicolon-shortcuts/scripts/manage_shortcut.sh"
bindings="${repo}/scripts/__show_autokey_bindings.sh"
sets="${VALUE_SETS_DIR:-${HOME}/.config/value-sets}"
label='project page URL (picker)'
# What register added, one word per line; unregister removes only these.
state="${dir}/.registered"

# Opens the demo window with the slide's command waiting at the prompt, and
# returns when the presenter closes it. The window's zsh is not inside tmux.
window() {
	local text
	text="$(preload)"
	env -u TMUX -u TMUX_PANE DEMO_PRELOAD="${text}" ZDOTDIR="${dir}/zdot" \
		alacritty --title demo --working-directory "${repo}" -e zsh -i \
		>/dev/null 2>&1 </dev/null
}

# The slide's command up to its first ;;, ending in a space so the next key
# starts a new word. Editors drop trailing spaces, so the slide cannot keep one.
preload() {
	local line cut=';;' text
	line="$(cat)"
	text="${line%%"${cut}"*}"
	[[ -z ${text} || ${text} == *' ' ]] || text+=' '
	printf '%s' "${text}"
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

case "${1:-}" in
window | preload | register | registered | unregister) "$1" ;;
*)
	printf 'usage: demo.sh window|preload|register|registered|unregister\n' >&2
	exit 2
	;;
esac
