#!/usr/bin/env bash
set -eo pipefail
. ./../__demo_magic.sh
TYPE_SPEED=45
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Check current Kubernetes version
echo 'Check current Kubernetes version' | boxes -d simple | __center_text.sh
pe "curl -s 'https://api.github.com/repos/kubernetes/kubernetes/releases/latest' | yq '.tag_name'"

clear

# Download a file from the internet
echo 'Download a file from the internet' | boxes -d simple | __center_text.sh
pe "curl -O https://speed.hetzner.de/100MB.bin"
pe "ls -lh 100MB.bin"

clear

# Send a POST request with JSON data to JSONPlaceholder
echo 'Send a POST request with JSON data' | boxes -d simple | __center_text.sh
pe "curl -X POST https://jsonplaceholder.typicode.com/posts -H 'Content-Type: application/json'
    -d '{\"title\":\"foo\",\"body\":\"bar\",\"userId\":1}'"

clear

# Authenticate with an API using a token (dummy example)
echo 'Authenticate with an API using a token' | boxes -d simple | __center_text.sh
pe "curl -H 'Authorization: Bearer your_token' https://jsonplaceholder.typicode.com/posts/1"

clear

# Upload a file to a server
echo 'Upload a file to a server' | boxes -d simple | __center_text.sh
FILE_URL=$(curl -F 'file=@./sample.txt' https://file.io | jq -r '.link')
pe "curl -F 'file=@./sample.txt' https://file.io | jq -r '.link'"
pe "curl $FILE_URL"

clear

# Check response time of a URL
echo 'Check response time of a URL' | boxes -d simple | __center_text.sh
pe "curl -o /dev/null -s -w 'Time: %{time_total}\n' https://www.example.com"

clear

# Monitor API health by checking response headers
echo 'Monitor API health by checking response headers' | boxes -d simple | __center_text.sh
pe "curl -I https://httpbin.org/get"

clear

# Test URL with custom headers
echo 'Test URL with custom headers' | boxes -d simple | __center_text.sh
pe "curl --header 'Content-Type: application/json' https://jsonplaceholder.typicode.com/posts"

# Clean up
rm -f deploy-config.yaml sample.json
