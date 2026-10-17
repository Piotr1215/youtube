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
# A rule with metadata.veto asks its own yes/no question of every call it
# matches, apart from the pick, since a line can be a useful event and still
# print a secret. A yes keeps the call for a person whatever the pick, and so
# does a veto the model cannot score.
#
# It prints one row per call, ✗ still a finding or ✓ settled, with the fix
# that lands. Without a mode nothing is written. The modes:
#
#   --json    one object per call, for demo-init.lua
#   --diff    the rows, then a diff of the fixes that land
#   --apply   the rows, then the same fixes written to the files
#
# A rule with metadata.context names a metavariable that holds a function name,
# such as FN for the function around the match or CALLEE for the one a call
# names. The model reads that function's declaration before the match: the
# tree finds it and the comment above it, in the same file, so the answer
# rests on what the function does. A rule with metadata.min_p lands a fix
# only on an answer that sure.
#
# A call with no answer, or one below min_p, is never fixed, so a model that
# is down or unsure rewrites nothing.
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
# The findings, read twice: once for the calls, once for their vetoes.
input="$(mktemp)"
trap 'rm -f "${edits}" "${input}"' EXIT
cat >"${input}"

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
		# An empty fix removes a statement; when it stood alone on its line,
		# the line goes with it, indentation and newline included.
		if [[ -z ${fix} ]]; then
			while ((start > 0)) && [[ ${content:start-1:1} == [[:blank:]] ]]; do
				start=$((start - 1))
			done
			if ((start == 0)) || [[ ${content:start-1:1} == $'\n' ]] && [[ ${content:end:1} == $'\n' ]]; then
				end=$((end + 1))
			fi
		fi
		content="${content:0:start}${fix}${content:end}"
	done < <(awk -F '\t' -v f="${file}" '$1 == f' "${edits}" | sort -t $'\t' -k2,2nr)
	if [[ ${mode} == apply ]]; then
		printf '%s' "${content}" >"${file}"
	else
		diff --color=always -U1 --label "a/${file}" --label "b/${file}" -- "${file}" <(printf '%s' "${content}") || true
	fi
}

