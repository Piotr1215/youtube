#!/usr/bin/env bash
# start the Platform, print its login for the UI, and log the CLI in. vcluster
# create needs that login: with a stale key the control plane gets no license and
# crash-loops with "license is not online". platform start never refreshes the
# CLI's key, so this logs in on every run.
#
#   ./platform.sh
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

log="$(mktemp)"
trap 'rm -f "${log}"' EXIT

# Print the value after a label in the platform start output.
# $1: label
field() { sed -E 's/\x1b\[[0-9;]*m//g' "${log}" | sed -n "s/^$1 *//p"; }

# Exchange the admin password for an access key.
# $1: Platform URL, $2: password
access_key() {
	local key
	key="$(curl -sk -X POST "$1/auth/password/login" -H 'Content-Type: application/json' \
		-d "$(jq -nc --arg p "$2" '{username: "admin", password: $p}')" | jq -r '.accessKey // empty')"
	if [[ -z "${key}" ]]; then
		fail "no access key from $1" "  Is the Platform up, and is its admin password unchanged?" >&2
		return 1
	fi
	printf '%s\n' "${key}"
}

vcluster use driver docker 2>&1 | brief
vcluster platform start 2>&1 | tee "${log}" | brief
url="$(field 'Login via UI:')"
key="$(access_key "${url}" "$(field 'Password:')")"
vcluster platform login "${url}" --access-key "${key}" --insecure 2>&1 | brief

note "Log in to the UI with the admin password above."
