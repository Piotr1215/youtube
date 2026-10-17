#!/usr/bin/env bash
# Asks classif, the local model, about each ast-grep finding whose rule carries
# a question in metadata.ask, and keeps the finding only when the answer is the
# rule's metadata.keep label. ast-grep picks the code; the model judges it.
#
#   ast-grep scan --json=stream --include-metadata FILE | ./triage.sh [--json]
#
# Prints one row per finding: ✗ kept, ✓ dismissed. With --json it prints one
# object per finding instead, for demo-init.lua to turn into diagnostics.
set -euo pipefail

json=false
[[ ${1:-} == --json ]] && json=true

while IFS= read -r finding; do
	ask="$(jq -r '.metadata.ask // empty' <<<"${finding}")"
	[[ -n ${ask} ]] || continue
	keep="$(jq -r '.metadata.keep // "no"' <<<"${finding}")"
	text="$(jq -r '.text' <<<"${finding}")"
	# classif prints "label p" and exits 1 on no, which is an answer here.
	verdict="$(printf '%s\n' "${text}" | classif "${ask}" 2</dev/null)" || true
	label="${verdict%% *}"
	p="${verdict##* }"
	# No verdict (model down, no answer) keeps the finding: fail open.
	kept=true
	[[ ${label} == yes || ${label} == no ]] && [[ ${label} != "${keep}" ]] && kept=false
	if ${json}; then
		jq -c --arg label "${label:-none}" --arg p "${p:-}" --argjson kept "${kept}" '{
			line: .range.start.line, col: .range.start.column,
			end_line: .range.end.line, end_col: .range.end.column,
			message, label: $label, p: $p, kept: $kept
		}' <<<"${finding}"
	else
		where="$(jq -r '"\(.file):\(.range.start.line + 1)"' <<<"${finding}")"
		if ${kept}; then
			printf '  \e[31m✗\e[0m \e[36m%s\e[0m  %s  \e[33m%s %s\e[0m\n' "${where}" "${text}" "${label:-none}" "${p}"
		else
			printf '  \e[32m✓\e[0m \e[36m%s\e[0m  %s  \e[90m%s %s\e[0m\n' "${where}" "${text}" "${label}" "${p}"
		fi
	fi
done
