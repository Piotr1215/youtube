#!/usr/bin/env bash
# create the GCE T4 VM that joins ai-dev as the GPU node, wait until its
# startup script has Ollama serving Winnow, then say what is on it. Safe to rerun:
# an existing VM is kept.
#
#   ./create-gpu-vm.sh
set -eo pipefail

PROJECT="${PROJECT:-eng-sandbox-02}"
ZONE="${ZONE:-us-central1-a}"
VM="${GPU_VM:-vind-node}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

gc() { gcloud compute "$@" --project="$PROJECT" --zone="$ZONE"; }

if gc instances describe "$VM" >/dev/null 2>&1; then
	created="built before the talk"
else
	created="created now"
	gc instances create "$VM" \
		--machine-type=n1-standard-4 \
		--image-family=common-cu129-ubuntu-2404-nvidia-580 \
		--image-project=deeplearning-platform-release \
		--accelerator=type=nvidia-tesla-t4,count=1 \
		--maintenance-policy=TERMINATE \
		--boot-disk-size=100GB \
		--metadata-from-file startup-script="$SCRIPT_DIR/gce-startup.sh" >/dev/null
	until gc ssh "$VM" --command=true >/dev/null 2>&1; do sleep 5; done
	paint gray "  waiting for the startup script: the 7.4 GB model download takes minutes"
	until gc ssh "$VM" --command='test -f /var/lib/models-ready' >/dev/null 2>&1; do sleep 15; done
fi

# shellcheck disable=SC2016 # $3 and $4 belong to the remote awk
info="$(gc ssh "$VM" --command='nvidia-smi --query-gpu=name,memory.total --format=csv,noheader; ollama list | awk "/^winnow/ {print \$3, \$4}"; systemctl is-active kubelet || true' 2>/dev/null)"
ok "$VM" "a GCE VM in $ZONE, $created"
ok "GPU" "$(sed -n 1p <<<"$info")"
ok "model" "Winnow 12B, $(sed -n 2p <<<"$info"), served by Ollama"
if [[ "$(sed -n 3p <<<"$info")" == active ]]; then
	fail "kubelet already runs" "  a join from an earlier run: ./reset.sh undoes it"
else
	ok "kubelet" "none yet: the join adds it"
fi
