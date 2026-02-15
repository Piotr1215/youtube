#!/bin/bash
nvidia-ctk runtime configure --runtime=containerd --set-as-default
systemctl restart containerd
curl -fsSL https://ollama.com/install.sh | sh
mkdir -p /etc/systemd/system/ollama.service.d
cat > /etc/systemd/system/ollama.service.d/override.conf << EOF
[Service]
Environment=OLLAMA_HOST=0.0.0.0
EOF
systemctl daemon-reload
systemctl enable --now ollama
until curl -sf http://localhost:11434/api/tags > /dev/null 2>&1; do sleep 1; done
ollama pull llama3.2:1b
