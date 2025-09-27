#!/usr/bin/env bash
set -euo pipefail

echo "Setting up GPU-enabled Kind cluster with KAI Scheduler..."

# Configure Docker for GPU pass-through
sudo nvidia-ctk runtime configure --runtime=docker --set-as-default
sudo systemctl restart docker

# Wait for Docker to be ready
until docker info >/dev/null 2>&1; do
  sleep 2
done

# Create cluster with GPU support (port 5000 exposed for demo app)
nvkind cluster create --name kai-demo --config-template=nvkind-config.yaml

# Install metrics server with Kind-specific configuration
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# Patch metrics server for Kind (needs insecure TLS)
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# Create secret for OpenAI API (from environment variable)
kubectl create secret generic openai-secret --from-literal=api-key=$OPENAI_API_KEY

# Deploy KAI Scheduler in host cluster (for initial demo)
KAI_VERSION=v0.7.11
helm upgrade -i kai-scheduler \
  oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler --create-namespace \
  --version $KAI_VERSION \
  --set "global.gpuSharing=true"

# Label worker node for GPU workloads
kubectl label node kai-demo-worker nvidia.com/gpu.present=true --overwrite

# Install NVIDIA device plugin
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.16.2/deployments/static/nvidia-device-plugin.yml

# Create RuntimeClass for NVIDIA containers (in host cluster for vCluster sync)
kubectl apply -f - <<EOF
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: nvidia
handler: nvidia
EOF

# Wait for device plugin
kubectl wait --for=condition=ready pod -n kube-system \
  -l name=nvidia-device-plugin-ds --timeout=60s

# Wait for KAI scheduler to be ready
kubectl wait --for=condition=ready pod -n kai-scheduler --all --timeout=120s

# Apply KAI queues configuration
kubectl apply -f queues.yaml

# Preload images into kind cluster for faster demo
./preload-images.sh

echo "━━━ Cluster Setup Complete! ━━━"
echo "KAI Scheduler and GPU support are ready."
