#!/usr/bin/env bash
# The simple local loop on the laptop cluster: build the app image with Docker,
# apply the app package in app/ (the same files Argo CD reconciles later), get a
# LoadBalancer IP, and test it from the laptop. The image is never pushed.
#
#   ./local-loop.sh
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

IMAGE="web:dev"
kubectl delete -k app/ --ignore-not-found >/dev/null 2>&1
start="$(date +%s)"

cmd "docker build -t ${IMAGE} web/"
docker build -q -t "${IMAGE}" web/ >/dev/null
ok "build" "image ${IMAGE}, local to this laptop"

cmd "kubectl apply -k app/"
kubectl apply -k app/ >/dev/null
if ! kubectl rollout status deployment/web --timeout=90s >/dev/null 2>&1; then
	fail "the app did not start" "$(kubectl get pods -l app=web --no-headers 2>&1 | head -3)"
	exit 1
fi
ok "run" "Deployment and Service from app/, image from the laptop's Docker"

for _ in $(seq 1 30); do
	ip="$(kubectl get service web -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
	[[ -n "${ip}" ]] && break
	sleep 1
done
ok "expose" "LoadBalancer IP ${ip}, reachable from the laptop"

cmd "curl ${ip}"
# A fresh LoadBalancer IP takes a few seconds to route.
title=""
for _ in $(seq 1 15); do
	title="$(curl -s -m 2 "http://${ip}" | sed -n 's:.*<title>\(.*\)</title>.*:\1:p' || true)"
	[[ -n "${title}" ]] && break
	sleep 1
done
if [[ -n "${title}" ]]; then
	ok "test" "the app answers: ${title}"
else
	fail "no answer from ${ip}" ""
	exit 1
fi
note "Code to tested app in $(($(date +%s) - start)) seconds, all on the laptop."
