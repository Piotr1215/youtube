#!/usr/bin/env bash
# Deploy two fractional-GPU workloads into the kai-isolated tenant cluster and
# show them sharing one physical GPU, placed by the tenant cluster's own KAI.
set -uo pipefail

kubectl config use-context kind-kai-demo >/dev/null
vcluster connect kai-isolated --driver helm >/dev/null

kubectl apply -f queues.yaml >/dev/null
kubectl apply -f gpu-demo-pod1.yaml >/dev/null
kubectl apply -f gpu-demo-pod2.yaml >/dev/null
kubectl wait --for=condition=ready pod -l app=gpu-demo --timeout=120s >/dev/null

echo
printf '\e[32m%s\e[0m\n' "✔ Two pods, one physical GPU, placed by KAI inside the tenant cluster:"
echo
kubectl get pods -l app=gpu-demo \
  -o custom-columns='NAME:.metadata.name,FRACTION:.metadata.annotations.kai\.scheduler/gpu-fraction,STATUS:.status.phase'
