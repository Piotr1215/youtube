#!/usr/bin/env bash
set -euo pipefail

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

# Delete existing pod if present
kubectl delete pod gpu-pod --ignore-not-found=true --wait=false

# Deploy the app
kubectl apply -f gpu-pod.yaml
kubectl apply -f gpu-service.yaml

# Wait for pod to be scheduled
echo "Waiting for pod to be scheduled..."
TIMEOUT=30
COUNT=0
while [ $COUNT -lt $TIMEOUT ]; do
    PHASE=$(kubectl get pod gpu-pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
    if [ "$PHASE" = "Running" ] || [ "$PHASE" = "Succeeded" ]; then
        break
    elif [ "$PHASE" = "Failed" ] || [ "$PHASE" = "Error" ]; then
        echo "Pod failed to start" >&2
        kubectl describe pod gpu-pod | tail -20
        exit 1
    elif [ "$PHASE" = "Pending" ]; then
        # Check if it's stuck pending
        if [ $COUNT -gt 10 ]; then
            REASON=$(kubectl get pod gpu-pod -o jsonpath='{.status.conditions[?(@.type=="PodScheduled")].reason}' 2>/dev/null || echo "")
            if [ -n "$REASON" ]; then
                echo "Pod stuck pending: $REASON" >&2
                kubectl describe pod gpu-pod | tail -20
                exit 1
            fi
        fi
    fi
    COUNT=$((COUNT + 1))
    sleep 1
done

if [ $COUNT -eq $TIMEOUT ]; then
    echo "Timeout waiting for pod to start" >&2
    kubectl get pod gpu-pod -o yaml | grep -A 10 status:
    exit 1
fi

# Wait for pod to be ready
if ! kubectl wait --for=condition=ready pod gpu-pod --timeout=30s; then
    echo "Pod not ready" >&2
    kubectl logs gpu-pod --tail=20
    exit 1
fi

# Kill any existing ngrok
pkill -f "ngrok http 5000" 2>/dev/null || true

# Start ngrok in background
ngrok http 5000 --log-level=error &
NGROK_PID=$!

# Circuit breaker for ngrok API
MAX_ATTEMPTS=50
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    # Check if ngrok process is still running
    if ! kill -0 $NGROK_PID 2>/dev/null; then
        echo "ngrok process died" >&2
        exit 1
    fi

    # Try to get tunnel info
    if RESPONSE=$(curl -s --max-time 1 http://localhost:4040/api/tunnels 2>/dev/null); then
        if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.tunnels[0].public_url' >/dev/null 2>&1; then
            export NGROK_URL=$(echo "$RESPONSE" | jq -r '.tunnels[0].public_url')
            break
        fi
    fi

    ATTEMPT=$((ATTEMPT + 1))
    sleep 0.2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "Timeout waiting for ngrok API" >&2
    kill $NGROK_PID 2>/dev/null || true
    exit 1
fi

# Display URLs
echo "Local:  http://localhost:5000"
echo "Public: $NGROK_URL"