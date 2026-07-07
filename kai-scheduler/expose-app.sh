#!/usr/bin/env bash
# Publish the local haiku app (localhost:5000) at the fixed public URL via a
# cloudflared tunnel. Started detached so it survives past this script and keeps
# serving across the QR / audience-haiku slides.
set -uo pipefail

TOKEN_FILE="${CF_TOKEN_FILE:-$HOME/.config/haiku-tunnel/token}"
LOG="${TMPDIR:-/tmp}/haiku-tunnel.log"
URL="https://haiku.cloudrumble.net"

if [ ! -f "$TOKEN_FILE" ]; then
    echo "Missing cloudflared token at $TOKEN_FILE" >&2
    exit 1
fi

# Don't start a second connector if one is already running.
if pgrep -x cloudflared >/dev/null 2>&1; then
    echo "Already live → ${URL}"
    exit 0
fi

setsid cloudflared tunnel run --token "$(cat "$TOKEN_FILE")" >"$LOG" 2>&1 &
disown 2>/dev/null || true

echo "Publishing → ${URL}"
