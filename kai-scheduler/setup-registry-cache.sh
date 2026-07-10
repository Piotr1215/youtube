#!/usr/bin/env bash
# Aggressively pre-cache every image the KAI demo pulls into a PERSISTENT local
# registry, so a fresh nvkind/kind cluster pulls from localhost instead of over
# (weak) wifi. The registry is backed by a host-mounted docker volume, so it
# survives `kind delete` / `cleanup.sh`: the download happens once, then every
# `setup-cluster.sh` run is fast and works even with no connectivity.
#
# How it plugs in: nvkind-config.yaml points the node containerd at this registry
# as a mirror for docker.io / ghcr.io / nvcr.io / registry.k8s.io, with the real
# upstream as a fallback endpoint. Warm images are served locally; anything not
# cached still falls back to the internet.
#
# Usage:
#   ./setup-registry-cache.sh              ensure the registry is up AND warm every image
#   ./setup-registry-cache.sh --ensure-only  only start the registry (used by setup-cluster.sh)
#
# Safe to re-run: images already cached are skipped, and one image failing only
# warns (falls back to upstream at run time) instead of aborting the rest.
set -uo pipefail
cd "$(dirname "$0")"

REGISTRY_NAME="kind-registry"
REGISTRY_PORT="5001"                      # host side (warming/debug); nodes use kind-registry:5000 on the kind net
REGISTRY_HOST="localhost:${REGISTRY_PORT}"
ENSURE_ONLY=0
[ "${1:-}" = "--ensure-only" ] && ENSURE_ONLY=1

# ---- 1. Ensure the persistent registry is up and attached to the kind network ----
if [ -z "$(docker ps -aq -f name="^${REGISTRY_NAME}$")" ]; then
  echo "Creating persistent registry ${REGISTRY_NAME} (volume: kind-registry-data)..."
  docker run -d --restart=always --name "${REGISTRY_NAME}" \
    -p "127.0.0.1:${REGISTRY_PORT}:5000" \
    -v kind-registry-data:/var/lib/registry \
    registry:2 >/dev/null
else
  docker start "${REGISTRY_NAME}" >/dev/null 2>&1 || true
fi
# Nodes resolve the cache as kind-registry:5000 once it is on the kind network.
if docker network inspect kind >/dev/null 2>&1; then
  docker network connect kind "${REGISTRY_NAME}" 2>/dev/null || true
fi

if [ "${ENSURE_ONLY}" -eq 1 ]; then
  echo "Registry ${REGISTRY_NAME} ready at ${REGISTRY_HOST}."
  exit 0
fi

command -v crane >/dev/null || { echo "ERROR: crane not found (go install github.com/google/go-containerregistry/cmd/crane@latest)"; exit 1; }

# ---- 2. The full image set the demo pulls, with EXPLICIT registry host so the
#         path we push to matches what containerd asks the mirror for. ----
KAI_STABLE="v0.7.11"        # host cluster + team-stable
KAI_BETA="v0.8.5"           # team-beta (deploy-team-versions.sh)
DEVICE_PLUGIN="v0.17.4"
METRICS_SERVER="v0.8.1"     # keep in sync with setup-cluster.sh
VCLUSTER_VERSION="$(vcluster --version 2>/dev/null | awk '{print $NF}')"
VCLUSTER_VERSION="${VCLUSTER_VERSION:-0.35.1}"

images=()
# KAI components exist per-version; caching a tag that a version doesn't publish
# just warns and is skipped. Keep the component list in sync with preload-images.sh.
for c in scheduler binder podgrouper podgroupcontroller queuecontroller \
         webhookmanager crd-upgrader admission resourcereservation; do
  images+=("ghcr.io/nvidia/kai-scheduler/${c}:${KAI_STABLE}")
  images+=("ghcr.io/nvidia/kai-scheduler/${c}:${KAI_BETA}")
done
images+=(
  "nvcr.io/nvidia/k8s-device-plugin:${DEVICE_PLUGIN}"
  "registry.k8s.io/metrics-server/metrics-server:${METRICS_SERVER}"
  "ghcr.io/loft-sh/vcluster-pro:${VCLUSTER_VERSION}"
  # vcluster tenant control-plane images. loft-sh/kubernetes is the big one that
  # otherwise stalls the first "create tenant" slide. Tag tied to vcluster 0.35.x.
  "ghcr.io/loft-sh/kubernetes:v1.36.0"
  "registry.k8s.io/coredns/coredns:v1.11.1"
  # The tenant vcluster's own DNS runs docker.io/coredns/coredns at a DIFFERENT tag
  # than the host's v1.11.1. Without it cached, the first `vcluster create` in the
  # demo stalls pulling coredns live. Same repo path, second tag: both coexist.
  "docker.io/coredns/coredns:1.14.2"
  "docker.io/library/ubuntu:latest"
  "docker.io/library/busybox:1.28"
  "docker.io/nvidia/cuda:12.2.0-base-ubuntu20.04"
  "docker.io/piotrzan/nginx-demo:green"
  "docker.io/piotrzan/sre-haiku-generator:latest"
)

# ---- 3. Warm each image (skip if already cached) ----
# Prefer copying from the local docker daemon when the image is already there
# (zero network); otherwise pull a single linux/amd64 image from upstream once.
ok=0; skip=0; fail=0
for src in "${images[@]}"; do
  path="${src#*/}"                        # strip registry host -> repo[:tag]
  dst="${REGISTRY_HOST}/${path}"
  if crane digest --insecure "${dst}" >/dev/null 2>&1; then
    printf '  skip   %s\n' "${src}"; skip=$((skip+1)); continue
  fi
  if docker image inspect "${src}" >/dev/null 2>&1; then
    if docker tag "${src}" "${dst}" 2>/dev/null && docker push "${dst}" >/dev/null 2>&1; then
      printf '  local  %s\n' "${src}"; ok=$((ok+1)); continue
    fi
  fi
  tmp="$(mktemp)"
  if crane pull --platform=linux/amd64 --insecure "${src}" "${tmp}" >/dev/null 2>&1 \
     && crane push --insecure "${tmp}" "${dst}" >/dev/null 2>&1; then
    printf '  pull   %s\n' "${src}"; ok=$((ok+1))
  else
    printf '  WARN   %s  (not cached; will fall back to upstream at run time)\n' "${src}"; fail=$((fail+1))
  fi
  rm -f "${tmp}"
done

echo ""
echo "Cache summary: ${ok} cached, ${skip} already present, ${fail} skipped."
echo "Registry ${REGISTRY_HOST} (volume kind-registry-data, survives kind delete)."
