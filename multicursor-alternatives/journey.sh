#!/usr/bin/env bash
# Prints the chapter map for a divider slide: chapters already covered in
# green, the current one in yellow, the rest dimmed.
#
#   ./journey.sh 3
set -euo pipefail

current="${1:?usage: journey.sh <chapter number>}"
chapters=("multiline edits" "basic concepts" "classic methods" "multicursor" "keystroke golf" "choosing a method")

for i in "${!chapters[@]}"; do
	n=$((i + 1))
	if ((n > 1)); then
		if ((n <= current)); then
			printf '  \e[32m│\e[0m\n'
		else
			printf '  \e[90m│\e[0m\n'
		fi
	fi
	if ((n < current)); then
		printf '  \e[32m✓  %s\e[0m\n' "${chapters[i]}"
	elif ((n == current)); then
		printf '  \e[1;33m▶  %s\e[0m\n' "${chapters[i]}"
	else
		printf '  \e[90m·  %s\e[0m\n' "${chapters[i]}"
	fi
done
