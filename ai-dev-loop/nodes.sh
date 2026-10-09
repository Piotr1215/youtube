#!/usr/bin/env bash
# list the nodes of ai-dev and say where each one runs, then where
# the model pod landed once the classif Stack has deployed it.
#
#   ./nodes.sh
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

cmd "kubectl get nodes"
# A node that just joined turns Ready once its network pod starts.
kubectl wait --for=condition=Ready node --all --timeout=120s >/dev/null 2>&1 || true
kubectl get nodes -o json |
	jq -r '.items[] | [.metadata.name, ([.status.conditions[] | select(.type == "Ready")][0].status)] | @tsv' |
	while IFS=$'\t' read -r name ready; do
		case "${name}" in
		"${CLUSTER}") where="the control plane, a Docker container on this laptop" ;;
		cloud-node) where="a KVM VM on this laptop, joined over the VPN" ;;
		"${GPU_VM}") where="a GCE VM with an NVIDIA T4, joined over the VPN" ;;
		*) where="a Docker container on this laptop" ;;
		esac
		if [[ "${ready}" == True ]]; then
			ok "${name}" "${where}"
		else
			fail "${name} is not Ready" "  ${where}"
		fi
	done

names="$(kubectl get nodes -o name)"
places="laptop"
grep -qx node/cloud-node <<<"${names}" && places+=" + local VM"
grep -qx "node/${GPU_VM}" <<<"${names}" && places+=" + cloud GPU"
note "One kube context, one dev loop: ${places}."
