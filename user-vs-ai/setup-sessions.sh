#!/bin/bash
set -euo pipefail

# Kill existing sessions if they exist to ensure clean start
for session in "user-session" "ai-session"; do
  if tmux has-session -t "$session" 2>/dev/null; then
    echo "Killing existing $session tmux session..."
    tmux kill-session -t "$session"
  fi
done

echo "Creating new human session..."
# Create human session
tmux new-session -d -s "user-session" -n "HUMAN"
# Split into 2 panes - horizontally with equal space
tmux split-window -h -p 50 -t "user-session:1"
# Configure each pane
tmux send-keys -t "user-session:1.1" "echo 'HUMAN WORKSPACE'" C-m
tmux send-keys -t "user-session:1.2" "echo 'HUMAN PROGRESS'" C-m
# Select the first pane
tmux select-pane -t "user-session:1.1"
echo "Human session created successfully."

echo "Creating new AI session..."
# Create AI session
tmux new-session -d -s "ai-session" -n "AI"
# Split into 2 panes - horizontally with equal space
tmux split-window -h -p 50 -t "ai-session:1"
# Configure each pane
tmux send-keys -t "ai-session:1.1" "echo 'AI WORKSPACE'" C-m
tmux send-keys -t "ai-session:1.2" "echo 'AI PROGRESS'" C-m
# Select the first pane
tmux select-pane -t "ai-session:1.1"
echo "AI session created successfully."

# Provide guidance if already in a tmux session
if [[ -n "${TMUX:-}" ]]; then
  echo "Already in a tmux session."
  echo "Use 'tmux switch-client -t user-session' to switch to the human session"
  echo "Use 'tmux switch-client -t ai-session' to switch to the AI session"
  echo "Or exit current tmux session first with Ctrl+b d"
fi