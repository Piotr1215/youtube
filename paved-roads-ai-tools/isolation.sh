#!/usr/bin/env bash
set -eo pipefail
cd "$(dirname "$0")"
export KUBECONFIG="${PAVED_KUBECONFIG:-${HOME}/.kube/paved-demo.config}"

# The tenant cluster is a real, isolated Kubernetes cluster. Inside it the team
# is cluster-admin and can create cluster-scoped objects a shared namespace
# would never allow. None of it reaches the host cluster: the platform hands
# over a cluster without handing over its own.

tenant="${TENANT:-team-docs}"
host_ctx="${HOST_CONTEXT:-kind-paved-demo}"

printf '\e[1;36m%s\e[0m\n' "Inside ${tenant}, the team is cluster-admin:"
vcluster connect "${tenant}" --driver helm -- sh -c '
  kubectl auth can-i create clusterroles >/dev/null 2>&1 && echo "  create ClusterRoles: allowed"
  kubectl auth can-i create customresourcedefinitions >/dev/null 2>&1 && echo "  create CRDs: allowed"
  kubectl delete namespace team-scratch --ignore-not-found >/dev/null 2>&1
  kubectl create namespace team-scratch >/dev/null 2>&1 && echo "  namespace team-scratch: created"
' 2>&1 | grep -E 'allowed|created'

printf '\n\e[1;36m%s\e[0m\n' "On the host cluster, none of it exists:"
# NotFound is the whole point, and it exits non-zero, so do not let it abort.
kubectl --context "${host_ctx}" get namespace team-scratch 2>&1 | sed 's/^/  /' || true

printf '\n\e[33m%s\e[0m\n' "The team owns a cluster. The platform did not give away the cluster."
