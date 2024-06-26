#!/usr/bin/env bash

set -eo pipefail

# Source the demo magic script (ensure the correct path)
. ./../__demo_magic.sh

./../__tmux_timer.sh &

TYPE_SPEED=20
CLEAR_SCREEN=true

clear

# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Ensure we start with a clean slate
docker stop demo-busybox >/dev/null 2>&1 || true
docker rm demo-busybox >/dev/null 2>&1 || true

# 1. Pull the busybox image
pei "docker pull busybox"

# 2. List images to show busybox
pei "docker images"

# 3. Build the custom image
pei "docker build -t custom-busybox ."

# Create a text file in the volume (behind the scenes)
mkdir -p /tmp/demo-volume
echo "Hello from the host side!" >/tmp/demo-volume/hello.txt

pei "cat /tmp/demo-volume/hello.txt"

# 4. Run busybox with a volume mount
pei "docker run -d --name demo-busybox -v /tmp/demo-volume:/data busybox sleep 3600"

# 9. List all containers (including stopped ones)
pei "docker ps -a"

# 6. Verify the file is in the container
pei "docker exec demo-busybox cat /data/hello.txt"

# 7. Execute a command in the running container with proper permissions
pei "docker exec demo-busybox sh -c 'echo \"Hello from busybox!\" > /data/hello.txt'"

pei "cat /tmp/demo-volume/hello.txt"

# 8. Demonstrate interactive shell with listing files
pei "docker exec -it demo-busybox sh -c 'echo \"This is inside busybox\"; ls -l /data; exit'"

# End of demo
echo 'Now you know the basics of using Docker with these commands: pull, build, run, ps, exec, and rm.'

# Remove and clean up all things at the end
docker stop demo-busybox
docker rm demo-busybox
rm -rf /tmp/demo-volume
