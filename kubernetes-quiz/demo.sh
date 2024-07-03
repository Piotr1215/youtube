#!/usr/bin/env bash
set -eo pipefail

# Source the demo magic script
. ./../__demo_magic.sh

./../__tmux_timer.sh &

TYPE_SPEED=20

clear

# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

p "Do you think you can answer these questions? \n
   Only one answer is correct \n
   comment below how many you got right!"

# Use repl to allow for interactive command execution
# repl
../__questions.sh ./questions.txt
