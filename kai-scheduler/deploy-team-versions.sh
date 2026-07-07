#!/usr/bin/env bash
# Create two tenant clusters and install a different KAI version in each, in
# parallel. team-stable -> v0.7.11 (stable), team-beta -> v0.8.5 (newer). Prints a
# milestone as each step completes, plus a heartbeat during the slow parallel
# create + helm installs, so the audience sees steady progress. Verbose output
# goes to /tmp logs. Connects both tenants (so they appear in the k9s :ctx menu)
# and returns to the control plane cluster context when done.
set -uo pipefail

STABLE_VERSION="v0.7.11"
BETA_VERSION="v0.8.5"

step() { printf '\n\e[1;36m▶ %s\e[0m\n' "$1"; }
ok()   { printf '  \e[32m✔ %s\e[0m\n' "$1"; }
fail() { printf '  \e[31m✗ %s\e[0m\n' "$1"; }
# Periodic "still working" line so a long parallel wait never looks frozen.
heartbeat() { local label="$1" i=0; while :; do sleep 10; i=$((i+10)); printf '    \e[90m… %s (%ds)\e[0m\n' "$label" "$i"; done; }

kubectl config use-context kind-kai-demo >/dev/null

step "Creating tenant clusters team-stable + team-beta (parallel)"
vcluster create team-stable --values kai-vcluster.yaml --driver helm --connect=false >/tmp/create-team-stable.log 2>&1 &
sp=$!
vcluster create team-beta   --values kai-vcluster.yaml --driver helm --connect=false >/tmp/create-team-beta.log 2>&1 &
bp=$!
heartbeat "provisioning both control planes" & hb=$!
if wait "$sp"; then ok "team-stable cluster ready"; else fail "team-stable create failed (see /tmp/create-team-stable.log)"; fi
if wait "$bp"; then ok "team-beta cluster ready";   else fail "team-beta create failed (see /tmp/create-team-beta.log)"; fi
kill "$hb" 2>/dev/null; wait "$hb" 2>/dev/null || true

step "Connecting both tenants (adds them to the k9s :ctx menu)"
kubectl config use-context kind-kai-demo >/dev/null
vcluster connect team-stable --driver helm >/dev/null
STABLE_CTX=$(kubectl config current-context)
kubectl config use-context kind-kai-demo >/dev/null
vcluster connect team-beta --driver helm >/dev/null
BETA_CTX=$(kubectl config current-context)
kubectl config use-context kind-kai-demo >/dev/null
ok "team-stable and team-beta selectable in k9s"

step "Installing KAI ${STABLE_VERSION} -> team-stable and ${BETA_VERSION} -> team-beta (parallel)"
helm upgrade -i kai-scheduler oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler --create-namespace --kube-context "$STABLE_CTX" \
  --version "$STABLE_VERSION" --set "global.gpuSharing=true" --wait >/tmp/kai-team-stable.log 2>&1 &
sp=$!
helm upgrade -i kai-scheduler oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler --create-namespace --kube-context "$BETA_CTX" \
  --version "$BETA_VERSION" --set "global.gpuSharing=true" --wait >/tmp/kai-team-beta.log 2>&1 &
bp=$!
heartbeat "installing KAI into both tenants" & hb=$!
if wait "$sp"; then ok "team-stable: KAI ${STABLE_VERSION} running"; else fail "team-stable KAI install failed (see /tmp/kai-team-stable.log)"; fi
if wait "$bp"; then ok "team-beta: KAI ${BETA_VERSION} running";     else fail "team-beta KAI install failed (see /tmp/kai-team-beta.log)"; fi
kill "$hb" 2>/dev/null; wait "$hb" 2>/dev/null || true

kubectl config use-context kind-kai-demo >/dev/null
echo
printf '\e[37m%s\e[0m\n' "Two versions, two tenant clusters, one control plane cluster. No shared scheduler."
