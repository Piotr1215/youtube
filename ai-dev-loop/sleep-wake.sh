#!/usr/bin/env bash
# pause ai-dev like a laptop going to sleep, resume it, then ask classif
# again to show the GPU endpoint came back without any change.
#
#   ./sleep-wake.sh
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

cmd "vcluster pause ${CLUSTER}"
# Already paused by an interrupted run is fine: resume follows.
vcluster pause "${CLUSTER}" >/dev/null 2>&1 || true
running="$(docker ps --format '{{.Names}}' | grep -c "^vcluster\.[a-z]*\.${CLUSTER}" || true)"
ok "laptop" "${CLUSTER}'s containers stopped, ${running} still running"
ok "${GPU_VM}" "untouched: the cloud VM keeps running"

paint
cmd "vcluster resume ${CLUSTER}"
start="$(date +%s)"
vcluster resume "${CLUSTER}" >/dev/null 2>&1
answer="$(./ask "Is this about Kubernetes?" "The pod keeps crashlooping." || true)"
ok "${CLUSTER}" "back in $(($(date +%s) - start)) seconds"
if [[ -n "${answer}" ]]; then
	ok "classif" "answers through the T4 again: ${answer}"
else
	fail "classif got no answer" "  the LoadBalancer may need a few more seconds"
fi
