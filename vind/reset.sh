#!/usr/bin/env bash
set +e

echo "=== Ensuring bridge kernel module ==="
sudo modprobe br_netfilter
sudo sysctl -q -w net.bridge.bridge-nf-call-iptables=1

echo "=== Setting docker driver ==="
vcluster use driver docker

echo "=== Deleting all vclusters ==="
for vc in $(vcluster list --output name 2>/dev/null); do
  vcluster delete "$vc" 2>/dev/null || true
done

echo "=== Stopping platform ==="
echo "delete" | vcluster platform destroy 2>/dev/null || true

echo "=== Cleaning up docker containers ==="
docker rm -f $(docker ps -aq --filter "name=vcluster") 2>/dev/null || true

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
for i in $(seq 1 15); do
  VM_IP=$(sudo virsh domifaddr cloud-node 2>/dev/null | awk '/ipv4/ {print $4}' | cut -d/ -f1)
  if [ -n "$VM_IP" ]; then echo "VM ready at $VM_IP"; break; fi
  sleep 2
done

if [[ "${1:-}" == "--clean-gcp" ]]; then
  echo "=== Cleaning up GCE VM ==="
  if gcloud compute instances describe vind-node --project=eng-sandbox-02 --zone=us-central1-a &>/dev/null; then
    gcloud compute instances delete vind-node --project=eng-sandbox-02 --zone=us-central1-a --quiet
  else
    echo "No vind-node VM found"
  fi
fi

echo "=== Done ==="
docker ps --format "table {{.Names}}\t{{.Status}}"
