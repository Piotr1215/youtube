#!/usr/bin/env bash
# Delete the kai-isolated tenant cluster (scheduler, CRDs and all state) in one
# timed shot. Runs from the control plane cluster context so it always finds it.
set -uo pipefail

kubectl config use-context kind-kai-demo >/dev/null
echo "+ vcluster delete kai-isolated --delete-namespace"
time vcluster delete kai-isolated --delete-namespace --driver helm
