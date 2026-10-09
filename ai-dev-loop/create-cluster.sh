#!/usr/bin/env bash
# create ai-dev in Docker from vcluster.yaml, then say in plain words what
# now runs where. The Platform that serves the UI, join tokens and Stacks is started
# and activated before the talk; a rerun keeps an existing cluster.
#
#   ./create-cluster.sh
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

vcluster use driver docker >/dev/null 2>&1
vcluster platform start >/dev/null 2>&1
platform="$(jq -r '.platform.host // empty' ~/.vcluster/config.json | sed -E 's#^https?://##')"

cmd "vcluster create ${CLUSTER} --values vcluster.yaml"
start="$(date +%s)"
if docker ps --format '{{.Names}}' | grep -qx "vcluster.cp.${CLUSTER}"; then
	ok "${CLUSTER}" "already exists, kept"
elif docker ps -a --format '{{.Names}}' | grep -qx "vcluster.cp.${CLUSTER}"; then
	# Left paused by an interrupted sleep-wake.sh.
	vcluster resume "${CLUSTER}" >/dev/null 2>&1
	kubectl wait --for=condition=Ready node --all --timeout=180s >/dev/null
	ok "${CLUSTER}" "was paused, resumed in $(($(date +%s) - start)) seconds"
else
	log="$(mktemp)"
	if ! vcluster create "${CLUSTER}" --values vcluster.yaml >"${log}" 2>&1; then
		fail "vcluster create failed" "$(tail -5 "${log}")"
		exit 1
	fi
	kubectl wait --for=condition=Ready node --all --timeout=180s >/dev/null
	ok "${CLUSTER}" "ready in $(($(date +%s) - start)) seconds"
fi

ok "control plane" "a Docker container on this laptop"
for node in $(docker ps --format '{{.Names}}' | sed -n "s/^vcluster\.node\.${CLUSTER}\.//p"); do
	ok "${node}" "a worker node, also a Docker container"
done
ok "Platform UI" "https://${platform}"
note "One file declared all of it, and the kube context now points at ${CLUSTER}."
