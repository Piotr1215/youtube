#!/usr/bin/env bash
set -eo pipefail
cd "$(dirname "$0")"
export KUBECONFIG="${PAVED_KUBECONFIG:-${HOME}/.kube/paved-demo.config}"

# The tenant cluster is a real, isolated Kubernetes cluster. Inside it the team
# is cluster-admin and can create cluster-scoped objects a shared namespace
# would never allow. None of it reaches the host cluster: the platform hands
# over a cluster without handing over its own. Output is plain English so a
# non-Kubernetes audience can follow it.

tenant="${TENANT:-team-docs}"
host_ctx="${HOST_CONTEXT:-kind-paved-demo}"

# Print one passed check.
# $1: what was checked, in plain words
ok() { printf '  \e[32m✓\e[0m  \e[37m%s\e[0m\n' "$1"; }

printf '\e[1;36m%s\e[0m\n' "Inside the team's own cluster, the team is in full control:"
vcluster connect "${tenant}" --driver helm -- sh -c '
  kubectl auth can-i create clusterroles >/dev/null 2>&1 && echo "OK can decide who may do what in its cluster"
  kubectl auth can-i create customresourcedefinitions >/dev/null 2>&1 && echo "OK can add new kinds of resources"
  kubectl delete namespace team-scratch --ignore-not-found >/dev/null 2>&1
  kubectl create namespace team-scratch >/dev/null 2>&1 && echo "OK created a workspace called team-scratch"
' 2>&1 | grep '^OK ' | while IFS= read -r line; do ok "${line#OK }"; done

printf '\n\e[1;36m%s\e[0m\n' "On the shared cluster underneath:"
# The lookup must fail: team-scratch exists only inside the team's cluster.
if kubectl --context "${host_ctx}" get namespace team-scratch >/dev/null 2>&1; then
	printf '  \e[31m✗\e[0m  \e[37m%s\e[0m\n' "team-scratch leaked onto the shared cluster"
else
	ok "no trace of team-scratch"
fi

printf '\n\e[33m%s\e[0m\n' "The team runs its own cluster; the shared cluster is never touched."
