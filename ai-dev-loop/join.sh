#!/usr/bin/env bash
# copy a join command for ai-dev, then open a root shell on the
# machine that joins, where the presenter pastes it. vm is the KVM VM on this
# laptop; gpu is the GCE T4 VM.
#
#   ./join.sh vm|gpu [--print]
#
# --print is the fallback when the clipboard fails: it prints the whole join command
# to paste by hand, and stops.
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

target="${1:?usage: ./join.sh vm|gpu}"
case "${target}" in
vm) node=cloud-node ;;
gpu) node="${GPU_NODE}" ;;
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
# GCE hostnames are FQDNs; the Stack pins its model pod to the gpuNode in vcluster.yaml.
# --force-join clears any earlier join, so a leftover config cannot stop this step.
if [[ "${target}" == gpu ]]; then
	join+="s -- --node-name ${GPU_NODE} --force-join"
	shown+="s -- --node-name ${GPU_NODE} --force-join"
fi
if [[ "${2:-}" == --print ]]; then
	printf '%s\n' "${join}"
	exit 0
fi
if printf "%s" "${join}" | xclip -selection clipboard >/dev/null 2>&1; then
	ok "join command" "copied to the clipboard, valid for one hour"
else
	fail "clipboard failed" "  the join command is still on the VM"
fi
paint gray "    ${shown}"
paint
paint yellow "  Paste it in the root shell that opens next, then exit when it says joined."
[[ "${target}" == gpu ]] && paint gray "  If the paste fails, run this there: sh /root/join-cmd"
paint

case "${target}" in
vm)
	ip="$(sudo virsh domifaddr cloud-node | awk '/ipv4/ {print $4}' | cut -d/ -f1)"
	# reset.sh rebuilds this VM, so its host key changes every run.
	shell=(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "root@${ip}")
	;;
gpu)
	# A paste can fail on stage, so the command also waits on the VM as a file.
	# vcluster-vpn holds its key in memory, and the join rewrites its config but only
	# runs enable --now, which leaves a running daemon alone. A daemon left from an
	# earlier cluster keeps the deleted key and the join hangs waiting for the tunnel,
	# so stop it here and the join starts it with the new key.
	shell=(gcloud compute ssh "${GPU_VM}" "${GCE[@]}" -- -t "sudo systemctl stop vcluster-vpn 2>/dev/null; printf '%s\n' '${join}' | sudo tee /root/join-cmd >/dev/null; sudo -i")
	;;
esac

# The shell's exit code is its last command's, and presenterm calls any non-zero
# code an error, so a typo before exit is not a failure. 255 is ssh's own failure.
code=0
"${shell[@]}" || code=$?
[[ "${code}" -ne 255 ]]
