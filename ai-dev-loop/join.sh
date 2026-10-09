#!/usr/bin/env bash
# copy a join command for ai-dev, then open a root shell on the
# machine that joins, where the presenter pastes it. vm is the KVM VM on this
# laptop; gpu is the GCE T4 VM.
#
#   ./join.sh vm|gpu
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

target="${1:?usage: ./join.sh vm|gpu}"
case "${target}" in
vm) node=cloud-node ;;
gpu) node="${GPU_VM}" ;;
*)
	fail "unknown target ${target}" "use vm or gpu"
	exit 1
	;;
esac

# A rerun after the join changes nothing: the join script refuses a running kubelet.
if [[ "$(kubectl get node "${node}" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)" == True ]]; then
	ok "${node}" "already joined to ${CLUSTER} and Ready, kept"
	exit 0
fi

cmd "vcluster token create --expires=1h"
join="$(vcluster token create --expires=1h 2>/dev/null)" || {
	fail "no join command" "Is ${CLUSTER} running? Run ./create-cluster.sh first."
	exit 1
}
shown='curl -fsSLk "https://<platform>/…/join?token=…" | sh -'
# GCE hostnames are FQDNs; the Stack pins its model pod to the node named vind-node.
if [[ "${target}" == gpu ]]; then
	join+="s -- --node-name ${GPU_VM}"
	shown+="s -- --node-name ${GPU_VM}"
fi
printf "%s" "${join}" | xclip -selection clipboard >/dev/null 2>&1
ok "join command" "copied to the clipboard, valid for one hour"
paint gray "    ${shown}"
paint
paint yellow "  Paste it in the root shell that opens next, then exit when it says joined."
paint

case "${target}" in
vm)
	ip="$(sudo virsh domifaddr cloud-node | awk '/ipv4/ {print $4}' | cut -d/ -f1)"
	# reset.sh rebuilds this VM, so its host key changes every run.
	exec ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "root@${ip}"
	;;
gpu)
	exec gcloud compute ssh "${GPU_VM}" "${GCE[@]}" -- -t sudo -i
	;;
esac
