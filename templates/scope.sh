# shellcheck shell=bash
# Sourced by a deck's reset.sh and down.sh, so `just reset` and `just down` act only
# on the infrastructure that deck owns. The deck declares its own names before
# sourcing; every check below compares exact names, and a target outside them
# stops the script before any command runs on it.
#
#   SCOPE_CLUSTERS=(ai-dev)                      vCluster Docker-driver clusters
#   SCOPE_KUBECONFIG="${HOME}/.kube/vind-demo.config"  the kubeconfig the deck pins
#
# The local Platform (container vcluster-platform) is shared by every deck. A deck
# may start it; it stops it only when no other deck's cluster is running.

SCOPE_PLATFORM=vcluster-platform

# Stop with the reason, before anything outside the deck is touched.
# $@: what was refused
scope_refuse() {
	printf 'scope: refusing %s\n' "$*" >&2
	exit 1
}

# Succeed when NAME is a container or network of one of the deck's clusters:
# vcluster.cp.C, vcluster.node.C.*, vcluster.lb.C.* or the network vcluster.C.
# $1: name
scope_owns() {
	local c
	for c in "${SCOPE_CLUSTERS[@]}"; do
		case "$1" in
		"vcluster.cp.${c}" | "vcluster.${c}" | "vcluster.node.${c}."* | "vcluster.lb.${c}."*) return 0 ;;
		esac
	done
	return 1
}

# Refuse unless every name is the deck's.
# $@: container or network names
scope_check() {
	local name
	for name in "$@"; do
		scope_owns "${name}" || scope_refuse "${name}: not one of ${SCOPE_CLUSTERS[*]}"
	done
}

# Refuse unless NAME is one of the deck's clusters.
# $1: cluster name
scope_cluster() {
	local c
	for c in "${SCOPE_CLUSTERS[@]}"; do
		[[ "$1" == "${c}" ]] && return 0
	done
	scope_refuse "cluster ${1:-<empty>}: not one of ${SCOPE_CLUSTERS[*]}"
}

# Print the deck's containers, optionally only those in one Docker status, control
# planes first, then nodes, then load balancers. Docker gives a started container the
# lowest free address on its network and a node registers its address once, so
# starting a node before its control plane swaps their addresses, and kubectl exec
# and logs then reach the wrong kubelet. Starting in this order, the creation order,
# gives each the address it registered.
# $1: status (running, exited), or empty for all
scope_containers() {
	local name role
	local -a names filter=()
	[[ -z "${1:-}" ]] || filter=(--filter "status=$1")
	mapfile -t names < <(docker ps -a "${filter[@]}" --format '{{.Names}}' | sort)
	for role in cp node lb; do
		for name in "${names[@]}"; do
			[[ "${name}" == "vcluster.${role}."* ]] && scope_owns "${name}" && printf '%s\n' "${name}"
		done
	done
	return 0
}

# Print the deck's Docker networks.
scope_networks() {
	local name
	while read -r name; do
		[[ -n "${name}" ]] && scope_owns "${name}" && printf '%s\n' "${name}"
	done < <(docker network ls --format '{{.Name}}')
	return 0
}

# Refuse unless kubectl would use the deck's kubeconfig and one of its clusters'
# contexts, vcluster-docker_C.
scope_context() {
	local context c
	[[ -n "${SCOPE_KUBECONFIG:-}" && "${KUBECONFIG:-}" == "${SCOPE_KUBECONFIG}" ]] ||
		scope_refuse "KUBECONFIG ${KUBECONFIG:-<unset>}: the deck pins ${SCOPE_KUBECONFIG:-<none>}"
	context="$(kubectl config current-context 2>/dev/null || true)"
	for c in "${SCOPE_CLUSTERS[@]}"; do
		[[ "${context}" == "vcluster-docker_${c}" ]] && return 0
	done
	scope_refuse "kube context ${context:-<none>}: not one of the deck's clusters"
}

# Succeed when no other deck's cluster is running, so the shared Platform may stop.
scope_platform_idle() {
	local name
	while read -r name; do
		[[ "${name}" == vcluster.cp.* ]] && ! scope_owns "${name}" && return 1
	done < <(docker ps --filter status=running --format '{{.Names}}')
	return 0
}

# Stop the deck's running containers. Nothing is removed.
scope_stop() {
	local -a running
	mapfile -t running < <(scope_containers running)
	((${#running[@]})) || return 0
	scope_check "${running[@]}"
	docker stop "${running[@]}" >/dev/null
}

# Stop the shared Platform unless another deck's cluster still runs on it.
# Fails, stopping nothing, when one does.
scope_stop_platform() {
	scope_platform_idle || return 1
	if [[ "$(docker inspect -f '{{.State.Running}}' "${SCOPE_PLATFORM}" 2>/dev/null)" == true ]]; then
		docker stop "${SCOPE_PLATFORM}" >/dev/null
	fi
}

# Start the deck's stopped containers and the shared Platform if it is stopped.
scope_start() {
	local -a stopped
	mapfile -t stopped < <(scope_containers exited)
	if [[ "$(docker inspect -f '{{.State.Status}}' "${SCOPE_PLATFORM}" 2>/dev/null)" == exited ]]; then
		docker start "${SCOPE_PLATFORM}" >/dev/null
	fi
	((${#stopped[@]})) || return 0
	scope_check "${stopped[@]}"
	docker start "${stopped[@]}" >/dev/null
}
