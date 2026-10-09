#!/usr/bin/env bash
# Score one or more versions of a question against the labeled examples in
# examples.tsv, through the model on the GPU node. Each row shows the model's
# real answer and confidence; it matches only when the answer equals the label,
# so unknown always counts as a miss.
#
#   ./eval.sh "Is this an infrastructure problem?" "Is this a Kubernetes problem?"
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

for question in "$@"; do
	cmd "${question}"
	hits=0 total=0
	while IFS=$'\t' read -r want text; do
		answer="$(./ask "${question}" "${text}" 2>/dev/null || true)"
		got="${answer%% *}"
		total=$((total + 1))
		if [[ "${got}" == "${want}" ]]; then
			hits=$((hits + 1))
			paint green '  ✓  ' gray "$(printf '%-13s' "${answer:-no answer}")" plain "${text}"
		else
			paint red '  ✗  ' gray "$(printf '%-13s' "${answer:-no answer}")" plain "${text}"
		fi
	done <examples.tsv
	paint 'bold yellow' "     ${hits}/${total} match the labels"
done
