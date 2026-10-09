#!/usr/bin/env bash
set -eo pipefail
cd "$(dirname "$0")"
export KUBECONFIG="${PAVED_KUBECONFIG:-${HOME}/.kube/paved-demo.config}"

# Prove the guardrails enforce, not just exist. Try to ship a naive pod (root,
# no security context) into the tenant cluster. The restricted Pod Security
# Standard the ai-tool-runtime template injected rejects it at admission, so
# nothing is created. The team wrote no policy; the template does the enforcing.
# Each rejection reason is translated into plain words for the audience.

tenant="${TENANT:-team-docs}"

# Print one reason the platform refused the pod.
# $1: the reason in plain words
why() { printf '     \e[37m› %s\e[0m\n' "$1"; }

printf '\e[1;36m%s\e[0m\n\n' "Someone ships a tool the unsafe way: as root, with no restrictions."

out="$(vcluster connect "${tenant}" --driver helm -- \
	kubectl run rule-breaker --image=nginx --restart=Never 2>&1 || true)"

if echo "${out}" | grep -qE "Forbidden|violates"; then
	printf '  \e[31m✗\e[0m  \e[1;37m%s\e[0m\n' "refused before it ever started, because:"
	echo "${out}" | grep -q 'runAsNonRoot' && why "it would run as the all-powerful root user"
	echo "${out}" | grep -q 'allowPrivilegeEscalation' && why "it could raise its own privileges"
	echo "${out}" | grep -q 'capabilities' && why "it keeps system powers it does not need"
else
	echo "${out}"
fi

printf '\n\e[33m%s\e[0m\n' "The team wrote no rule for this; the road enforced it."
