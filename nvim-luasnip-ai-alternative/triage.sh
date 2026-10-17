#!/usr/bin/env bash
# Asks classif, the local model, about each ast-grep finding whose rule carries
# a question in metadata.ask, and keeps the finding only when the answer is the
# rule's metadata.keep label. ast-grep picks the code; the model judges it.
#
#   ast-grep scan --json=stream --include-metadata FILE... | ./triage.sh [MODE]
#
# Without a mode it prints one row per finding: ✗ kept, ✓ dismissed. A kept
# finding whose rule has a fix shows it below, the change gra would offer in
# the editor. The modes:
#
#   --json    one object per finding, for demo-init.lua
#   --diff    the rows, then a diff of the rule's fix on each kept finding
#   --apply   the rows, then the same fixes written to the files
#
# With --diff and --apply the model's answer decides where the fix lands: a
# finding it dismisses keeps its code, even though the rule offers a fix. A
# finding with no answer stays as a warning but is never fixed, so a model
# that is down rewrites nothing.
set -euo pipefail

mode=rows
case ${1:-} in
--json | --diff | --apply) mode="${1#--}" ;;
esac

# Fixes for kept findings, one per line: file, start byte, end byte, and the
# replacement in base64, since it may hold tabs or newlines.
edits="$(mktemp)"
trap 'rm -f "${edits}"' EXIT

# Splices every recorded fix for one file into its text, last offset first so
# the earlier offsets stay valid, then prints the diff or writes the file.
# ast-grep counts offsets in bytes, and LC_ALL=C makes bash slice in bytes.
fix_file() {
	local file="$1" content start end fix LC_ALL=C
	content="$(
		cat -- "${file}"
		printf x
	)"
	content="${content%x}"
	while IFS=$'\t' read -r _ start end fix; do
		fix="$(base64 -d <<<"${fix}")"
		content="${content:0:start}${fix}${content:end}"
	done < <(awk -F '\t' -v f="${file}" '$1 == f' "${edits}" | sort -t $'\t' -k2,2nr)
	if [[ ${mode} == apply ]]; then
		printf '%s' "${content}" >"${file}"
	else
		diff --color=always -U1 --label "a/${file}" --label "b/${file}" -- "${file}" <(printf '%s' "${content}") || true
	fi
}

while IFS= read -r finding; do
	ask="$(jq -r '.metadata.ask // empty' <<<"${finding}")"
	[[ -n ${ask} ]] || continue
	keep="$(jq -r '.metadata.keep // "no"' <<<"${finding}")"
	text="$(jq -r '.text' <<<"${finding}")"
	# classif prints "label p" and exits 1 on no, which is an answer here.
	verdict="$(printf '%s\n' "${text}" | classif "${ask}" 2</dev/null)" || true
	label="${verdict%% *}"
	p="${verdict##* }"
	# No verdict (model down, no answer) keeps the finding as a warning, but
	# only a real answer may let the fix through.
	kept=true answered=false
	[[ ${label} == yes || ${label} == no ]] && answered=true
	${answered} && [[ ${label} != "${keep}" ]] && kept=false
	if [[ ${mode} == json ]]; then
		jq -c --arg label "${label:-none}" --arg p "${p:-}" --argjson kept "${kept}" --argjson answered "${answered}" '{
			line: .range.start.line, col: .range.start.column,
			end_line: .range.end.line, end_col: .range.end.column,
			start: .range.byteOffset.start, end: .range.byteOffset.end,
			fix_start: (.replacementOffsets.start // .range.byteOffset.start),
			fix_end: (.replacementOffsets.end // .range.byteOffset.end),
			message, label: $label, p: $p, kept: $kept, answered: $answered, fix: .replacement
		}' <<<"${finding}"
		continue
	fi
	where="$(jq -r '"\(.file):\(.range.start.line + 1)"' <<<"${finding}")"
	if ${kept}; then
		printf '  \e[31m✗\e[0m \e[36m%s\e[0m  %s  \e[33m%s %s\e[0m\n' "${where}" "${text}" "${label:-none}" "${p}"
		if [[ ${mode} == rows ]]; then
			fix="$(jq -r '.replacement // empty' <<<"${finding}")"
			[[ -z ${fix} ]] || printf '    \e[38;2;128;128;128mfix ›\e[0m \e[32m%s\e[0m\n' "${fix}"
		elif ${answered}; then
			jq -r 'select(.replacement != null) | [.file,
				(.replacementOffsets.start // .range.byteOffset.start),
				(.replacementOffsets.end // .range.byteOffset.end),
				(.replacement | @base64)] | @tsv' <<<"${finding}" >>"${edits}"
		fi
	else
		printf '  \e[32m✓\e[0m \e[36m%s\e[0m  %s  \e[38;2;128;128;128m%s %s\e[0m\n' "${where}" "${text}" "${label}" "${p}"
	fi
done

if [[ ${mode} == diff || ${mode} == apply ]]; then
	[[ ${mode} == diff ]] && printf '\n'
	while IFS= read -r file; do
		fix_file "${file}"
	done < <(cut -f1 "${edits}" | sort -u)
fi
