#!/usr/bin/env bash
# show the model in the T4's memory, read on the VM itself: GPU memory in use and
# what Ollama has loaded. It stays loaded because the Stack sets keep_alive to -1.
#
#   ./gpu.sh
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

# One connection for both commands, split below so each output sits under its command.
if ! out="$(gcloud compute ssh "${GPU_VM}" "${GCE[@]}" \
	--command='nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv,noheader,nounits; ollama ps' 2>/dev/null)"; then
	fail "the T4 did not answer" "  check the VM with ./create-gpu-vm.sh"
	exit 1
fi

cmd "nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv"
# nvidia-smi reports MiB. The columns follow ollama ps below it.
awk -F', ' 'NR == 1 {
	printf "%-12s%-10s%s\n", "NAME", "USED", "TOTAL"
	printf "%-12s%-10s%s\n", $1, sprintf("%.1f GB", $2 / 1024), sprintf("%.1f GB", $3 / 1024)
}' <<<"${out}" | brief
paint
cmd "ollama ps"
sed 1d <<<"${out}" | brief
