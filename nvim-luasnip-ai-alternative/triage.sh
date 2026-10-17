#!/usr/bin/env bash
# Asks classif, the local model, about ast-grep findings, and lets the answer
# decide which rule's fix lands. ast-grep finds the code and builds every fix;
# the model only judges.
#
#   ast-grep scan --json=stream --include-metadata FILE... | ./triage.sh [--pick] [MODE]
#
# Without --pick the model is a gate. A rule asks a yes/no question in
# metadata.ask; the answer named by fix_on lands the rule's fix, the one named
# by clear_on clears the finding, and any other answer keeps it as a warning.
#
# With --pick the model picks a fix. Rules that match the same call offer one
# option each in metadata.option, as name=when to pick it, under the question
# in metadata.choose. classif -e picks one name per call, and that rule's fix
# lands; none keeps the call as a warning.
#
# Without a mode it prints one row per call: ✗ still a finding, ✓ cleared,
# with the fix that would land. The modes:
#
#   --json    one object per call, for demo-init.lua
#   --diff    the rows, then a diff of the fixes that land
#   --apply   the rows, then the same fixes written to the files
#
# A call with no answer is never fixed, so a model that is down rewrites
# nothing.
set -euo pipefail

pick=false
mode=rows
for arg in "$@"; do
	case ${arg} in
	--pick) pick=true ;;
	--json | --diff | --apply) mode="${arg#--}" ;;
	esac
done

# Fixes that land, one per line: file, start byte, end byte, and the
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

# The question each finding answers to, and the findings grouped by call:
# rules that match the same code with the same question are asked once.
if ${pick}; then
	question='.metadata.choose'
else
	question='.metadata.ask'
fi

while IFS= read -r group; do
	ask="$(jq -r ".[0] | ${question}" <<<"${group}")"
	text="$(jq -r '.[0].text' <<<"${group}")"
	args=()
	if ${pick}; then
		while IFS= read -r option; do
			args+=(-e "${option}")
		done < <(jq -r '.[].metadata.option // empty' <<<"${group}")
	fi
	# classif prints "label p" and exits non-zero on any label but the first,
	# which is still an answer here.
	verdict="$(printf '%s\n' "${text}" | classif "${ask}" "${args[@]}" 2</dev/null)" || true
	label="${verdict%% *}"
	p="${verdict##* }"
	[[ -n ${verdict} ]] || p=""

	# The call's outcome: whether the model answered, which finding's fix lands
	# (an index into the group, or null), and whether the finding is cleared.
	outcome="$(jq -c --arg label "${label}" --argjson pick "${pick}" '
		(if $pick then map(.metadata.option | split("=")[0]) else map(.metadata.fix_on) end) as $on
		| ($label != "" and (if $pick then ($on + ["none"]) else ["yes", "no"] end | index($label)) != null) as $answered
		| {
			answered: $answered,
			lands: (if $answered then ([range(length)] | map(select($on[.] == $label)) | first) else null end),
			cleared: ($answered and ($pick | not) and .[0].metadata.clear_on == $label)
		}' <<<"${group}")"
	answered="$(jq -r .answered <<<"${outcome}")"
	cleared="$(jq -r .cleared <<<"${outcome}")"
	lands="$(jq -r '.lands // empty' <<<"${outcome}")"
	finding="$(jq -c ".[${lands:-0}]" <<<"${group}")"
	fix="null"
	[[ -n ${lands} ]] && fix="$(jq -c '.replacement' <<<"${finding}")"

	if [[ ${mode} == json ]]; then
		jq -c --arg ask "${ask}" --arg label "${label:-none}" --arg p "${p}" \
			--argjson answered "${answered}" --argjson cleared "${cleared}" --argjson fix "${fix}" '{
			rule: .ruleId, ask: $ask,
			line: .range.start.line, col: .range.start.column,
			end_line: .range.end.line, end_col: .range.end.column,
			start: .range.byteOffset.start, end: .range.byteOffset.end,
			fix_start: (.replacementOffsets.start // .range.byteOffset.start),
			fix_end: (.replacementOffsets.end // .range.byteOffset.end),
			message, label: $label, p: $p, answered: $answered,
			kept: ($cleared | not), fix: $fix
		}' <<<"${finding}"
		continue
	fi
	where="$(jq -r '"\(.file):\(.range.start.line + 1)"' <<<"${finding}")"
	if ${cleared}; then
		printf '  \e[32m✓\e[0m \e[36m%s\e[0m  %s  \e[38;2;128;128;128m%s %s\e[0m\n' "${where}" "${text}" "${label}" "${p}"
		continue
	fi
	printf '  \e[31m✗\e[0m \e[36m%s\e[0m  %s  \e[33m%s %s\e[0m\n' "${where}" "${text}" "${label:-none}" "${p}"
	[[ ${fix} == null ]] && continue
	if [[ ${mode} == rows ]]; then
		printf '    \e[38;2;128;128;128mfix ›\e[0m \e[32m%s\e[0m\n' "$(jq -r . <<<"${fix}")"
	else
		jq -r '[.file,
			(.replacementOffsets.start // .range.byteOffset.start),
			(.replacementOffsets.end // .range.byteOffset.end),
			(.replacement | @base64)] | @tsv' <<<"${finding}" >>"${edits}"
	fi
done < <(jq -c -s "map(select(${question} != null)) | group_by([.file, .range.byteOffset.start, ${question}]) | .[] | sort_by(.ruleId)")

if [[ ${mode} == diff || ${mode} == apply ]]; then
	[[ ${mode} == diff ]] && printf '\n'
	while IFS= read -r file; do
		fix_file "${file}"
	done < <(cut -f1 "${edits}" | sort -u)
fi
