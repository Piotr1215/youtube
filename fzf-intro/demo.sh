#!/usr/bin/env bash

set -eo pipefail

# Add source and line number when running in debug mode
IFS=$'\n\t'

# Source the demo magic script (ensure the correct path)
. ./../__demo_magic.sh

./../__tmux_timer.sh &

TYPE_SPEED=20
CLEAR_SCREEN=true

clear

# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

rm file1.txt file2.txt file3.txt .hiddenfile >/dev/null 2>&1 || true
rm -r subdir >/dev/null 2>&1 || true
# Create a sample directory structure for demonstration
echo "Creating some sample files for the demo..."
echo 'This is file1' >file1.txt
echo 'This is file2' >file2.txt
echo 'This is file3' >file3.txt
echo 'This is a hidden file' >.hiddenfile
mkdir subdir && echo 'This is file in subdir' >subdir/file4.txt

# Launch fzf in the terminal with the picker on the top
pei "fzf --reverse | xargs stat"

# Use fzf to open a file in vim
pei "nvim \$(fzf --reverse)"

# Use fzf to fuzzy-find and kill processes
pei "ps aux | fzf | awk '{print \$2}'"

# Use fzf for interactive cd into a directory
pei "cd \$(find * -type d | fzf)"

# Use fzf with git branch to switch branches
pei "git log --oneline | fzf"

# Use fzf to find content in all files in current dir
pei "cat \$(fzf --reverse)"

pei "f=\$(fzf --reverse) && cp "\$f" "\$f.bak""
pei "ls -l"

# Cleanup demo directory

# End of demo
echo 'Now you know the basics of using fzf, so go ahead and make your workflow smoother and faster.'
