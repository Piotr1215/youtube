#!/usr/bin/env bash
set -euo pipefail

# Preload container images for faster demo

echo "Preloading images for KAI scheduler demo..."

# List of images to preload
IMAGES=(
    "nvidia/cuda:12.2.0-base-ubuntu20.04"
    "ubuntu:latest"
    "piotrzan/nginx-demo:green"
    "busybox:1.28"
    "ghcr.io/loft-sh/vcluster:latest"
    "piotrzan/sre-haiku-generator:latest"
)

# Pull images locally
for image in "${IMAGES[@]}"; do
    echo "Pulling $image..."
    docker pull "$image"
done

# Check if cluster exists
if kind get clusters | grep -q kai-demo; then
    echo "Loading images into kind cluster 'kai-demo'..."
    for image in "${IMAGES[@]}"; do
        echo "  - Loading $image..."
        kind load docker-image "$image" --name kai-demo
    done
    echo "Images preloaded successfully!"
else
    echo "WARNING: Cluster 'kai-demo' not found. Run this after creating the cluster."
fi