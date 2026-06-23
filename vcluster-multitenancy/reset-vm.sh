#!/usr/bin/env bash
# reset-vm.sh - remove the cloud-node demo VM (the KVM private node).
#
# Counterpart to create-cloud-vm.sh / setup.sh. Stops the VM, removes its
# libvirt definition, and deletes its disk image, so the next `bash setup.sh`
# rebuilds it from a clean cloud image. Leaves all vclusters untouched; use
# reset.sh for those.
#
# Usage:  bash reset-vm.sh
set -uo pipefail

IMG_DIR="/var/lib/libvirt/images"
VM_NAME="cloud-node"

echo "=== Destroying ${VM_NAME} (if running) ==="
sudo virsh destroy "$VM_NAME" 2>/dev/null || true

echo "=== Undefining ${VM_NAME} ==="
sudo virsh undefine "$VM_NAME" 2>/dev/null || true

echo "=== Removing disk image ==="
sudo rm -f "$IMG_DIR/$VM_NAME.qcow2"

echo "=== Done ==="
if sudo virsh list --all --name 2>/dev/null | grep -qx "$VM_NAME"; then
    echo "WARNING: ${VM_NAME} is still defined."
else
    echo "${VM_NAME} removed. Run 'bash setup.sh' to recreate it."
fi
