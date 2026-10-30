#!/usr/bin/env bash
# The simple local loop on the laptop cluster: build the app image with Docker,
# apply the app package in app/ (the same files Argo CD reconciles later), get a
# LoadBalancer IP and test it from the laptop, then edit the page and take the
# change through the same loop. The image is never pushed.
#
#   ./local-loop.sh
set -eo pipefail

cd "$(dirname "$0")"
source ./common.sh

IMAGE="web:dev"

# The edit is part of the demo; the next run starts from the committed page.
page="$(<web/index.html)"
trap 'printf "%s\n" "${page}" >web/index.html' EXIT

# Build the image, showing the command the way the audience would type it.
build() {
	cmd "docker build -t ${IMAGE} web/"
	docker build -q -t "${IMAGE}" web/ >/dev/null
}

# Wait for the deployment to finish rolling out.
rolled_out() {
	if ! kubectl rollout status deployment/web --timeout=90s >/dev/null 2>&1; then
		fail "the app did not start" "$(kubectl get pods -l app=web --no-headers 2>&1 | head -3)"
		exit 1
	fi
}

# Curl the app until it answers with the expected title. A fresh LoadBalancer IP
# takes a few seconds to route, and a rollout serves the old pod until it ends.
# $1: expected title
expect_title() {
	local title=""
	cmd "curl ${ip}"
	for _ in $(seq 1 15); do
		title="$(curl -s -m 2 "http://${ip}" | sed -n 's:.*<title>\(.*\)</title>.*:\1:p' || true)"
		[[ "${title}" == "$1" ]] && break
		sleep 1
	done
	if [[ "${title}" == "$1" ]]; then
		ok "test" "the app answers: ${title}"
	else
		fail "no answer from ${ip} with: $1" "  got: ${title:-nothing}"
		exit 1
	fi
}

kubectl delete -k app/ --ignore-not-found >/dev/null 2>&1

build
ok "build" "image ${IMAGE}, local to this laptop"

cmd "kubectl apply -k app/"
kubectl apply -k app/ >/dev/null
rolled_out
ok "run" "Deployment and Service from app/, image from the laptop's Docker"

for _ in $(seq 1 30); do
	ip="$(kubectl get service web -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
	[[ -n "${ip}" ]] && break
	sleep 1
done
ok "expose" "LoadBalancer IP ${ip}, reachable from the laptop"
expect_title "web app, dev build"

paint
start="$(date +%s)"
# A new title every run: the curl below can only pass on the image just built.
stamp="$(date +%T)"
cmd "sed -i 's/dev build/build ${stamp}/' web/index.html"
sed -i "s/dev build/build ${stamp}/" web/index.html
build
cmd "kubectl rollout restart deployment/web"
kubectl rollout restart deployment/web >/dev/null
rolled_out
ok "rebuild" "new image, new pod, nothing pushed"
expect_title "web app, build ${stamp}"
note "Edit to tested change in $(($(date +%s) - start)) seconds, all on the laptop."
