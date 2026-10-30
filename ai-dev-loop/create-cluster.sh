#!/usr/bin/env bash
# create ai-dev in Docker from vcluster.yaml, then say in plain words what
# now runs where. platform.sh starts the Platform and logs the CLI in first; a rerun
# keeps an existing cluster.
#
#   ./create-cluster.sh
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

vcluster use driver docker >/dev/null 2>&1
if ! vcluster platform get current-user >/dev/null 2>&1; then
	fail "the CLI is not logged in to the Platform" "  Run ./platform.sh first."
	exit 1
fi
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
	if ! vcluster create "${CLUSTER}" --values vcluster.yaml 2>&1 | tee "${log}" | brief; then
		fail "vcluster create failed" "$(tail -5 "${log}")"
		exit 1
	fi
	cmd "kubectl wait --for=condition=Ready node --all"
	kubectl wait --for=condition=Ready node --all --timeout=180s >/dev/null
	ok "${CLUSTER}" "ready in $(($(date +%s) - start)) seconds"
fi

ok "control plane" "a Docker container on this laptop"
for node in $(docker ps --format '{{.Names}}' | sed -n "s/^vcluster\.node\.${CLUSTER}\.//p"); do
	ok "${node}" "a worker node, also a Docker container"
done
ok "Platform UI" "https://${platform}"
note "vcluster.yaml defines this cluster; the kube context now points at ${CLUSTER}."
