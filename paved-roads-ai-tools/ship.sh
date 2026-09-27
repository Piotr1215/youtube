#!/usr/bin/env bash
set -eo pipefail
cd "$(dirname "$0")"
export KUBECONFIG="${PAVED_KUBECONFIG:-${HOME}/.kube/paved-demo.config}"

# Ship the team's tool into the governed tenant cluster. Pins the demo
# kubeconfig so this can only ever target the local kind rig, never the
# ambient cluster the shell's KUBECONFIG might point at.

tenant="${TENANT:-team-docs}"
exec vcluster connect "${tenant}" --driver helm -- \
    kubectl apply -f vcluster-yaml-mcp/
