#!/usr/bin/env bash
set -eo pipefail
. ./../__demo_magic.sh
TYPE_SPEED=45
# CLEAR_SCREEN=true
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Create a sample Kubernetes Deployment YAML file
cat <<EOF >deploy-config.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mywebapp
  labels:
    app: mywebapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mywebapp
  template:
    metadata:
      labels:
        app: mywebapp
    spec:
      containers:
      - name: mywebapp
        image: nginx:latest
        ports:
        - containerPort: 80
EOF

# Extract the image name
echo 'Extract element from array' | boxes -d simple | __center_text.sh
pe "yq '.spec.template.spec.containers[0].image' deploy-config.yaml"

clear

# Extract name and labels from metadata
echo 'Extract multiple elements' | boxes -d simple | __center_text.sh
pe "yq '.metadata | (.name, .labels)' deploy-config.yaml"

clear

# Modify the replicas count
echo 'Modify element in place' | boxes -d simple | __center_text.sh
pe "yq '.spec.replicas = 5' -i deploy-config.yaml"

# Show only the changed replicas value
pe "yq '{\"New Replicas Spec\": .spec.replicas}' deploy-config.yaml"

clear

# Add a new label to the metadata
echo 'Add a new element' | boxes -d simple | __center_text.sh
pe "yq '.metadata.labels.newlabel = \"newvalue\"' -i deploy-config.yaml"

clear

# Remove the labels from the template metadata
echo 'Remove element' | boxes -d simple | __center_text.sh
pe "yq 'del(.spec.template.metadata.labels)' -i deploy-config.yaml"

clear
# Use yq with select syntax to update a specific container image
echo 'Update with selection' | boxes -d simple | __center_text.sh
pe "yq '(.spec.template.spec.containers[] | select(.name == \"mywebapp\") | .image) |= \"nginx:stable\"' -i deploy-config.yaml"

clear
# Create a sample JSON file
cat <<EOF >sample.json
{
  "name": "myjsonapp",
  "version": "1.0.0",
  "description": "This is a sample JSON file",
  "dependencies": {
    "yq": "^4.0.0",
    "jq": "^1.6"
  }
}
EOF
echo 'Convert JSON to YAML' | boxes -d simple | __center_text.sh
pe "bat sample.json"

# Print contents of sample.json as idiomatic YAML
pe "yq -P sample.json"
