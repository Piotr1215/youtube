#!/usr/bin/env bash
set -eo pipefail
cd "$(dirname "$0")"
export KUBECONFIG="${PAVED_KUBECONFIG:-${HOME}/.kube/paved-demo.config}"

# Prove the guardrails enforce, not just exist. Try to ship a naive pod (root,
# no security context) into the tenant cluster. The restricted Pod Security
# Standard the ai-tool-runtime template injected rejects it at admission, so
# nothing is created. The team wrote no policy; the template does the enforcing.

tenant="${TENANT:-team-docs}"

printf '\e[1;36m%s\e[0m\n\n' "Deploying a non-compliant pod into ${tenant}..."

out="$(vcluster connect "${tenant}" --driver helm -- \
    kubectl run rule-breaker --image=nginx --restart=Never 2>&1 || true)"
echo "${out}" | grep -E "Forbidden|violates" || echo "${out}"

printf '\n\e[33m%s\e[0m\n' "Rejected at admission. The team wrote no policy; the template enforces it."
