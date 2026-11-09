#!/usr/bin/env bash
# say whether the network this laptop joined cuts a local bridge off from the internet.
# A bridge keeps the subnet it was made with, so a new wifi can land on top of it. When
# the wifi's route is the more specific one, replies to the bridge's containers leave
# through the wifi and never arrive: the Platform restarts forever and every slide hangs.
# Prints nothing and exits 0 when every bridge is clear.
#
#   ./net-check.sh
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

clash=0
for dev in $(ip -j link show type bridge | jq -r '.[].ifname'); do
	subnet="$(ip -j -4 route show dev "${dev}" | jq -r 'first(.[] | select(.dst | contains("/")) | .dst) // empty')"
	[[ -n "${subnet}" ]] || continue
	# The first container on a bridge gets .2, so ask the kernel where a reply to it goes.
	reply="$(ip -j route get "${subnet%.*}.2" | jq -r '.[0].dev')"
	if [[ "${reply}" != "${dev}" ]]; then
		fail "${dev} ${subnet} is cut off by ${reply}" "  Its containers have no internet: the network overlaps this bridge."
		clash=1
	fi
done
exit "${clash}"
