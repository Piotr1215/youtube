#!/usr/bin/env bash

set -eo pipefail

# Add source and line number when running in debug mode
IFS=$'\n\t'

# Source the demo magic script (ensure the correct path)
. ./../__demo_magic.sh

./../__tmux_timer.sh &

TYPE_SPEED=15
CLEAR_SCREEN=true

clear

# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Create a new namespace for the demo
pei "kubectl create namespace demo-namespace"

# List all namespaces to confirm creation
pei "kubectl get namespaces"

# Create a deployment in the demo namespace
pei "kubectl create deployment nginx-deployment --image=nginx --replicas=2 -n demo-namespace"

# Get all pods in the demo namespace
pei "kubectl get pods -n demo-namespace"

# Describe the deployment to show detailed information
pei "kubectl describe deployment nginx-deployment -n demo-namespace"

# Scale the deployment to 4 replicas
pei "kubectl scale deployment nginx-deployment --replicas=4 -n demo-namespace"

# Get the pods again to show the updated number of replicas
pei "kubectl get pods -n demo-namespace"

# Clean up by deleting the namespace
pei "kubectl delete namespace demo-namespace"

echo "Demo completed!"