# Prints what the tree holds about the Go function NAME declared in FILE: the
# comment lines right above the declaration, then its signature. Prints
# nothing when FILE declares no such function, such as a method or an import.
declaration() {
	local file="$1" name="$2" line
	[[ ${name} =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || return 0
	line="$(ast-grep scan --json=stream --inline-rules "id: declaration
language: go
rule:
  kind: function_declaration
  has:
    field: name
    regex: ^${name}\$" "${file}" 2>/dev/null | jq -rs '.[0].range.start.line // empty')"
	[[ -n ${line} ]] || return 0
	awk -v n="$((line + 1))" '
		NR < n { doc = ($0 ~ /^[[:space:]]*\/\//) ? doc $0 "\n" : "" }
		NR == n { sub(/[[:space:]]*\{.*$/, ""); printf "%s%s\n", doc, $0; exit }' "${file}"
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
	context=""
	var="$(jq -r '.[0].metadata.context // empty' <<<"${group}")"
	if [[ -n ${var} ]]; then
		context="$(declaration "$(jq -r '.[0].file' <<<"${group}")" \
			"$(jq -r --arg v "${var}" '.[0].metaVariables.single[$v].text // empty' <<<"${group}")")"
	fi
	[[ -n ${context} ]] && args+=(-c "${context}")
	min_p="$(jq -r '.[0].metadata.min_p // empty' <<<"${group}")"
	[[ -n ${min_p} ]] && args+=(-t "${min_p}")
	# classif prints "label p" and exits 1 on any label but the first, which is
	# still an answer here. Exit 2 means no score and 3 an answer below -t:
	# neither may land a fix.
	status=0
	verdict="$(printf '%s\n' "${text}" | classif "${ask}" "${args[@]}" 2</dev/null)" || status=$?
	read -r label p _ <<<"${verdict}"
	sure=true
	((status < 2)) || sure=false

	# The first veto that answers yes, or gives no score, as its rule's message
	# and the answer.
	veto=""
	if ${pick}; then
		where_at="$(jq -c '.[0] | [.file, .range.byteOffset.start]' <<<"${group}")"
		while IFS=$'\t' read -r veto_ask veto_message; do
			veto_status=0
			veto_verdict="$(printf '%s\n' "${text}" | classif "${veto_ask}" 2>/dev/null)" || veto_status=$?
			read -r veto_label veto_p _ <<<"${veto_verdict}"
			if [[ ${veto_label} == yes ]] || ((veto_status == 2)); then
				veto="${veto_message}: ${veto_label:-no score} ${veto_p}"
				break
			fi
		done < <(jq -r -s --argjson at "${where_at}" '
			map(select(.metadata.veto != null and [.file, .range.byteOffset.start] == $at))
			| unique_by(.metadata.veto) | .[] | [.metadata.veto, .message] | @tsv' "${input}")
	fi

	# The call's outcome: whether the model answered, which finding's fix lands
	# (an index into the group, or null), and whether the finding is cleared.
	outcome="$(jq -c --arg label "${label}" --argjson pick "${pick}" --argjson sure "${sure}" '
		(if $pick then map(.metadata.option | split("=")[0]) else map(.metadata.fix_on) end) as $on
		| ($sure and $label != "" and (if $pick then ($on + ["none"]) else ["yes", "no"] end | index($label)) != null) as $answered
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
	[[ -z ${veto} ]] || fix="null"

	if [[ ${mode} == json ]]; then
		jq -c --arg ask "${ask}" --arg label "${label}" --arg p "${p}" --arg context "${context}" \
			--argjson answered "${answered}" --argjson cleared "${cleared}" --argjson fix "${fix}" '{
			rule: .ruleId, ask: $ask, context: $context,
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
		[[ -z ${context} ]] || printf '    \e[38;2;128;128;128mreads › %s\e[0m\n' "$(tail -1 <<<"${context}")"
		continue
	fi
	# ✓ a fix lands and no person is needed; ✗ the call stays for a person.
	${answered} || p="${p} unsure"
	mark='\e[31m✗'
	[[ ${fix} == null ]] || mark='\e[32m✓'
	printf "  ${mark}\\e[0m \\e[36m%s\\e[0m  %s  \\e[33m%s %s\\e[0m\\n" "${where}" "${text}" "${label:-none}" "${p}"
	[[ -z ${context} ]] || printf '    \e[38;2;128;128;128mreads › %s\e[0m\n' "$(tail -1 <<<"${context}")"
	if [[ ${fix} == null ]]; then
		if [[ -n ${veto} ]]; then
			printf '    \e[31m%s\e[0m \e[38;2;128;128;128m› left for a person\e[0m\n' "${veto}"
		else
			printf '    \e[38;2;128;128;128mleft for a person\e[0m\n'
		fi
		continue
	fi
	printf '    \e[38;2;128;128;128mfix ›\e[0m \e[32m%s\e[0m\n' "$(jq -r '. | if . == "" then "(the line is removed)" else . end' <<<"${fix}")"
	if [[ ${mode} != rows ]]; then
		jq -r '[.file,
			(.replacementOffsets.start // .range.byteOffset.start),
			(.replacementOffsets.end // .range.byteOffset.end),
			(.replacement | @base64)] | @tsv' <<<"${finding}" >>"${edits}"
	fi
done < <(jq -c -s "map(select(${question} != null)) | group_by([.file, .range.byteOffset.start, ${question}]) | .[] | sort_by(.ruleId)" "${input}")

if [[ ${mode} == diff || ${mode} == apply ]]; then
	[[ ${mode} == diff ]] && printf '\n'
	while IFS= read -r file; do
		fix_file "${file}"
	done < <(cut -f1 "${edits}" | sort -u)
fi
