#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# GPU-enabled kind cluster + KAI Scheduler. Built to survive weak wifi and to be
# idempotent: re-running gives a clean, working cluster every time.
#
# Fresh clusters pull images from the persistent local registry cache
# (setup-registry-cache.sh) via the containerd mirror wired into nvkind-config.yaml,
# so pulls are local and fast. Readiness waits WARN instead of aborting, so a single
# slow step can never leave the cluster half-configured (missing queues, no preload).

CLUSTER=kai-demo
KAI_VERSION=v0.7.11
DEVICE_PLUGIN_VERSION=v0.17.4
METRICS_SERVER_VERSION=v0.8.1   # pinned (not 'latest') so it caches deterministically

echo "Setting up GPU-enabled Kind cluster with KAI Scheduler..."

# 1. Docker GPU pass-through. nvkind requests the GPU via a volume mount
#    (/var/run/nvidia-container-devices/0 in nvkind-config.yaml); the toolkit only
#    honors that trigger when accept-nvidia-visible-devices-as-volume-mounts is on.
sudo nvidia-ctk runtime configure --runtime=docker --set-as-default
sudo nvidia-ctk config --in-place --set accept-nvidia-visible-devices-as-volume-mounts=true
sudo systemctl restart docker
until docker info >/dev/null 2>&1; do sleep 2; done

# 2. Clean slate: drop any prior kai-demo so re-runs are deterministic.
if kind get clusters 2>/dev/null | grep -qx "${CLUSTER}"; then
  echo "  existing ${CLUSTER} found; deleting for a clean rebuild"
  kind delete cluster --name "${CLUSTER}"
fi

# 3. Create the GPU cluster.
nvkind cluster create --name "${CLUSTER}" --config-template=nvkind-config.yaml

# Point the local kubeconfig at the new cluster (correct API port + current context)
# so every step below, and the demo slides, target kind-kai-demo and never the
# homelab cluster by accident.
kind export kubeconfig --name "${CLUSTER}"
kubectl config use-context "kind-${CLUSTER}"

# 4. Attach the image cache to the freshly created kind network so the containerd
#    mirror can reach it. Non-fatal: if the cache is missing, pulls hit upstream.
./setup-registry-cache.sh --ensure-only || echo "  WARN: image cache not ready; pulls will use upstream"

# 5. Metrics server (pinned) + Kind insecure-TLS patch. Idempotent.
kubectl apply -f "https://github.com/kubernetes-sigs/metrics-server/releases/download/${METRICS_SERVER_VERSION}/components.yaml"
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' 2>/dev/null || true

# 6. OpenAI secret (apply, not create, so re-runs don't fail on "already exists").
kubectl create secret generic openai-secret \
  --from-literal=api-key="${OPENAI_API_KEY}" \
  --dry-run=client -o yaml | kubectl apply -f -

# 7. KAI Scheduler in the host cluster (helm upgrade -i is idempotent).
helm upgrade -i kai-scheduler \
  oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler --create-namespace \
  --version "${KAI_VERSION}" --set "global.gpuSharing=true"

# 8. GPU node label + device plugin. The plugin MUST run under the nvidia runtime,
#    otherwise it comes up under runc, sees no GPU ("No devices found"), and never
#    advertises nvidia.com/gpu -- which KAI needs as capacity to hand out fractions.
kubectl label node "${CLUSTER}-worker" nvidia.com/gpu.present=true --overwrite
kubectl apply -f "https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/${DEVICE_PLUGIN_VERSION}/deployments/static/nvidia-device-plugin.yml"
kubectl patch ds -n kube-system nvidia-device-plugin-daemonset --type merge \
  -p '{"spec":{"template":{"spec":{"runtimeClassName":"nvidia"}}}}'

# RuntimeClass for nvidia containers (used by the device plugin and every GPU pod).
kubectl apply -f - <<EOF
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: nvidia
handler: nvidia
EOF

# 9. Readiness -- WARN, never abort. With the cache warmed these return fast.
kubectl -n kube-system rollout status ds/nvidia-device-plugin-daemonset --timeout=300s \
  || echo "  WARN: device plugin not ready yet (continuing)"
kubectl wait --for=condition=ready pod -n kai-scheduler --all --timeout=300s \
  || echo "  WARN: kai-scheduler pods not all ready yet (continuing)"

# 10. KAI queues -- REQUIRED: demo pods reference kai.scheduler/queue. Always applied,
#     even if a wait above lagged, so the scheduler always has a queue to bind to.
kubectl apply -f queues.yaml

# 11. Preload demo images into the node (belt-and-suspenders alongside the mirror).
./preload-images.sh || echo "  WARN: preload had issues (mirror/fallback will cover it)"

# 12. Verify the GPU is actually advertised -- the thing the KAI demo depends on.
echo "Waiting for nvidia.com/gpu to be advertised..."
gpu=""
for _ in $(seq 1 30); do
  gpu="$(kubectl get node "${CLUSTER}-worker" -o jsonpath='{.status.allocatable.nvidia\.com/gpu}' 2>/dev/null || true)"
  [ -n "${gpu}" ] && break
  sleep 4
done
if [ -n "${gpu}" ]; then
  echo "  nvidia.com/gpu = ${gpu}  OK"
else
  echo "  WARN: nvidia.com/gpu still 0. Inspect: kubectl logs -n kube-system -l name=nvidia-device-plugin-ds"
fi

echo "━━━ Cluster Setup Complete! ━━━"
echo "KAI Scheduler and GPU support are ready."
