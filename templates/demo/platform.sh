#!/usr/bin/env bash
# A deck's own vCluster Platform: a Docker container beside every other deck's, with its
# own volume, relay address and CLI config, so decks run in parallel and no deck's
# clusters show in another's UI. vcluster platform start always makes the container
# vcluster-platform (docker.go), so this makes the same container under the deck's name.
# A vind cluster registers with the Platform its CLI config is logged in to
# (create_docker.go), so the deck calls vcluster with --config "$DEMO_VCLUSTER_CONFIG".
# No address is written by hand: build registers the one the container hands out.
#
#   DEMO_DECK                the deck's name (required)
#   DEMO_PLATFORM_CONTAINER  default vcluster-platform-$DEMO_DECK
#   DEMO_PLATFORM_IMAGE      default ghcr.io/loft-sh/vcluster-platform:5.0.0
#   DEMO_VCLUSTER_CONFIG     default ~/.vcluster/$DEMO_DECK.json; a config in ~/.vcluster
#                            shares the CLI's download cache, kept beside the config
#   DEMO_MGMT_KUBECONFIG     the admin kubeconfig written after each login, default
#                            $XDG_STATE_HOME/demo/$DEMO_DECK/platform.kubeconfig
#
#   probe       the container runs, the deck's CLI is logged in to the registered
#               address, and the Platform answers three times in a row
#   start       starts the container and logs the CLI in again when its login lapsed
#   build       start, creating the container from the cached image when it is missing
#   stop        stops the container; down keeps it, since a new one needs activating
#   activated   its license lets clusters be created: a new Platform blocks them until
#               it is activated once, online, in its UI
#   login       prints the UI login row and copies the admin password to the clipboard;
#               --show also prints the password
#   ui PATH     prints a link into the UI, for under a step that changed that page
#   key         prints a fresh admin access key, for a slide's hidden login line
#
#   DEMO_DECK=<deck> ./platform.sh probe|start|build|stop|activated|login [--show]|ui PATH|key
set -euo pipefail

