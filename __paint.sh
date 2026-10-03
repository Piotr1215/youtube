#!/usr/bin/env bash
# Color slide text without ANSI escape codes.
#
# Run it as the paint command in a presenterm +exec_replace block, one row
# per call, as color/text pairs. Text is printed verbatim and never parsed,
# so brackets, percent signs, and backslashes need no escaping.
#
#   paint cyan 'find the spot' gray ' ──▶ ' 'bold yellow' 'next line'
#   paint plain 'no color, ' '#ff8800' 'any hex color, ' 'white on red' 'a background'
#   paint
#
# A color is one or more words: plain, bold, italic, underline, a name
# (black red green yellow blue magenta cyan white gray grey), a hex #rrggbb,
# and "on <color>" for the background. paint with no arguments prints a
# blank line.
#
# Install once: ln -s ~/dev/youtube/__paint.sh ~/.local/bin/paint
# Sourcing the file defines the same paint function without a new process.
#
# presenterm ignores the bright codes (90-97) and the 256-color grey ramp in
# command output, so gray is sent as RGB, like every hex color.

# Set _paint_code to the SGR parameters for one color word.
# $1: color word, $2: 30 for foreground, 40 for background
_paint_color() {
	local word="$1" base="$2" i
	local names=(black red green yellow blue magenta cyan white)
	for i in "${!names[@]}"; do
		if [[ "${word}" == "${names[i]}" ]]; then
			_paint_code=$((base + i))
			return 0
		fi
	done
	case "${word}" in
	gray | grey) word='#808080' ;;
	esac
	if [[ "${word}" =~ ^#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$ ]]; then
		_paint_code="$((base + 8));2;$((16#${BASH_REMATCH[1]}));$((16#${BASH_REMATCH[2]}));$((16#${BASH_REMATCH[3]}))"
		return 0
	fi
	printf 'paint: unknown color "%s"\n' "${word}" >&2
	return 1
}

# Set _paint_sgr to the joined SGR parameters for a color spec like "bold yellow".
# $1: color spec
_paint_style() {
	local words word base=30 codes=()
	IFS=' ' read -ra words <<<"$1"
	for word in "${words[@]}"; do
		case "${word}" in
		plain | -) ;;
		bold) codes+=(1) ;;
		italic) codes+=(3) ;;
		underline) codes+=(4) ;;
		on)
			base=40
			continue
			;;
		*)
			_paint_color "${word}" "${base}" || return 1
			codes+=("${_paint_code}")
			;;
		esac
		base=30
	done
	local IFS=';'
	_paint_sgr="${codes[*]}"
}

# Print one row of colored text.
# $@: color/text pairs
paint() {
	if (($# % 2)); then
		printf 'paint: expected color/text pairs, got %d arguments\n' "$#" >&2
		return 1
	fi
	local line=''
	while (($#)); do
		_paint_style "$1" || return 1
		if [[ -n "${_paint_sgr}" ]]; then
			line+=$'\e['"${_paint_sgr}m$2"$'\e[0m'
		else
			line+="$2"
		fi
		shift 2
	done
	printf '%s\n' "${line}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	paint "$@"
fi
