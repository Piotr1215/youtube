#!/usr/bin/env bash
# run the audience page for the QR slide: audience/server.py on 127.0.0.1, made
# public through the named tunnel's gpu.cloudrumble.net once that hostname has a
# route, or through a temporary trycloudflare.com quick tunnel until then. url
# prints the public address once it answers. stop ends only the processes start
# launched and deletes the page's private state directory.
#
#   ./audience.sh start|stop|status|url|qr
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

PORT="${AUDIENCE_PORT:-8089}"
URL="${AUDIENCE_URL:-https://gpu.cloudrumble.net}"
TOKEN_FILE="${CF_TOKEN_FILE:-${HOME}/.config/haiku-tunnel/token}"
STATE="${XDG_RUNTIME_DIR:-/tmp}/vind-audience"
SAMPLE="The deployment is stuck at 0 of 3 replicas."

alive() { [[ -s "${STATE}/$1.pid" ]] && kill -0 "$(<"${STATE}/$1.pid")" 2>/dev/null; }

start() {
	install -d -m 700 "${STATE}"
	if ! alive server; then
		CLASSIF_LOG="${STATE}/classif.jsonl" setsid python3 -I audience/server.py "${PORT}" \
			>"${STATE}/server.log" 2>&1 </dev/null &
		echo $! >"${STATE}/server.pid"
	fi
	for _ in $(seq 1 20); do
		curl -sf "http://127.0.0.1:${PORT}/healthz" >/dev/null && break
		sleep 0.5
	done
	if ! curl -sf "http://127.0.0.1:${PORT}/healthz" >/dev/null; then
		fail "the page did not start" "$(tail -3 "${STATE}/server.log")"
		exit 1
	fi
	ok "page" "http://127.0.0.1:${PORT}, bound to this laptop only"

	public="${URL}"
	host="${URL#https://}"
	# Ask public DNS: a home or venue resolver may still cache the hostname's old
	# NXDOMAIN. --resolve then reaches Cloudflare's edge without that resolver.
	edge="$(dig +short +time=3 @1.1.1.1 "${host}" A 2>/dev/null | grep -E '^[0-9.]+$' | head -1 || true)"
	reach=()
	if alive tunnel; then
		public="$(<"${STATE}/public")"
		ok "tunnel" "started earlier"
	elif [[ -n "${edge}" ]]; then
		# The hostname's route lives on the named tunnel, which may already run for
		# another demo; only a connector started here is stopped by stop.
		if pgrep -x cloudflared >/dev/null; then
			ok "tunnel" "a cloudflared connector already runs, reused"
		elif [[ -s "${TOKEN_FILE}" ]]; then
			TUNNEL_TOKEN_FILE="${TOKEN_FILE}" setsid cloudflared tunnel run >"${STATE}/tunnel.log" 2>&1 </dev/null &
			echo $! >"${STATE}/tunnel.pid"
			ok "tunnel" "named tunnel connector started"
		else
			fail "no tunnel token at ${TOKEN_FILE}" "  set CF_TOKEN_FILE"
			exit 1
		fi
	else
		setsid cloudflared tunnel --no-autoupdate --url "http://127.0.0.1:${PORT}" \
			>"${STATE}/tunnel.log" 2>&1 </dev/null &
		echo $! >"${STATE}/tunnel.pid"
		public=""
		for _ in $(seq 1 30); do
			public="$(grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' "${STATE}/tunnel.log" | head -1 || true)"
			[[ -n "${public}" ]] && break
			sleep 1
		done
		ok "tunnel" "quick tunnel: ${host} has no route yet"
	fi
	echo "${public}" >"${STATE}/public"
	[[ "${public}" == "${URL}" && -n "${edge}" ]] && reach=(--resolve "${host}:443:${edge}")

	code=""
	for _ in $(seq 1 60); do
		[[ -n "${public}" ]] && code="$(curl -s "${reach[@]}" -o /dev/null -w '%{http_code}' -m 5 "${public}/healthz" || true)"
		[[ "${code}" == 200 ]] && break
		sleep 1
	done
	ready=1
	if [[ "${code}" == 200 ]]; then
		ok "public" "${public} reaches the page"
	else
		fail "${public:-the tunnel} answers ${code:-nothing}" "  see ${STATE}/tunnel.log"
		ready=0
	fi

	answer="$(curl -s -m 30 -H 'Content-Type: application/json' \
		-d "{\"text\": \"${SAMPLE}\"}" "http://127.0.0.1:${PORT}/api/classify" |
		jq -r 'if .label then "\(.label) \(.p) in \(.seconds) s" else empty end' 2>/dev/null || true)"
	if [[ -n "${answer}" ]]; then
		ok "T4" "answers through the page: ${answer}"
	else
		fail "the T4 does not answer yet" "  is the classif Stack Healthy?"
		ready=0
	fi
	# A dead QR code on screen is worse than none: fail so the presenter sees it,
	# and let url and qr hand out the address only once both checks passed.
	((ready)) && touch "${STATE}/verified"
}

stop() {
	for name in server tunnel; do
		alive "${name}" && kill "$(<"${STATE}/${name}.pid")"
	done
	rm -rf "${STATE}"
	ok "audience page" "stopped, its state deleted"
}

# The public address, once start has seen it and the T4 answer and both the page
# and its tunnel still run.
url() {
	[[ -f "${STATE}/verified" ]] && alive server || return 1
	alive tunnel || pgrep -x cloudflared >/dev/null || return 1
	cat "${STATE}/public"
}

# The QR code for the url, for an +exec slide: presenterm runs +exec_replace blocks
# when the deck loads, before start has made the page public.
qr() {
	local address
	if ! address="$(url)"; then
		fail "the page is not public yet" "  run ./audience.sh start first"
		return 1
	fi
	qrencode -t UTF8 -s 1 -m 2 "${address}"
	paint 'bold white' "  ${address}"
}

status() {
	if alive server; then
		curl -sf "http://127.0.0.1:${PORT}/healthz" |
			jq -r '"  \(.answers) answers: \(.yes // 0) yes, \(.no // 0) no, \(.unknown // 0) unknown"'
	else
		paint gray "  the audience page is not running"
	fi
}

case "${1:-}" in
start | stop | status | url | qr) "$1" ;;
*)
	echo "usage: ./audience.sh start|stop|status|url|qr" >&2
	exit 1
	;;
esac
