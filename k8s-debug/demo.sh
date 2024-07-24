#!/usr/bin/env bash

set -eo pipefail

# Source the demo magic script
. ./../__demo_magic.sh

# Start the timer
./../__tmux_timer.sh &

CLEAR_SCREEN=true
TYPE_SPEED=20
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

clear

# Check pod status
pe "kubectl get pods"

# Describe a specific pod (running)
pe "kubectl describe pod redis5"

# Check logs for a running pod
pe "kubectl logs redis5"

# Execute a command in a running pod
pe "kubectl exec -it redis5 -- redis-cli INFO"

# Use ephemeral debug container
pe "kubectl get pod/nginx -oyaml | yq '.status.podIP' | xclip -sel clip"
pe "kubectl debug redis5 -it --image=nicolaka/netshoot --target=redis5"

# Check events for the problematic pod
pe "kubectl get events --field-selector involvedObject.name=debug-pod"

# Clean up
# Add any necessary cleanup commands here
