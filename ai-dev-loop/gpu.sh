#!/usr/bin/env bash
# show the model in the T4's memory, read on the VM itself: GPU memory in use and
# what Ollama has loaded. It stays loaded because the Stack sets keep_alive to -1.
#
#   ./gpu.sh
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

cmd "nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv"
cmd "ollama ps"
if ! gcloud compute ssh "${GPU_VM}" "${GCE[@]}" \
	--command='nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv; ollama ps' 2>/dev/null | brief; then
	fail "the T4 did not answer" "  check the VM with ./create-gpu-vm.sh"
	exit 1
fi
