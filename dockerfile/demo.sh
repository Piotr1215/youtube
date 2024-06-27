#!/usr/bin/env bash
set -eo pipefail
# Add source and line number when running in debug mode
IFS=$'\n\t'
# Source the demo magic script (ensure the correct path)
. ./../__demo_magic.sh
./../__tmux_timer.sh &
TYPE_SPEED=30
# Create main.py
echo 'print("Hello from main.py!")' >src/main.py

# Create another_script.py
echo 'print("This is another_script.py!")' >src/another_script.py

clear
# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Show the Dockerfile
nvim -c 'SimulateTyping ./Example/Dockerfile 30' Dockerfile

# Build the Docker image
p "docker build -t myimage ."
docker build -t myimage .

# Run the container with default CMD
pei "docker run myimage"

# Show the contents of the new script
pe "cat src/another_script.py"

# Run the container with the new script
pei "docker run myimage another_script.py"

# Demonstrate how to override ENTRYPOINT
pei "docker run --entrypoint /bin/bash myimage -c 'echo Hello from bash!'"

rm src/another_script.py
rm Dockerfile
