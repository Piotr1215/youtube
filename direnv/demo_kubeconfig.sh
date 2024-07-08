#!/usr/bin/env bash
set -eo pipefail
. ./../__demo_magic.sh
TYPE_SPEED=15
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Alternative approach: use a function that runs in the current shell
show_kubeconfig() {
	echo $KUBECONFIG
}
# Setup test environment
cd /home/decoder/dev/shorts/direnv
rm -rf ./my_cluster 2>/dev/null || true
./separate-kubeconfig.sh my_cluster

# Change to the my_cluster directory
cd ./my_cluster

# Allow the .envrc file
direnv allow 2>/dev/null || true

p "Before we evaluate direnv this will be my global KUBECONFIG"

pe "show_kubeconfig"

# Use eval to ensure the environment is updated in the current shell
eval "$(direnv export bash)"

p "kubeconfig should point to the ./config file in the my_cluster directory"

pe "show_kubeconfig"
