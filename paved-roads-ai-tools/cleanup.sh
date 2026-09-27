#!/usr/bin/env bash
set -eo pipefail
cd "$(dirname "$0")"
export KUBECONFIG="${PAVED_KUBECONFIG:-${HOME}/.kube/paved-demo.config}"

# Tear down the demo. The tenant cluster runs inside kind, so deleting the kind
# cluster takes the tool and its whole governed envelope with it. Then drop the
# demo kubeconfig. The named cloudflared tunnel + DNS persist in Cloudflare;
# only the local connector stops.

cluster="${CLUSTER:-paved-demo}"

pkill -x cloudflared 2>/dev/null || true
kind delete cluster --name "${cluster}" --kubeconfig "${KUBECONFIG}" 2>/dev/null || true
rm -f "${KUBECONFIG}"
echo "deleted kind/${cluster} and removed ${KUBECONFIG}"
