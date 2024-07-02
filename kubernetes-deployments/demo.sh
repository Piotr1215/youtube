#!/usr/bin/env bash

set -eo pipefail

# Add source and line number when running in debug mode
IFS=$'\n\t'

# Source the demo magic script (ensure the correct path)
. ./../__demo_magic.sh

./../__tmux_timer.sh &

TYPE_SPEED=15

stop_kubectl_port_forward() {
	# Find the PID of the kubectl port-forward process
	local pid=$(pgrep -f 'kubectl port-forward')

	# Check if the PID exists
	if [ -n "$pid" ]; then
		kill $pid
	fi
}

clear

# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Stop any port forwarding
stop_kubectl_port_forward

# Delete resources
kubectl delete -f ./example/deployment.yaml &>/dev/null || true

# Simulate typing
nvim -c 'SimulateTyping ./example/deployment.yaml 20'

# Create the deployment
pe "kubectl apply -f ./example/deployment.yaml"

# Launch
pe "kubectl port-forward svc/nginxsvc 8080:80 &"

# Curl to see if works
pe "curl -s http://localhost:8080 | html2text"
