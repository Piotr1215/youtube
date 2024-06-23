#!/usr/bin/env bash

set -eo pipefail

# Add source and line number when running in debug mode
IFS=$'\n\t'

# Source the demo magic script (ensure the correct path)
. ./../__demo_magic.sh

TYPE_SPEED=30

clear

# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Change to the /tmp directory
pei "cd /tmp"

# Traditional find vs modern fd (one level deep)
pe "find . -maxdepth 1 -name '*.txt'"
pe "fd . --max-depth 1 --extension txt"

# Traditional sed vs modern sd
pe "echo 'Hello World' | sed 's/World/Universe/'"
pe "echo 'Hello World' | sd 'World' 'Universe'"

# Traditional ls vs modern exa
pe "\ls -l"
pe "exa -l"

# Traditional cat vs modern bat
echo "Hello World" >README.md
pe "cat README.md"
pe "bat README.md"

# Traditional grep vs modern ripgrep (rg)
echo "Hello World" >example.txt
pe "grep 'World' example.txt"
pe "rg 'World' example.txt"

# Traditional diff vs modern delta
echo "Hello Universe" >example2.txt
pe "diff example.txt example2.txt"
pe "delta example.txt example2.txt"

# Generate and display a markdown table using glow
echo '
| Traditional Tool | Modern Alternative |
|------------------|--------------------|
| ls               | exa                |
| find             | fd                 |
| sed              | sd                 |
| cat              | bat                |
| grep             | ripgrep (rg)       |
| du               | dust               |
| diff             | delta              |
' >tools.md

pe "glow tools.md"

# Cleanup
rm README.md example.txt example2.txt tools.md
