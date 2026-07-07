#!/usr/bin/env bash
# Install KAI as THE scheduler inside the kai-isolated tenant cluster.
# Verbose helm output goes to a log; the slide sees a clean checkmark. Leaves
# kubectl connected to the tenant cluster so the next slide (k9s) shows the KAI
# pods running inside it.
set -uo pipefail
KAI_VERSION="${KAI_VERSION:-v0.7.11}"

kubectl config use-context kind-kai-demo >/dev/null
vcluster connect kai-isolated --driver helm >/dev/null

echo "Installing KAI ${KAI_VERSION} into kai-isolated..."
helm upgrade -i kai-scheduler \
  oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler --create-namespace \
  --version "$KAI_VERSION" \
  --set "global.gpuSharing=true" \
  --wait >/tmp/kai-isolated.log 2>&1

kubectl wait --for=condition=ready pod -n kai-scheduler --all --timeout=120s >/dev/null 2>&1

printf '\e[32m✔ %s\e[0m\n' "KAI ${KAI_VERSION} running as the scheduler inside kai-isolated"
