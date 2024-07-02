#!/usr/bin/env bash

set -eo pipefail

# Source the demo magic script
. ./../__demo_magic.sh

./../__tmux_timer.sh &

TYPE_SPEED=50
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

clear

# Basic usage of man
pe "man man"
# Simulate viewing and then quitting

# Viewing man page for ls
pe "man ls"

cat man_sections.txt

# Example of accessing a specific section
p "Using man -f will print short description of the command"
pe "man -f ls"

# Viewing the intro man page
pe "man intro"

p "Using man -k will search for a keyword in command descriptions"
pe "man -k directory"
clear

p "Using apropos to search in specific section"
pe "apropos -s 1 . | grep zsh"
