#!/usr/bin/env bash
# Start the demo's own Intake instance next to the tenant cluster (setup.sh
# made it): a local NATS with the EVENTS stream, the engine in push mode, and
# the adapter watching the tenant cluster. A fresh state starts from the seed:
# one default rule and one action, nothing else.
set -eo pipefail
source "$(dirname "$0")/env.sh"
mkdir -p "${DEMO_STATE}"
alive() { [[ -s "${DEMO_STATE}/$1.pid" ]] && kill -0 "$(<"${DEMO_STATE}/$1.pid")" 2>/dev/null; }
start() { # name, command...
	local name=$1; shift
	alive "${name}" && return 0
	setsid "$@" >>"${DEMO_STATE}/${name}.log" 2>&1 </dev/null &
	echo $! >"${DEMO_STATE}/${name}.pid"
}

if [[ ! -d "${INTAKE_RULES}" ]]; then
	mkdir -p "${INTAKE_RULES}" "${INTAKE_HANDLERS}"
	cp "${DEMO_DIR}"/seed/*.yaml "${INTAKE_RULES}/"
	cp -r "${DEMO_DIR}"/actions/. "${INTAKE_HANDLERS}/"
	git -C "${INTAKE_RULES}" init -q
	git -C "${INTAKE_RULES}" add -A
	git -C "${INTAKE_RULES}" -c user.name=seed -c user.email=seed@demo commit -qm "seed: one default, no rules"
	touch "${INTAKE_LOG}" "${DEMO_STATE}/inbox.log" "${DEMO_STATE}/tess.log"
fi

# Tess's folder decides which Intake she operates (Piotr, 8 Nov: ownership "can
# be weak for now, maybe like folder location"). Claude reads the folder's local
# settings at every start there, a pane or a one-shot run, so this instance's
# INTAKE_* reach every shell she opens and the real rules stay out of reach.
operator_home="${OPERATOR_HOME:-$HOME/loft/tenant-operator}"
if [[ -d "${operator_home}/.claude" ]]; then
	pins=(DEMO_STATE TENANT KUBECONFIG EVENTS_NATS_URL INTAKE_RULES INTAKE_HANDLERS INTAKE_LOG
		INTAKE_ROUTER_JOURNAL INTAKE_RULES_CHANGES INTAKE_RULES_HISTORY INTAKE_PROCESS_DELIVERED
		INTAKE_PROCESS_HOLD INTAKE_ROUTE_TARGET_CMD INTAKE_ROUTER_SEND INTAKE_CONFIG INTAKE_BY)
	local_settings="${operator_home}/.claude/settings.local.json"
	[[ -s "${local_settings}" ]] || echo '{}' >"${local_settings}"
	jq --argjson names "$(printf '%s\n' "${pins[@]}" | jq -Rn '[inputs]')" \
		'.env = ((.env // {}) + ([$names[] | {key: ., value: $ENV[.]}] | from_entries))' \
		"${local_settings}" >"${local_settings}.tmp" && mv "${local_settings}.tmp" "${local_settings}"
fi

start nats nats-server -js -a 127.0.0.1 -p "${DEMO_NATS_PORT}" -sd "${DEMO_STATE}/nats"
for _ in $(seq 50); do nats --server "${EVENTS_NATS_URL}" account info >/dev/null 2>&1 && break; sleep 0.1; done
nats --server "${EVENTS_NATS_URL}" stream info EVENTS >/dev/null 2>&1 ||
	nats --server "${EVENTS_NATS_URL}" stream add EVENTS --subjects 'events.>' --storage file --retention limits --defaults >/dev/null
nats --server "${EVENTS_NATS_URL}" consumer info EVENTS intake-process >/dev/null 2>&1 ||
	nats --server "${EVENTS_NATS_URL}" consumer add EVENTS intake-process --pull --deliver all --ack explicit \
		--filter 'events.>' --max-pending 1000 --wait 10m --max-deliver=-1 --defaults >/dev/null

start process intake process
start adapter "${DEMO_DIR}/adapter.sh"
echo "operator demo up: state ${DEMO_STATE}, events ${EVENTS_NATS_URL}"
