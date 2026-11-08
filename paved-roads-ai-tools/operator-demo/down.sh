#!/usr/bin/env bash
# Stop what up.sh started. --wipe also deletes the demo state, so the next up
# starts empty again.
set -eo pipefail
source "$(dirname "$0")/env.sh"
for name in adapter process nats; do
	pidf="${DEMO_STATE}/${name}.pid"
	if [[ -s "${pidf}" ]]; then kill -- "-$(<"${pidf}")" 2>/dev/null || true; fi
	rm -f "${pidf}"
done
[[ "${1:-}" == --wipe ]] && rm -rf "${DEMO_STATE}"
echo "operator demo down"
