#\!/bin/bash
set -e

echo "Setting up NVIDIA Container Support in Kind..."

# Install required packages
docker exec kai-gpu-demo-control-plane apt-get update
docker exec kai-gpu-demo-control-plane apt-get install -y curl gnupg libc-bin pciutils psmisc apt-utils

# Add NVIDIA repository and install container toolkit
docker exec kai-gpu-demo-control-plane bash -c '
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed "s#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g" | \
        tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-container-toolkit
'

# Setup library paths and symlinks for driver version 565.77
docker exec kai-gpu-demo-control-plane bash -c '
    mkdir -p /usr/lib64 /usr/local/nvidia/lib64
    mkdir -p /usr/local/nvidia/bin
    mkdir -p /usr/lib/nvidia
    mkdir -p /usr/local/nvidia/toolkit
    
    # Create symlinks if needed (already mounted, but ensure they work)
    cd /usr/lib/x86_64-linux-gnu
    
    # Make binaries executable
    chmod +x /usr/bin/nvidia-* || true
    
    # Update library paths
    echo "/usr/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/nvidia.conf
    echo "/usr/lib64" >> /etc/ld.so.conf.d/nvidia.conf
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
    ldconfig
'

# Configure containerd for nvidia runtime
docker exec kai-gpu-demo-control-plane bash -c '
    nvidia-ctk runtime configure --runtime=containerd
    systemctl restart containerd
'

# Wait for containerd to restart
sleep 10

# Verify setup
docker exec kai-gpu-demo-control-plane bash -c '
    echo "=== Testing nvidia-smi ==="
    nvidia-smi || echo "nvidia-smi failed"
    echo "=== Checking NVIDIA libraries ==="
    ldconfig -p | grep -E "nvidia|cuda" | head -10
'

echo "NVIDIA setup complete"
