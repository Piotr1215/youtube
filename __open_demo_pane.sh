#!/bin/bash

# Capture the current session and window name
current_session=$(tmux display-message -p '#S')
current_window=$(tmux display-message -p '#I')
current_pane=$(tmux display-message -p '#P')

# Script path from the input parameter
SCRIPT_PATH="$1"

# Create a new vertical split pane and run the demo script
tmux split-window -h
new_pane=$(tmux display-message -p '#P')
tmux send-keys -t "$new_pane" "bash $SCRIPT_PATH; tmux wait-for -S demo-exit" Enter

# Automatically switch focus to the new pane
tmux select-pane -t "$new_pane"

# Wait for the new pane to signal that the demo script has exited
tmux wait-for demo-exit

# Close the new pane
tmux kill-pane -t "$new_pane"

# Switch back to the original pane
tmux select-pane -t "$current_pane"
