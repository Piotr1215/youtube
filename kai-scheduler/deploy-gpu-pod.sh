#!/usr/bin/env bash
set -euo pipefail

# Pin the host context so the haiku app can never land on another cluster
# (e.g. the homelab). Override with DEMO_CONTEXT if needed.
kubectl config use-context "${DEMO_CONTEXT:-kind-kai-demo}" >/dev/null 2>&1 || true

# Check prerequisites
if ! kubectl get secret openai-secret >/dev/null 2>&1; then
    echo "Missing openai-secret. Run: kubectl create secret generic openai-secret --from-literal=api-key=\$OPENAI_API_KEY" >&2
    exit 1
fi

if ! kubectl get runtimeclass nvidia >/dev/null 2>&1; then
    echo "Missing nvidia RuntimeClass. Run setup-cluster.sh first" >&2
    exit 1
fi

if ! kubectl get queues -n default >/dev/null 2>&1; then
    echo "KAI queues not configured. Run: kubectl apply -f queues.yaml" >&2
    exit 1
fi

# Check if KAI scheduler is running
if ! kubectl get pod -n kai-scheduler -l app.kubernetes.io/name=kai-scheduler --field-selector=status.phase=Running >/dev/null 2>&1; then
    echo "KAI scheduler not running" >&2
    kubectl get pod -n kai-scheduler
    exit 1
fi

# Delete existing pod if present and wait for deletion
kubectl delete pod gpu-pod --ignore-not-found=true --wait=true --timeout=10s

# Deploy the app
kubectl apply -f gpu-pod.yaml
kubectl apply -f gpu-service.yaml

# Wait for pod to be scheduled
echo "Waiting for pod to be scheduled..."
if ! kubectl wait --for=condition=PodScheduled pod/gpu-pod --timeout=30s; then
    echo "Pod failed to be scheduled within 30s" >&2
    kubectl describe pod gpu-pod | tail -20
    exit 1
fi

# Wait for pod to reach Running phase
echo "Waiting for pod to start running..."
if ! kubectl wait --for=jsonpath='{.status.phase}'=Running pod/gpu-pod --timeout=30s; then
    echo "Pod failed to reach Running phase within 30s" >&2
    PHASE=$(kubectl get pod gpu-pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")
    echo "Current phase: $PHASE" >&2
    if [ "$PHASE" = "Failed" ] || [ "$PHASE" = "Error" ]; then
        kubectl logs gpu-pod --tail=20 2>/dev/null || true
    fi
    kubectl describe pod gpu-pod | tail -20
    exit 1
fi

# Wait for pod to be ready (containers started and healthy)
echo "Waiting for pod to be ready..."
if ! kubectl wait --for=condition=Ready pod/gpu-pod --timeout=30s; then
    echo "Pod not ready within 30s" >&2
    kubectl logs gpu-pod --tail=20
    exit 1
fi

# The app is reachable on the host through the kind NodePort mapping
# (nvkind maps container 30500 -> host 5000). The public URL is published
# separately by the cloudflared slide, which dials this local port.
echo "Local: http://localhost:5000"