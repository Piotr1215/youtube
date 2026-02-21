#!/usr/bin/env bash
echo "deploying to production"
kubectl apply -f manifests/
echo "deploy complete"
