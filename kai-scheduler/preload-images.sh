#!/usr/bin/env bash
set -euo pipefail

# Preload container images so demo pods start instantly.
#
# Docker here uses the containerd image store (io.containerd.snapshotter.v1).
# With that store `kind load docker-image` fails on multi-arch images: it runs
# `ctr import --all-platforms`, which needs blobs for every platform in the
# manifest index, but `docker pull` only fetches the host platform ("content
# digest ... not found"). Instead we pull straight into each kind node's own
# containerd (k8s.io namespace) with crictl, which kubelet reads directly.

echo "Preloading images for KAI scheduler demo..."

# `vcluster create` deploys an image whose tag matches the installed CLI version
# (e.g. vcluster-pro:0.35.1), NOT :latest. Preloading the wrong tag left the real
# image to pull on demand, which was the main cause of the long tenant-cluster
# create. Derive the exact tag from the CLI so it stays correct across upgrades.
VCLUSTER_VERSION="$(vcluster --version 2>/dev/null | awk '{print $NF}')"
VCLUSTER_IMAGE="ghcr.io/loft-sh/vcluster-pro:${VCLUSTER_VERSION:-0.35.1}"

# List of images to preload
IMAGES=(
    "nvidia/cuda:12.2.0-base-ubuntu20.04"
    "ubuntu:latest"
    "piotrzan/nginx-demo:green"
    "busybox:1.28"
    "${VCLUSTER_IMAGE}"
    "piotrzan/sre-haiku-generator:latest"
)

# team-beta installs a SECOND KAI version (see deploy-team-versions.sh). Its image
# tags differ from the host/v0.7.11 set that setup-cluster.sh already caches, so
# preload them too. Otherwise the "Different KAI Versions Per Team" slide pulls ~9
# images live under `helm --wait` and can time out. Keep in sync with that script.
KAI_BETA_VERSION="v0.8.5"
for c in scheduler binder podgrouper podgroupcontroller queuecontroller \
         admission resourcereservation webhookmanager crd-upgrader; do
    IMAGES+=("ghcr.io/nvidia/kai-scheduler/${c}:${KAI_BETA_VERSION}")
done

# Preloading is an optimization; a flaky registry pull must never abort setup.
if ! kind get clusters | grep -q kai-demo; then
    echo "WARNING: Cluster 'kai-demo' not found. Run this after creating the cluster."
    exit 0
fi

# Demo workloads only ever land on the GPU worker: the control-plane node is
# tainted NoSchedule, so preloading it is wasted work. Target worker(s) only,
# and fall back to every node if the naming ever changes.
mapfile -t NODES < <(kind get nodes --name kai-demo | grep -- '-worker' || kind get nodes --name kai-demo)

for node in "${NODES[@]}"; do
    echo "Loading ${#IMAGES[@]} images into node '${node}' (parallel)..."
    for image in "${IMAGES[@]}"; do
        # Each pull is independent, so fan them out and join with wait. The
        # subshell swallows failures into a warning so set -e never trips.
        (
            if docker exec "${node}" crictl pull "${image}" >/dev/null 2>&1; then
                echo "  ok    ${image}"
            else
                echo "  WARN  ${image} (will pull on demand)"
            fi
        ) &
    done
    wait
done

echo "Images preloaded."
