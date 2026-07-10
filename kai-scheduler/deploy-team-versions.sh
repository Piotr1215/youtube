#!/usr/bin/env bash
# Create two tenant clusters and install a different KAI version in each, in
# parallel. team-stable -> v0.7.11 (stable), team-beta -> v0.8.5 (newer). Prints a
# milestone as each step completes; verbose create/helm output goes to /tmp logs.
# Connects both tenants and returns to the control plane cluster context when done.
set -uo pipefail

STABLE_VERSION="v0.7.11"
BETA_VERSION="v0.8.5"

step() { printf '\n\e[1;36m▶ %s\e[0m\n' "$1"; }
ok()   { printf '  \e[32m✔ %s\e[0m\n' "$1"; }
fail() { printf '  \e[31m✗ %s\e[0m\n' "$1"; }

kubectl config use-context kind-kai-demo >/dev/null

step "Creating tenant clusters team-stable + team-beta"
vcluster create team-stable --values kai-vcluster.yaml --driver helm --connect=false >/tmp/create-team-stable.log 2>&1 &
sp=$!
vcluster create team-beta   --values kai-vcluster.yaml --driver helm --connect=false >/tmp/create-team-beta.log 2>&1 &
bp=$!
if wait "$sp"; then ok "team-stable cluster ready"; else fail "team-stable create failed (see /tmp/create-team-stable.log)"; fi
if wait "$bp"; then ok "team-beta cluster ready";   else fail "team-beta create failed (see /tmp/create-team-beta.log)"; fi

step "Connecting both tenants"
kubectl config use-context kind-kai-demo >/dev/null
vcluster connect team-stable --driver helm >/dev/null
STABLE_CTX=$(kubectl config current-context)
kubectl config use-context kind-kai-demo >/dev/null
vcluster connect team-beta --driver helm >/dev/null
BETA_CTX=$(kubectl config current-context)
kubectl config use-context kind-kai-demo >/dev/null
ok "both tenants connected"

step "Installing KAI ${STABLE_VERSION} -> team-stable and ${BETA_VERSION} -> team-beta"
helm upgrade -i kai-scheduler oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler --create-namespace --kube-context "$STABLE_CTX" \
  --version "$STABLE_VERSION" --set "global.gpuSharing=true" --wait >/tmp/kai-team-stable.log 2>&1 &
sp=$!
helm upgrade -i kai-scheduler oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler --create-namespace --kube-context "$BETA_CTX" \
  --version "$BETA_VERSION" --set "global.gpuSharing=true" --wait >/tmp/kai-team-beta.log 2>&1 &
bp=$!
if wait "$sp"; then ok "team-stable: KAI ${STABLE_VERSION} running"; else fail "team-stable KAI install failed (see /tmp/kai-team-stable.log)"; fi
if wait "$bp"; then ok "team-beta: KAI ${BETA_VERSION} running";     else fail "team-beta KAI install failed (see /tmp/kai-team-beta.log)"; fi

kubectl config use-context kind-kai-demo >/dev/null
echo
printf '\e[37m%s\e[0m\n' "Two versions, two tenant clusters, one control plane cluster. No shared scheduler."
