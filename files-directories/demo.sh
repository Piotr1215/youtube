#!/usr/bin/env bash

set -eo pipefail

# Add source and line number when running in debug mode
IFS=$'\n\t'

# Source the demo magic script (ensure the correct path)
. ./../__demo_magic.sh

./../__tmux_timer.sh &

TYPE_SPEED=15

clear

# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Create a new directory
pei "mkdir my_demo_directory"

# Navigate into the new directory
pei "cd my_demo_directory"

# Create a new file
pei "touch my_demo_file.txt"

# List the contents to verify
pei "ls -l"

# Write text to the new file
pei "echo 'Hello, World!' > my_demo_file.txt"

# Display the content of the file
pei "cat my_demo_file.txt"

# Rename the file
pei "mv my_demo_file.txt my_renamed_file.txt"

# List the contents to verify
pei "ls -l"

# Create a subdirectory
pei "mkdir my_subdirectory"

# List the contents to verify
pei "ls -l"

# Move the renamed file to the subdirectory
pei "mv my_renamed_file.txt my_subdirectory/"

# List files in the subdirectory with details
pei "ls -l my_subdirectory"

# Navigate back to the parent directory
pei "cd .."

# Remove the directory and its contents
pei "rm -r my_demo_directory"

# List the contents to verify
pei "ls -l"
