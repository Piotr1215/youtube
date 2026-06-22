#!/usr/bin/env bash
set -eo pipefail

# Create a KVM VM for vcluster private node demo

IMG_DIR="/var/lib/libvirt/images"
VM_NAME="cloud-node"
CLOUD_IMG="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"

# Serialize runs: two concurrent invocations racing on the same qcow2 corrupt a live disk
exec 9>"/tmp/create-cloud-vm-${VM_NAME}.lock"
if ! flock -n 9; then
    echo "Another create-cloud-vm.sh run is in progress for ${VM_NAME}. Aborting." >&2
    exit 1
fi

# Download cloud image if not present
if [[ ! -f "$IMG_DIR/jammy-server-cloudimg-amd64.img" ]]; then
    echo "Downloading Ubuntu cloud image..."
    sudo wget -q --show-progress -O "$IMG_DIR/jammy-server-cloudimg-amd64.img" "$CLOUD_IMG"
fi

# Create cloud-init config
SSH_KEY=$(cat ~/.ssh/id_ed25519.pub 2>/dev/null || cat ~/.ssh/id_rsa.pub 2>/dev/null)
sudo tee "$IMG_DIR/cloud-init.yaml" > /dev/null << EOF
#cloud-config
hostname: cloud-node
disable_root: false
users:
  - name: root
    ssh_authorized_keys:
      - $SSH_KEY
EOF

# Delete existing VM FIRST so its disk file is not held open by a running qemu.
# Overwriting a live qcow2 (cp/resize below) corrupts the guest filesystem.
sudo virsh destroy "$VM_NAME" 2>/dev/null || true
sudo virsh undefine "$VM_NAME" 2>/dev/null || true

# Copy and resize image
sudo cp "$IMG_DIR/jammy-server-cloudimg-amd64.img" "$IMG_DIR/$VM_NAME.qcow2"
sudo qemu-img resize "$IMG_DIR/$VM_NAME.qcow2" 10G

# Create VM
sudo virt-install \
  --name "$VM_NAME" \
  --ram 2048 \
  --vcpus 2 \
  --disk "path=$IMG_DIR/$VM_NAME.qcow2,format=qcow2" \
  --os-variant ubuntu22.04 \
  --network network=default \
  --graphics none \
  --import \
  --cloud-init "user-data=$IMG_DIR/cloud-init.yaml" \
  --noautoconsole

echo "VM created. Get IP with: virsh domifaddr $VM_NAME"
echo "SSH with: ssh $USER@\$(virsh domifaddr $VM_NAME | awk '/ipv4/ {print \$4}' | cut -d/ -f1)"
