#!/usr/bin/env bash
set -euo pipefail

# Deploy the app
kubectl apply -f gpu-pod.yaml
kubectl apply -f gpu-service.yaml

# Wait for pod to be ready
kubectl wait --for=condition=ready pod gpu-pod --timeout=60s

# Start ngrok
ngrok http 5000 --log-level=error > /tmp/ngrok.log 2>&1 &
sleep 3

# Show URLs
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
echo "Local:  http://localhost:5000"
echo "Public: $NGROK_URL"