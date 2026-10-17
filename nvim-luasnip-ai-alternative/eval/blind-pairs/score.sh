#!/usr/bin/env bash
# Runs every pair dir under $1 through the real triage path with the rules in
# this folder and scores each line against the pair's intended label.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
pairs="$1"
cd /home/decoder/dev/youtube/nvim-luasnip-ai-alternative
right=0 acted_right=0 acted_wrong=0
scan="$(mktemp)"
trap 'rm -f "${scan}"' EXIT
for d in "${pairs}"/p*/; do
	i=$((10#$(basename "$d" | tr -dc 0-9) - 1))
	dbg="$(jq -r ".[$i].debug_func" "${pairs}/pairs.json")"
	ast-grep scan -c "${here}/sgconfig.yml" --filter '^log-(debug|info)$' --include-metadata --json=stream "$d/main.go" >"${scan}"
	out="$(./triage.sh --pick <"${scan}" | sed 's/\x1b\[[0-9;]*m//g')"
	while IFS=$'\t' read -r label p unsure fn fix; do
		want=info; [[ ${fn} == "${dbg}" ]] && want=debug
		mark="  "
		[[ ${label} == "${want}" ]] && right=$((right + 1)) && mark="ok"
		if [[ ${fix} == fix ]]; then
			if [[ ${label} == "${want}" ]]; then acted_right=$((acted_right + 1)); else acted_wrong=$((acted_wrong + 1)); mark="XX"; fi
		fi
		printf '%s %-4s %-14s want %-5s got %-5s %s %s\n' "${mark}" "$(basename "$d")" "${fn}" "${want}" "${label}" "${p}" "${unsure}"
	done < <(awk '
		/^  (✓|✗) / { label = $(NF-1); p = $NF; unsure = ""; if ($NF == "unsure") { label = $(NF-2); p = $(NF-1); unsure = "unsure" } }
		/reads ›/ { fn = $0; sub(/.*func (\([^)]*\) )?/, "", fn); sub(/\(.*/, "", fn) }
		/fix ›|left for a person/ { printf "%s\t%s\t%s\t%s\t%s\n", label, p, (unsure == "" ? "-" : unsure), fn, (/fix ›/ ? "fix" : "person") }' <<<"${out}")
done
printf 'right label %d/20, fixes right %d, fixes wrong %d\n' "${right}" "${acted_right}" "${acted_wrong}"
