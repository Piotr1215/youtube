#!/usr/bin/env bash
set -eo pipefail
. ./../__demo_magic.sh
./../__tmux_timer.sh &
TYPE_SPEED=30
cat <<EOF >deploy-config.yaml
app:
  name: mywebapp
  version: 1.0.0
  image: nginx:latest
  replicas: 3
database:
  image: postgres:13
  password: secretpassword
EOF
clear
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
pem "echo 6 Essential Linux Commands for DevOps Engineers"

# 1. yq - Parse and modify our deployment configuration
pem "echo 1. Using yq to inspect our deployment config"
pei "cat deploy-config.yaml"
pei "yq '.app.image' deploy-config.yaml"

# 2. sed and grep - Update configuration for next release
pem "echo 2. Using sed and grep to update app version for next release"
pei "sed -i 's/version: 1.0.0/version: 1.1.0/' deploy-config.yaml"
pei "grep version deploy-config.yaml"

# 3. curl - Check our deployment API and parse the response
pem "echo 3. Using curl to check deployment API status"
pei "curl -s 'https://api.github.com/repos/kubernetes/kubernetes/releases/latest' | yq '.tag_name'"

# 4. tee - Log our deployment process
pem "echo 4. Using tee to log deployment steps"
pei "echo 'Starting deployment process' | tee deployment.log"
pei "echo 'App version: 1.1.0' | tee -a deployment.log"
pei "cat deployment.log"

# 4. watch - Monitor deployment progress
pem "echo 5. Using watch to check deployment progress logs"
pem "echo 'Pods ready: 1/3' | tee -a deployment.log"
pem "echo 'Pods ready: 2/3' | tee -a deployment.log"
pem "echo 'Pods ready: 3/3' | tee -a deployment.log"
clear

# 6. journalctl - Query Systemd Journal Logs
pem "echo 6. Using journalctl to view and filter system logs"
pei "journalctl -u ollama.service | tail"

# Cleanup
rm deploy-config.yaml deployment.log
