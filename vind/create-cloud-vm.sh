#!/usr/bin/env bash
set -eo pipefail

# Create a KVM VM for vcluster private node demo

IMG_DIR="/var/lib/libvirt/images"
VM_NAME="cloud-node"
CLOUD_IMG="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"

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
users:
  - name: $USER
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - $SSH_KEY
EOF

# Copy and resize image
sudo cp "$IMG_DIR/jammy-server-cloudimg-amd64.img" "$IMG_DIR/$VM_NAME.qcow2"
sudo qemu-img resize "$IMG_DIR/$VM_NAME.qcow2" 10G

# Delete existing VM if present
sudo virsh destroy "$VM_NAME" 2>/dev/null || true
sudo virsh undefine "$VM_NAME" 2>/dev/null || true

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
