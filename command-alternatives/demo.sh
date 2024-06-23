#!/usr/bin/env bash

set -eo pipefail

# Add source and line number when running in debug mode
IFS=$'\n\t'

# Source the demo magic script (ensure the correct path)
. ./../__demo_magic.sh

./../__tmux_timer.sh &

TYPE_SPEED=10

clear

# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Change to the /tmp directory
pe "cd /tmp"

# Traditional find vs modern fd (one level deep)
pei "find . -maxdepth 1 -name '*.txt'"
pei "fd . --max-depth 1 --extension txt"

# Traditional sed vs modern sd
pei "echo 'Hello World' | sed 's/World/Universe/'"
pei "echo 'Hello World' | sd 'World' 'Universe'"

# Traditional ls vs modern exa
pei "\ls -l"
pei "exa -l"

# Traditional cat vs modern bat
echo "Hello World" >README.md
pei "cat README.md"
pei "bat README.md"

# Traditional grep vs modern ripgrep (rg)
echo "Hello World" >example.txt
pei "grep 'World' example.txt"
pei "rg 'World' example.txt"

# Generate and display a markdown table using glow
echo '
| Traditional Tool | Modern Alternative |
|------------------|--------------------|
| ls               | exa                |
| find             | fd                 |
| sed              | sd                 |
| cat              | bat                |
| grep             | ripgrep (rg)       |
' >tools.md

glow tools.md

# Cleanup
rm README.md example.txt tools.md
