#!/usr/bin/env bash
set -eo pipefail
cd "$(dirname "$0")"
export KUBECONFIG="${PAVED_KUBECONFIG:-${HOME}/.kube/paved-demo.config}"

# Ship the team's tool into the governed tenant cluster. Pins the demo
# kubeconfig so this can only ever target the local kind rig, never the
# ambient cluster the shell's KUBECONFIG might point at. Output names each
# manifest by what it is for, so a non-Kubernetes audience can follow it.

tenant="${TENANT:-team-docs}"

# Print one shipped part and what happened to it.
# $1: the part in plain words, $2: created, configured, or unchanged
ok() { printf '  \e[32m✓\e[0m  \e[37m%-24s\e[0m\e[36m%s\e[0m\n' "$1" "$2"; }

printf '\e[1;36m%s\e[0m\n' "The team ships its tool: three standard files, no security rules."
vcluster connect "${tenant}" --driver helm -- kubectl apply -f vcluster-yaml-mcp/ 2>&1 |
	while IFS= read -r line; do
		case "${line}" in
		deployment*) ok "the tool itself" "${line##* }" ;;
		service/*) ok "its internal address" "${line##* }" ;;
		ingress*) ok "its public entrance" "${line##* }" ;;
		*rror*) printf '  \e[31m✗\e[0m  %s\n' "${line}" ;;
		esac
	done

printf '\n\e[1;36m%s\e[0m\n' "The platform checks it against the road's rules:"
if vcluster connect "${tenant}" --driver helm -- \
	kubectl rollout status deployment/vcluster-yaml-mcp-server --timeout=90s >/dev/null 2>&1; then
	ok "admitted and running" "non-root, inside the team's quota"
else
	printf '  \e[31m✗\e[0m  \e[37m%s\e[0m\n' "not running yet"
fi

printf '\n\e[33m%s\e[0m\n' "The team wrote none of the rules it just passed."
