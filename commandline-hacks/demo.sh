#!/usr/bin/env bash

set -eo pipefail

# Add source and line number when running in debug mode
IFS=$'\n\t'

# Source the demo magic script (ensure the correct path)
. ./../__demo_magic.sh

./../__tmux_timer.sh &

TYPE_SPEED=40

clear

# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
# Function to simulate command output
simulate_output() {
	echo "$1"
	sleep 1.5
}

# Start the demo
clear

p "1. Global Aliases for Command Output Processing \n
  alias -g W='| nvim -c -'"
echo 'Hello, World!' >test.txt
p "echo 'Hello, World!' W"
nvim test.txt
clear

p "2. Suffix Aliases for Quick File Opening \n
   alias -s md=nvim \n
   alias -s txt=cat"
p "./sample_markdown.md"
nvim sample_markdown.md
p "./sample_text.txt"
cat sample_text.txt
p ""
clear

p "3. Quick Command Line Editing with Ctrl+X+E \n
   ffmpeg -i input.mp4 -vf scale=1280:720 output.mp4"
nvim ffmpeg.txt
clear

p "4. Essential Keyboard Shortcuts \n
   Ctrl+U: Remove from cursor to start of line \n
   Ctrl+K: Cut from cursor to end of line \n
   Ctrl+A: Go to start of line \n
   Ctrl+E: Go to end of line"
clear

p "5. Brace Expansion for Batch Operations"
pe "touch file{1..3}.txt"
pe "ls file*.txt"
