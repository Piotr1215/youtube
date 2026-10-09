#!/usr/bin/env bash
# Prints the chapter map for a divider slide: chapters already covered in
# green, the current one in yellow, the rest dimmed. The chapters follow the
# talk's framing: the shift, then the discipline, runtime, and interface that
# converge on paved roads for AI tools.
#
#   ./journey.sh 3
set -euo pipefail

current="${1:?usage: journey.sh <chapter number>}"
chapters=("the shift: AI users" "the discipline: platform engineering" "the runtime: Kubernetes" "the interface: MCP" "next steps")
# presenterm drops bright (90-97) codes in command output, so dim is sent as RGB.
dim='\e[38;2;128;128;128m'

for i in "${!chapters[@]}"; do
	n=$((i + 1))
	if ((n > 1)); then
		if ((n <= current)); then
			printf '  \e[32m│\e[0m\n'
		else
			printf "  ${dim}│\e[0m\n"
		fi
	fi
	if ((n < current)); then
		printf '  \e[32m✓  %s\e[0m\n' "${chapters[i]}"
	elif ((n == current)); then
		printf '  \e[1;33m▶  %s\e[0m\n' "${chapters[i]}"
	else
		printf "  ${dim}·  %s\e[0m\n" "${chapters[i]}"
	fi
done
