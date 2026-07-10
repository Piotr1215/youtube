#!/usr/bin/env bash
# Reset the DEMO artifacts you create live during the talk -- GPU pods, the exposed
# service, the published tunnel, and the tenant vclusters -- while leaving the whole
# base setup (kind cluster, host KAI Scheduler, device plugin, queues, GPU config,
# image cache) intact. Lets you re-run the demo from a clean slate WITHOUT setup-cluster.sh.
set -uo pipefail

CLUSTER=kai-demo

kubectl config use-context "kind-${CLUSTER}" >/dev/null 2>&1 || {
  echo "kind-${CLUSTER} context not found -- is the cluster up?"; exit 1; }

echo "Resetting demo artifacts (base cluster, KAI, GPU and cache are left intact)..."

# 1. Stop the published tunnel (expose-app.sh / "Publish the App" slide).
if pkill -f cloudflared 2>/dev/null; then echo "  stopped cloudflared tunnel"; else echo "  cloudflared not running"; fi

# 2. Remove the GPU demo workloads (deploy-gpu-pod.sh and the gpu-demo pods). Deleted
#    by the demo's own names/labels so nothing in the base setup is touched.
kubectl delete pod gpu-pod gpu-demo-pod1 gpu-demo-pod2 test-gpu-pod test-gpu-simple \
  --ignore-not-found --wait=false 2>/dev/null || true
kubectl delete pod -l app=sre-haiku --ignore-not-found --wait=false 2>/dev/null || true
kubectl delete service gpu-service --ignore-not-found 2>/dev/null || true
echo "  removed GPU demo pods + service"

# 3. Delete tenant vclusters (they run as pods inside kind via the helm driver).
mapfile -t vclusters < <(vcluster list --output json 2>/dev/null | jq -r '.[] | (.Name // .name)' 2>/dev/null)
if [ "${#vclusters[@]}" -eq 0 ]; then
  vclusters=(kai-isolated team-stable team-beta)
fi
for vc in "${vclusters[@]}"; do
  [ -z "${vc}" ] && continue
  echo "+ vcluster delete ${vc} --delete-namespace --driver helm"
  vcluster delete "${vc}" --delete-namespace --driver helm 2>/dev/null \
    || echo "  (skipped ${vc}: not present)"
done

# 4. Prune the per-tenant kubeconfig contexts `vcluster connect` left behind.
kubectl config use-context "kind-${CLUSTER}" >/dev/null 2>&1
pruned=0
for entry in $(kubectl config get-contexts -o name 2>/dev/null | grep -E "^vcluster_.*_kind-${CLUSTER}$"); do
  kubectl config delete-context "$entry" >/dev/null 2>&1 || true
  kubectl config delete-cluster "$entry" >/dev/null 2>&1 || true
  kubectl config unset "users.${entry}" >/dev/null 2>&1 || true
  pruned=$((pruned + 1))
done
echo "  pruned ${pruned} stale tenant context(s)"

echo "Demo reset complete. Rebuild with ./deploy-gpu-pod.sh, ./deploy-team-versions.sh, etc."
