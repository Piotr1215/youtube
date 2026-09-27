#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")" || exit 1

# Publish the local MCP server at the fixed public URL via a cloudflared tunnel.
# The server runs inside the team-docs tenant and is reached through an Ingress:
# vcluster syncs the Ingress to the kind host, ingress-nginx serves it, and the
# kind extraPortMapping exposes it at localhost:8088. Detached so it keeps
# serving across the QR / audience slides. Same local pattern as the kai talk.
#
# The tunnel's ingress rule (mcp.cloudrumble.net -> http://localhost:8088) and
# the DNS record are configured Cloudflare-side, once. This only runs the
# connector. The token is PERSONAL: it lives in a local file, never in git.

token_file="${CF_TOKEN_FILE:-${HOME}/.config/haiku-tunnel/token}"
log="${TMPDIR:-/tmp}/mcp-tunnel.log"
url="https://mcp.cloudrumble.net/mcp"

if [ ! -s "${token_file}" ]; then
    echo "error: tunnel token not found at ${token_file}" >&2
    echo "  drop your cloudflared token there, or set CF_TOKEN_FILE=/path/to/token" >&2
    exit 1
fi

# Don't start a second connector if one is already running.
if pgrep -x cloudflared >/dev/null 2>&1; then
    echo "already live -> ${url}"
    exit 0
fi

setsid cloudflared tunnel run --token "$(cat "${token_file}")" >"${log}" 2>&1 &
disown 2>/dev/null || true

echo "publishing -> ${url} (give the tunnel ~10s to register)"
