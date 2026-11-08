#!/usr/bin/env bash
# The event source: every Warning event in the tenant cluster becomes one
# notifications.log line, published on the demo EVENTS stream. The watch
# replays existing events first (fields split on \x1f: kubectl's watch output
# turns tabs into spaces); each event's uid and count is its message id.
# The API server ends a watch after a while, so the watch restarts in a loop,
# and the ids already published are kept in a file: the stream's duplicate
# window is two minutes, too short to catch a replay after a restart.
set -eo pipefail
source "$(dirname "$0")/env.sh"
source_token="k8s-${TENANT}"
seen="${DEMO_STATE}/adapter-seen"
touch "${seen}"
tpl='{{if eq .type "Warning"}}{{.metadata.uid}}-{{.count}}{{"\x1f"}}{{.reason}}{{"\x1f"}}{{.involvedObject.kind}}/{{.involvedObject.name}}{{"\x1f"}}{{.metadata.namespace}}{{"\x1f"}}{{.message}}{{"\n"}}{{end}}'
while true; do
	"${DEMO_DIR}/tk" get events -A --watch -o go-template="${tpl}" | while IFS=$'\x1f' read -r id reason obj ns message; do
		# Only well-formed event lines: a reason word and a kind/name object.
		[[ "${reason}" =~ ^[A-Za-z]+$ && "${obj}" == */* ]] || continue
		grep -qxF "${id}" "${seen}" && continue
		printf '%s\n' "${id}" >>"${seen}"
		message=${message//$'\t'/ }
		line=$(printf '%s\t%s\t%s %s %s:\tkind:k8s-warning tenant:%s ns:%s reason:%s obj:%s | %s' \
			"$(date '+%F %T')" "${source_token}" "${TENANT}" "${reason}" "${obj}" "${TENANT}" "${ns}" "${reason}" "${obj}" "${message}")
		printf '%s\n' "${line}" >>"${INTAKE_LOG}"
		nats --server "${EVENTS_NATS_URL}" pub "events.${source_token}.event" "${line}" -H "Nats-Msg-Id:${id}" >/dev/null 2>&1
		printf '%s event %s %s\n' "$(date +%T)" "${reason}" "${obj}"
	done
	sleep 2
done
