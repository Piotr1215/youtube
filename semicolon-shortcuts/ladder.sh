#!/usr/bin/env bash
# Prints the steps taken so far for a step slide: earlier steps in green, the
# current one in yellow. Later steps stay hidden, so the payoff is not shown
# before its slide.
#
#   ./ladder.sh 3
set -euo pipefail

current="${1:?usage: ladder.sh <step number>}"
steps=("mouse" "C alias" "clipboard history" "fzf" "Ctrl-T" ";; shortcuts")

line=""
for ((i = 0; i < current; i++)); do
	if ((i > 0)); then
		line+=$'\e[90m ─▶ \e[0m'
	fi
	if ((i + 1 < current)); then
		line+=$'\e[32m'"${steps[i]}"$'\e[0m'
	else
		line+=$'\e[1;33m'"${steps[i]}"$'\e[0m'
	fi
done
printf '%s\n' "${line}"
