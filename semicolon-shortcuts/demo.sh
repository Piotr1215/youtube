#!/usr/bin/env bash
# Runs the deck's demos. The slides call it from hidden lines of code blocks
# marked +exec +acquire_terminal: Ctrl+E gives the slide's window to the demo,
# and leaving the demo shell (Ctrl+D) brings the slide back.
#
#   ./demo.sh shell <<<'nvim ;;dot '  zsh in the dotfiles repo with the command
#                                      typed up to its first ;; (AutoKey only
#                                      sees real keys, so the presenter types
#                                      the trigger)
#   ./demo.sh register                adds the ;;docs trigger for lists/docs
#   ./demo.sh registered              exits 0 when ;;docs exists, 1 when not
#   ./demo.sh unregister              removes ;;docs and its list
set -euo pipefail

dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo="${HOME}/dev/dotfiles"
engine="${HOME}/.claude/skills/semicolon-shortcuts/scripts/manage_shortcut.sh"
bindings="${repo}/scripts/__show_autokey_bindings.sh"
sets="${VALUE_SETS_DIR:-${HOME}/.config/value-sets}"

# Starts the demo shell with the slide's command waiting at the prompt. The
# command arrives on stdin, so the shell reads its keys from the terminal.
shell() {
	cd "${repo}"
	DEMO_PRELOAD="$(preload)" ZDOTDIR="${dir}/zdot" exec zsh -i </dev/tty
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

# Reports whether AutoKey has a ;;docs trigger. grep reads the whole list, since
# -q would close the pipe early and pipefail would turn a match into a failure.
registered() {
	"${bindings}" --bang-plain 2>/dev/null | grep '^;;docs ' >/dev/null
}

# Copies the demo list into the value sets and points ;;docs at it.
register() {
	[[ -f "${sets}/docs" ]] || cp "${dir}/lists/docs" "${sets}/docs"
	if ! registered; then
		"${engine}" add-picker docs_picker ';;docs' docs 'project page URL (picker)' >/dev/null
	fi
	printf '\e[32m✓ %s\e[0m\n\n' ';;docs → lists/docs'
}

# Takes the desktop back to how it was before the deck ran.
unregister() {
	if registered; then
		"${engine}" remove ';;docs' >/dev/null
	fi
	rm -f "${sets}/docs"
}

case "${1:-}" in
shell | preload | register | registered | unregister) "$1" ;;
*)
	printf 'usage: demo.sh shell|preload|register|registered|unregister\n' >&2
	exit 2
	;;
esac
