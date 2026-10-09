#!/usr/bin/env bash
# Return the demo to a clean start: no vclusters, a fresh KVM node, and a GPU VM
# with its join undone but its driver and model kept. The Platform stays up,
# because a new one starts unactivated and blocks every vcluster create until
# someone activates it in the UI.
# --clean-platform also destroys the Platform.
# --clean-gcp also deletes the GCE T4 VM, which stops its billing; recreating it
# with create-gpu-vm.sh re-downloads the 7.4 GB model.
#
#   ./reset.sh [--clean-platform] [--clean-gcp]
set +e

cd "$(dirname "$0")" || exit 1
source ./common.sh

echo "=== Ensuring bridge kernel module ==="
sudo modprobe br_netfilter
sudo sysctl -q -w net.bridge.bridge-nf-call-iptables=1

echo "=== Setting docker driver ==="
vcluster use driver docker

echo "=== Stopping the audience page ==="
"$(dirname "$0")/audience.sh" stop

echo "=== Undoing the GPU VM's join ==="
# A second join refuses while the first kubelet runs. The join script's own
# --reset-only uninstalls what it installed, and it needs a token, so this runs
# before the cluster is deleted. It leaves vcluster-vpn running with the deleted
# cluster's key in memory, and a later join rewrites its config without restarting
# it, so stop it too.
join="$(vcluster token create --expires=10m 2>/dev/null)"
if [[ -n "${join}" ]] && gcloud compute ssh "${GPU_VM}" "${GCE[@]}" --command='systemctl is-active -q kubelet' 2>/dev/null; then
  gcloud compute ssh "${GPU_VM}" "${GCE[@]}" --command="sudo sh -c '${join}s -- --reset-only' && sudo systemctl disable --now vcluster-vpn && sudo rm -f /etc/vcluster-vpn/config.json" 2>&1 | tail -3
elif gcloud compute ssh "${GPU_VM}" "${GCE[@]}" --command='systemctl is-active -q kubelet' 2>/dev/null; then
  # The cluster is gone, so no token for --reset-only: stop what makes the next
  # join refuse or hang; that join resets the rest before it installs.
  gcloud compute ssh "${GPU_VM}" "${GCE[@]}" --command="sudo systemctl disable --now kubelet vcluster-vpn && sudo rm -f /etc/vcluster-vpn/config.json" 2>&1 | tail -3
else
  echo "no join to undo"
fi

echo "=== Deleting all vclusters ==="
for vc in $(vcluster list --output name 2>/dev/null); do
  vcluster delete "$vc" 2>/dev/null || true
done

if [[ " $* " == *" --clean-platform "* ]]; then
  echo "=== Stopping platform ==="
  echo "delete" | vcluster platform destroy 2>/dev/null || true
fi

# common.sh pins the demo scripts to this kubeconfig.
rm -f "${VIND_KUBECONFIG:-${HOME}/.kube/vind-demo.config}"

echo "=== Cleaning up docker containers ==="
docker ps -aq --filter "name=^vcluster\." | xargs -r docker rm -f >/dev/null 2>&1 || true

echo "=== Cleaning up docker networks ==="
for net in $(docker network ls --format '{{.Name}}' | grep '^vcluster\.' 2>/dev/null); do
  docker network rm "$net" 2>/dev/null || true
done

echo "=== Recreating KVM VM ==="
sudo virsh destroy cloud-node 2>/dev/null || true
sudo virsh undefine cloud-node 2>/dev/null || true
sudo rm -f /var/lib/libvirt/images/cloud-node.qcow2
sudo qemu-img create -b /var/lib/libvirt/images/jammy-server-cloudimg-amd64.img \
  -F qcow2 -f qcow2 /var/lib/libvirt/images/cloud-node.qcow2 20G
sudo virt-install \
  --name cloud-node \
  --memory 2048 \
  --vcpus 2 \
  --disk /var/lib/libvirt/images/cloud-node.qcow2 \
  --os-variant ubuntu22.04 \
  --cloud-init user-data=/var/lib/libvirt/images/cloud-init.yaml \
  --network network=default \
  --noautoconsole \
  --import
sudo virsh start cloud-node 2>/dev/null || true
echo "Waiting for VM to boot..."
for _ in $(seq 1 15); do
  VM_IP=$(sudo virsh domifaddr cloud-node 2>/dev/null | awk '/ipv4/ {print $4}' | cut -d/ -f1)
  if [ -n "$VM_IP" ]; then echo "VM ready at $VM_IP"; break; fi
  sleep 2
done

if [[ " $* " == *" --clean-gcp "* ]]; then
  echo "=== Cleaning up GCE VM ==="
  if gcloud compute instances describe vind-node --project=eng-sandbox-02 --zone=us-central1-a &>/dev/null; then
    gcloud compute instances delete vind-node --project=eng-sandbox-02 --zone=us-central1-a --quiet
  else
    echo "No vind-node VM found"
  fi
fi

echo "=== Done ==="
docker ps --format "table {{.Names}}\t{{.Status}}"
