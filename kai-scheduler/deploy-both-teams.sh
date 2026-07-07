#!/usr/bin/env bash
# Deploy the same fractional-GPU workloads into BOTH tenant clusters. Each set is
# placed by that tenant cluster's own KAI version, with no shared scheduler.
# Returns to the control plane cluster context when done.
set -uo pipefail

for team in team-stable team-beta; do
  kubectl config use-context kind-kai-demo >/dev/null
  vcluster connect "$team" --driver helm >/dev/null
  kubectl apply -f queues.yaml >/dev/null
  kubectl apply -f gpu-demo-pod1.yaml >/dev/null
  kubectl apply -f gpu-demo-pod2.yaml >/dev/null
  printf '\e[32m✔ deployed to %s\e[0m\n' "$team"
done

kubectl config use-context kind-kai-demo >/dev/null
