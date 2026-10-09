#!/usr/bin/env bash
# show the classif Stack's tasks from the vCluster Platform, each with
# what it is doing in plain words. --watch prints the rows again whenever they
# change, until the Stack is Healthy.
#
#   ./stack-status.sh [--watch]
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

STACK="${STACK:-classif}"
mgmt="$(mktemp)"
trap 'rm -f "${mgmt}"' EXIT
vcluster platform connect management --print >"${mgmt}" 2>/dev/null

# Print "stack PHASE", then "TASK PHASE" for each task of the Stack.
phases() {
	kubectl --kubeconfig "${mgmt}" get stackinstance -A \
		-l "platform.vcluster.com/stack-config-name=${STACK}" -o json |
		jq -r '.items[0] // empty | "stack \(.status.phase // "Pending")", (.status.tasks[]? | "\(.name) \(.phase)")'
}

# Print what a task is doing, in plain words.
# $1: task name, $2: phase
meaning() {
	case "$1:$2" in
	model:Healthy)
		local ip
		ip="$(kubectl get svc ollama -n classif -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)"
		echo "Winnow runs on the T4, behind LoadBalancer ${ip} on this laptop"
		;;
	model:Failed | model:Degraded) echo "deploy failed; the Stack retries it" ;;
	model:*)
		if kubectl get node "${GPU_VM}" >/dev/null 2>&1; then
			echo "loading Winnow into the T4's memory"
		else
			echo "waiting for ${GPU_VM}, the GPU node, to join"
		fi
		;;
	check:Healthy) echo "a test question got an answer from the model" ;;
	check:Progressing) echo "asks the model a test question" ;;
	check:Failed | check:Degraded) echo "the test question got no answer; the Stack retries it" ;;
	check:*) echo "starts once model is healthy" ;;
	*) echo "$2" ;;
	esac
}

# Print one row per "name phase" line on stdin.
rows() {
	local name phase color mark
	while read -r name phase; do
		case "${phase}" in
		Healthy) color=green mark='✓' ;;
		Failed | Degraded) color=red mark='✗' ;;
		Progressing) color=yellow mark='▶' ;;
		*) color=gray mark='·' ;;
		esac
		if [[ "${name}" == stack ]]; then
			paint 'bold cyan' "  Stack ${STACK}: " "${color}" "${phase}"
		else
			paint "${color}" "  ${mark}  " cyan "$(printf '%-8s' "${name}")" plain "$(meaning "${name}" "${phase}")"
		fi
	done
}

if [[ -z "$(phases)" ]]; then
	fail "no ${STACK} Stack yet" "  Is ${CLUSTER} running? Run ./create-cluster.sh first."
	exit 1
fi

if [[ "${1:-}" != --watch ]]; then
	phases | rows
	exit 0
fi

last=''
while :; do
	now="$(phases | rows)"
	if [[ "${now}" != "${last}" ]]; then
		paint gray "  $(date +%T)"
		printf '%s\n' "${now}"
		last="${now}"
	fi
	phases | head -1 | grep -qx 'stack Healthy' && break
	sleep 3
done
