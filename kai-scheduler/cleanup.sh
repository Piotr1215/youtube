#!/usr/bin/env bash
# Reset the KAI demo environment to a clean state.
# Safe to run repeatedly; every step is best-effort so one failure never blocks
# the rest of the teardown.
set -uo pipefail

echo "Cleaning up KAI demo environment..."

# Stop the cloudflared tunnel (started on the "Publish the App" slide).
if pkill -f cloudflared 2>/dev/null; then
    echo "  stopped cloudflared tunnel"
else
    echo "  cloudflared not running"
fi

# Delete the Kind cluster. Because the kai-isolated / team-* vclusters run as pods
# INSIDE kind (helm driver), this removes them and every demo workload in one shot.
if kind get clusters 2>/dev/null | grep -qx kai-demo; then
    kind delete cluster --name kai-demo
else
    echo "  kind cluster 'kai-demo' not present"
fi

# vcluster connect wrote a kubeconfig context/cluster/user per tenant. Deleting the
# kind cluster orphans them, so they pile up in the k9s ':ctx' menu across runs.
# Prune every vcluster_* entry tied to kai-demo; other clusters are left untouched.
pruned=0
for entry in $(kubectl config get-contexts -o name 2>/dev/null | grep -E '^vcluster_.*_kind-kai-demo$'); do
    kubectl config delete-context "$entry" >/dev/null 2>&1 || true
    kubectl config delete-cluster "$entry" >/dev/null 2>&1 || true
    kubectl config unset "users.${entry}" >/dev/null 2>&1 || true
    pruned=$((pruned + 1))
done
echo "  pruned ${pruned} stale vcluster kubeconfig context(s)"

# Revert the Docker default runtime back to runc (setup-cluster.sh set it to nvidia).
if [ -f /etc/docker/daemon.json ] && grep -q '"default-runtime"' /etc/docker/daemon.json; then
    sudo jq 'del(."default-runtime")' /etc/docker/daemon.json | sudo sponge /etc/docker/daemon.json
    sudo systemctl restart docker
    echo "  reverted docker default-runtime"
else
    echo "  docker default-runtime already clean"
fi

# Note: the global vcluster driver stays 'docker' (this demo pins --driver helm
# per command), so the multitenancy demo is unaffected. Nothing to restore.

echo "Cleanup complete."
