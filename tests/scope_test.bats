#!/usr/bin/env bats
# templates/scope.sh keeps `just reset` and `just down` inside one deck: fake docker
# and kubectl list a mix of decks, and every mutation is checked against the log.

setup() {
	BIN="${BATS_TEST_TMPDIR}/bin"
	LOG="${BATS_TEST_TMPDIR}/log"
	mkdir -p "${BIN}"
	cat >"${BIN}/docker" <<'EOF'
#!/usr/bin/env bash
printf 'docker %s\n' "$*" >>"${LOG}"
case "$1 $*" in
ps*status=running*) printf '%s\n' ${RUNNING:-} ;;
ps*status=exited*) printf '%s\n' ${EXITED:-} ;;
ps*) printf '%s\n' ${RUNNING:-} ${EXITED:-} ;;
network*) printf '%s\n' ${NETWORKS:-} ;;
inspect*) [[ "$*" == *State.Running* ]] && echo "${PLATFORM_RUNNING:-true}" || echo "${PLATFORM_STATUS:-running}" ;;
esac
EOF
	cat >"${BIN}/kubectl" <<'EOF'
#!/usr/bin/env bash
[[ "$*" == "config current-context" ]] && echo "${CONTEXT:-}"
EOF
	chmod +x "${BIN}/docker" "${BIN}/kubectl"
	export PATH="${BIN}:${PATH}" LOG
	source "${BATS_TEST_DIRNAME}/../templates/scope.sh"
	SCOPE_CLUSTERS=(ai-dev)
	SCOPE_KUBECONFIG="${BATS_TEST_TMPDIR}/deck.config"
}

# Fail when the deck would own NAME. A bare `!` line never fails a bats test.
not_owned() {
	if scope_owns "$1"; then
		echo "owned: $1"
		return 1
	fi
}

@test "owns only the deck's cluster containers and network, by exact name" {
	scope_owns vcluster.cp.ai-dev
	scope_owns vcluster.node.ai-dev.worker-1
	scope_owns vcluster.lb.ai-dev.svc
	scope_owns vcluster.ai-dev
	not_owned vcluster.cp.platform-host
	not_owned vcluster.cp.ai-dev-2
	not_owned vcluster.node.ai-dev-2.worker-1
	not_owned vcluster-platform
	not_owned kind-registry
}

@test "lists only the deck's containers and networks" {
	RUNNING="vcluster.cp.ai-dev vcluster.cp.platform-host vcluster.node.ai-dev.worker-1 vcluster-platform" \
		run scope_containers running
	[ "${output}" = $'vcluster.cp.ai-dev\nvcluster.node.ai-dev.worker-1' ]
	NETWORKS="vcluster.ai-dev vcluster.platform-host bridge" run scope_networks
	[ "${output}" = vcluster.ai-dev ]
}

@test "refuses a foreign name before anything runs" {
	run scope_check vcluster.cp.ai-dev vcluster.cp.platform-host
	[ "${status}" -eq 1 ]
	[[ "${output}" == *"refusing vcluster.cp.platform-host"* ]]
	run scope_cluster platform-host
	[ "${status}" -eq 1 ]
	scope_cluster ai-dev
}

@test "refuses another kubeconfig or another cluster's context" {
	KUBECONFIG="${HOME}/.kube/config" CONTEXT=vcluster-docker_ai-dev run scope_context
	[ "${status}" -eq 1 ]
	KUBECONFIG="${SCOPE_KUBECONFIG}" CONTEXT=vcluster-docker_platform-host run scope_context
	[ "${status}" -eq 1 ]
	KUBECONFIG="${SCOPE_KUBECONFIG}" CONTEXT=vcluster-platform_management run scope_context
	[ "${status}" -eq 1 ]
	KUBECONFIG="${SCOPE_KUBECONFIG}" CONTEXT=vcluster-docker_ai-dev scope_context
}

@test "stop touches only the deck's running containers" {
	RUNNING="vcluster.cp.ai-dev vcluster.node.ai-dev.worker-1 vcluster.cp.platform-host vcluster-platform kind-registry" \
		scope_stop
	grep -qx 'docker stop vcluster.cp.ai-dev vcluster.node.ai-dev.worker-1' "${LOG}"
	[ "$(grep -c '^docker stop' "${LOG}")" -eq 1 ]
}

@test "the shared Platform stays up while another deck's cluster runs" {
	RUNNING="vcluster.cp.ai-dev vcluster.cp.platform-host vcluster-platform" run scope_stop_platform
	[ "${status}" -eq 1 ]
	[ "$(grep -c 'docker stop' "${LOG}")" -eq 0 ]
}

@test "the shared Platform stops when only the deck's cluster used it" {
	RUNNING="vcluster.cp.ai-dev vcluster-platform kind-registry" scope_stop_platform
	grep -qx 'docker stop vcluster-platform' "${LOG}"
}

@test "start wakes only the deck's containers and the Platform" {
	EXITED="vcluster.cp.ai-dev vcluster.cp.platform-host nomad_redis" PLATFORM_STATUS=exited scope_start
	grep -qx 'docker start vcluster-platform' "${LOG}"
	grep -qx 'docker start vcluster.cp.ai-dev' "${LOG}"
	[ "$(grep -c '^docker start' "${LOG}")" -eq 2 ]
}

@test "starts control planes before nodes before load balancers, whatever docker lists first" {
	EXITED="vcluster.lb.ai-dev.svc vcluster.node.ai-dev.worker-2 vcluster.node.ai-dev.worker-1 vcluster.cp.ai-dev" \
		PLATFORM_STATUS=running scope_start
	grep -qx 'docker start vcluster.cp.ai-dev vcluster.node.ai-dev.worker-1 vcluster.node.ai-dev.worker-2 vcluster.lb.ai-dev.svc' "${LOG}"
}
