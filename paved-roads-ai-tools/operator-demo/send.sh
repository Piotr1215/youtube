#!/usr/bin/env bash
# INTAKE_ROUTER_SEND for the demo: the processor calls `send.sh -t <target> <digest>`.
# A digest for the operator wakes Tess for one run; anything else lands in the log.
set -eo pipefail
source "$(dirname "$0")/env.sh"
target=$2 text=$3
printf '%s %s -> %s\n%s\n' "$(date +%T)" "${SND_FROM:-?}" "${target}" "${text}" >>"${DEMO_STATE}/sent.log"
if [[ "${target}" == tenant-operator ]]; then
	setsid "${DEMO_DIR}/tess.sh" "${text}" </dev/null >/dev/null 2>&1 &
fi
