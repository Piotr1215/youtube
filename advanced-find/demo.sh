#!/usr/bin/env bash
set -eo pipefail
# Source the demo magic script
. ./../__demo_magic.sh
# Start the tmux timer
./../__tmux_timer.sh &
# Set the typing speed for the demo
TYPE_SPEED=20
CLEAR_SCREEN=true
# Clear the screen before starting the demo
clear
# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
# Prepare
mkdir -p /tmp/find_demo
cd /tmp/find_demo
mkdir -p dir1 dir2 dir3
# Add script.sh file and make it executable
echo '#!/bin/bash\necho "Hello from script.sh"' >dir2/script.sh
chmod +x dir2/script.sh
# Make all the *.txt files contain some random text so they are not empty
echo "Random text 1" >file1.txt
echo "Random text 2" >file2.txt
echo "Log entry" >file3.log
echo "Nested text 1" >dir1/nested1.txt
echo "Nested log entry" >dir2/nested2.log
echo "Old file content" >dir3/old_file.txt
touch -t 202201010000 dir3/old_file.txt
# List the directory structure
pe "exa --tree --color=always"
# 1. Find files by name with multiple patterns
pe "find . -name '*.log'"
# 4. Find files with specific permissions (executable)
pe "find . -type f -executable"
# 6. Find files and execute a command on them
pe "find . -type f -name '*.txt'
    -exec echo 'Found file: {}' \;"
# 7. Find files larger than a certain size
dd if=/dev/zero of=largefile bs=1M count=5
pe "find . -type f -size +1M"
# 8. Find files and change their permissions
pe "find . -type f -name '*.txt' 
    -exec chmod u=rw,go-rwx {} +"
# 9. Find files newer than a specific date
# The -newer option compares modification times. It finds files modified more recently than the reference file.
pe "find . -type f -newer dir3/old_file.txt"
# 10. Find and sort files by modification time (simpler version)
pe "find . -type f -exec du -h {} + | sort -h"
# Cleanup
cd ..
rm -rf find_demo