deck="${DEMO_DECK:?set DEMO_DECK to the deck name}"
[[ "${deck}" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "invalid DEMO_DECK: ${deck}" >&2; exit 2; }
state="${XDG_STATE_HOME:-${HOME}/.local/state}/demo/${deck}"
container="${DEMO_PLATFORM_CONTAINER:-vcluster-platform-${deck}}"
image="${DEMO_PLATFORM_IMAGE:-ghcr.io/loft-sh/vcluster-platform:5.0.0}"
config="${DEMO_VCLUSTER_CONFIG:-${HOME}/.vcluster/${deck}.json}"
mgmt="${DEMO_MGMT_KUBECONFIG:-${state}/platform.kubeconfig}"
registry="${state}/registry"

# Run the vcluster CLI with the deck's config.
vc() { command vcluster --config "${config}" "$@"; }

# Run kubectl against the Platform as admin.
mk() { kubectl --kubeconfig "${mgmt}" "$@"; }

# Print the address the deck's CLI is logged in to.
logged_in() { jq -r '.platform.host // empty' "${config}" 2>/dev/null || true; }

# Print the address build registered for the container.
registered() { jq -r '.url // empty' "${registry}/platform.json" 2>/dev/null || true; }

# Print the admin password vcluster platform start derives when none is given: an
# HMAC-SHA256 of $HOME keyed with this machine's id. Every deck's Platform uses it.
admin_password() { printf '%s' "${HOME}" | openssl dgst -sha256 -hmac "$(cat /etc/machine-id)" -r | cut -d' ' -f1; }

# Print an admin access key from the Platform, the exchange a UI login does.
# $1: Platform URL
access_key() {
	curl -sk -m 10 -X POST "$1/auth/password/login" -H 'Content-Type: application/json' \
		-d "$(jq -nc --arg p "$(admin_password)" '{username: "admin", password: $p}')" 2>/dev/null |
		jq -r '.accessKey // empty' 2>/dev/null || true
}

# Exit 0 when ready, 1 when not, 2 when Docker cannot be asked. After a Wi-Fi change
# the Platform can answer once and restart, hence three answers.
probe() {
	local running i
	docker version >/dev/null 2>&1 || return 2
	running="$(docker inspect -f '{{.State.Running}}' "${container}" 2>/dev/null)" ||
		{ echo "${container} does not exist" >&2; return 1; }
	[[ "${running}" == true ]] || { echo "${container} stopped" >&2; return 1; }
	[[ -n "$(registered)" && "$(logged_in)" == "$(registered)" ]] ||
		{ echo "the deck's CLI is not logged in to ${container}" >&2; return 1; }
	[[ "$(jq -r '.driver.type // empty' "${config}" 2>/dev/null)" == docker ]] ||
		{ echo "the deck's CLI does not use the docker driver" >&2; return 1; }
	for i in 1 2 3; do
		((i == 1)) || sleep 2
		vc platform get current-user >/dev/null 2>&1 || { echo "the Platform does not answer" >&2; return 1; }
	done
	mk --request-timeout=10s get --raw /version >/dev/null 2>&1 || { echo "the admin kubeconfig does not answer" >&2; return 1; }
}

# Start the container, wait for its relay address, log the deck's CLI in when its login
# lapsed, register the address and write the admin kubeconfig.
# $1: "create" to create a missing container
up() {
	local domain='' key='' url
	if ! docker inspect "${container}" >/dev/null 2>&1; then
		[[ "${1:-}" == create ]] || { echo "${container} does not exist: run just reset" >&2; return 1; }
		docker image inspect "${image}" >/dev/null 2>&1 ||
			{ echo "${image} is not cached: docker pull ${image} on good Wi-Fi" >&2; return 1; }
		# The run vcluster platform start does (docker.go), with the deck's own name and volume.
		docker run -d --name "${container}" \
			--env "ADMIN_PASSWORD_HASH=$(printf '%s' "$(admin_password)" | sha256sum | cut -d' ' -f1)" \
			-v "${container}:/var/lib/loft" "${image}" >/dev/null
		echo "created ${container}; a new Platform needs activating once in its UI"
	fi
	docker start "${container}" >/dev/null
	for _ in $(seq 120); do
		domain="$(docker exec "${container}" cat /var/lib/loft/loft-domain.txt 2>/dev/null || true)"
		[[ -n "${domain}" ]] && break
		sleep 5
	done
	[[ -n "${domain}" ]] || { echo "${container} handed out no relay address in 10 min" >&2; return 1; }
	url="https://${domain}"
	if [[ "$(logged_in)" != "${url}" ]] || ! vc platform get current-user >/dev/null 2>&1; then
		for _ in $(seq 60); do
			key="$(access_key "${url}")"
			[[ -n "${key}" ]] && break
			sleep 5
		done
		[[ -n "${key}" ]] || { echo "${url} gave no access key in 5 min" >&2; return 1; }
		vc platform login "${url}" --access-key "${key}" --insecure 2>&1 |
			sed -u -E -e 's/\x1b\[[0-9;]*m//g' -e '/^[[:space:]]*$/d' -e 's/^/  /'
	fi
	vc use driver docker >/dev/null
	mkdir -p "${registry}"
	jq -n --arg url "${url}" --arg container "${container}" \
		--arg id "$(docker inspect -f '{{.Id}}' "${container}")" \
		'{url: $url, container: $container, id: $id}' >"${registry}/platform.json"
	mkdir -p "$(dirname "${mgmt}")" && chmod 700 "$(dirname "${mgmt}")"
	(umask 077 && vc platform connect management --print >"${mgmt}.new") && mv "${mgmt}.new" "${mgmt}"
	echo "${container} at ${url}"
}

stop() {
	[[ "$(docker inspect -f '{{.State.Running}}' "${container}" 2>/dev/null)" != true ]] ||
		docker stop "${container}" >/dev/null
}

# Exit 0 when the license lets clusters be created, 1 when it blocks them, 2 when the
# Platform cannot be asked. A License with no status yet is not activated either.
activated() {
	local out
	out="$(mk --request-timeout=10s get licenses.management.loft.sh loft -o json 2>/dev/null)" || return 2
	jq -e '.status.license != null and ((.status.license.block // []) | length == 0)' <<<"${out}" >/dev/null && return 0
	echo "not activated: log in at $(logged_in) as admin and activate it" >&2
	return 1
}

# Print the UI login row, and copy the admin password to the clipboard.
# $1: --show to also print the password
login() {
	local url password
	url="$(logged_in)"
	url="${url:-no Platform in ${config}}"
	password="$(admin_password)"
	if printf '%s' "${password}" | xclip -selection clipboard >/dev/null 2>&1; then
		[[ "${1:-}" == --show ]] || { paint cyan '  login            ' plain "${url}" gray '  admin, password in the clipboard'; return; }
	elif [[ "${1:-}" != --show ]]; then
		paint cyan '  login            ' plain "${url}" red '  clipboard failed: login --show'
		return
	fi
	# The password on a row of its own keeps both rows within a slide's width.
	paint cyan '  login            ' plain "${url}" gray '  admin'
	paint cyan '  password         ' plain "${password}"
}

# Print a link into the UI under a step's output.
# $1: UI path, such as projects/default/vclusters/my-cluster
ui() {
	local url
	url="$(logged_in)"
	printf '\n  \e[35m↗\e[0m  \e[4;36m%s/%s\e[0m\n' "${url%/}" "${1#/}"
}

# Print a fresh admin access key for the Platform the deck's CLI is logged in to.
key() {
	local key
	key="$(access_key "$(logged_in)")"
	[[ -n "${key}" ]] || { echo "no access key from $(logged_in)" >&2; return 1; }
	printf '%s\n' "${key}"
}

case "${1:-}" in
	probe) probe ;;
	start) up ;;
	build) up create ;;
	stop) stop ;;
	activated) activated ;;
	login) login "${2:-}" ;;
	ui) ui "${2:?usage: platform.sh ui PATH}" ;;
	key) key ;;
	*) echo "usage: DEMO_DECK=<deck> platform.sh probe|start|build|stop|activated|login [--show]|ui PATH|key" >&2; exit 1 ;;
esac
