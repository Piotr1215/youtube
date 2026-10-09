#!/bin/bash
# GCE startup script for the GPU node: NVIDIA runtime for containerd, Ollama on all
# interfaces, and the models classif uses, so the node is ready before the curl join.
# GCE runs it on every boot; each step is safe to repeat.
nvidia-ctk runtime configure --runtime=containerd --set-as-default
systemctl restart containerd
command -v ollama >/dev/null || curl -fsSL https://ollama.com/install.sh | sh
mkdir -p /etc/systemd/system/ollama.service.d
cat > /etc/systemd/system/ollama.service.d/override.conf << EOF
[Service]
Environment=OLLAMA_HOST=0.0.0.0
EOF
systemctl daemon-reload
systemctl enable --now ollama
systemctl restart ollama
until curl -sf http://localhost:11434/api/tags > /dev/null 2>&1; do sleep 1; done

# Winnow-12B, the model classif defaults to, created as the classif README describes.
cat > /tmp/Modelfile << 'MODEL'
FROM hf.co/Piotr1215/Winnow-12B-GGUF:Q4_K_M
TEMPLATE {{ .Prompt }}
RENDERER gemma4
PARSER gemma4
PARAMETER temperature 1
PARAMETER top_k 64
PARAMETER top_p 0.95
MODEL
export HOME=/root
ollama list | grep -q '^winnow:12b-q4_K_M' || ollama create winnow:12b-q4_K_M -f /tmp/Modelfile
ollama pull embeddinggemma
touch /var/lib/models-ready
