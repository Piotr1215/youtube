#!/usr/bin/env bash
set -eo pipefail
cd "$(dirname "$0")"

# Pave the road, locally and in ISOLATION. Same rig as the kai talk: a kind
# cluster, then a governed tenant cluster from the approved ai-tool-runtime
# values via the vcluster helm driver.
#
# Isolation matters: the demo pins its own kubeconfig so nothing here can ever
# touch another cluster (e.g. a homelab) that the ambient KUBECONFIG points at.
# Every demo script (connect, ship, guardrails, cleanup) pins the same file.
#
# Steps:
#   1. Point KUBECONFIG at a dedicated demo file.
#   2. Clean slate: drop any prior kind cluster.
#   3. Create the local kind cluster into the demo kubeconfig (control plane).
#   4. Create the team-docs tenant cluster from ai-tool-runtime.yaml. Creating
#      from the approved values injects the governance envelope as it comes up:
#      pod security (restricted), NetworkPolicy, ResourceQuota, LimitRange.

cluster="${CLUSTER:-paved-demo}"
tenant="${TENANT:-team-docs}"
template="${TEMPLATE:-ai-tool-runtime.yaml}"
export KUBECONFIG="${PAVED_KUBECONFIG:-${HOME}/.kube/paved-demo.config}"

# 1. Clean slate
if kind get clusters 2>/dev/null | grep -qx "${cluster}"; then
    kind delete cluster --name "${cluster}" --kubeconfig "${KUBECONFIG}"
fi

# 2. Local control plane cluster, written to the isolated demo kubeconfig.
#    kind sets this file's current-context to kind-<cluster>, so the create
#    below targets the kind cluster and nothing else.
kind create cluster --name "${cluster}" --config kind-config.yaml --kubeconfig "${KUBECONFIG}"

# 3. ingress-nginx on the kind (host) cluster. The tenant exposes the MCP
#    server through an Ingress (the sanctioned exit; the template's quota
#    forbids NodePort), and vcluster syncs that Ingress to the host namespace
#    where this controller serves it.
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
# Wait on the rollout, not a pod selector. A pod-selector wait races the
# Deployment and aborts with "no matching resources found" when the pod object
# is a beat behind. rollout status waits cleanly, and controller-ready implies
# the admission webhook cert is mounted, so ship.sh can apply the Ingress.
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=180s

# 4. Governed tenant cluster from the approved template (helm driver)
vcluster create "${tenant}" --values "${template}" --driver helm --connect=false

echo "isolated kubeconfig: ${KUBECONFIG}"
echo "kind/${cluster} + governed tenant cluster ${tenant} ready (from ${template})"
