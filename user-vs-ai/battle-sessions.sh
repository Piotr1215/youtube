#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <exercise_name>"
    echo "Available exercises:"
    ls -1 exercises/
    exit 1
fi

exercise_name=$1

if [ ! -d "exercises/$exercise_name" ]; then
    echo "Error: Exercise '$exercise_name' not found."
    echo "Available exercises:"
    ls -1 exercises/
    exit 1
fi

# Create working directories if they don't exist
mkdir -p workspaces/human workspaces/ai

# Get instructions
if [ -f "exercises/$exercise_name/instructions" ]; then
    task_description=$(cat --pager never "exercises/$exercise_name/instructions")
else 
    task_description=$(head -1 "exercises/$exercise_name/start")
fi

# Copy the exercise file to both workspaces
cp "exercises/$exercise_name/start" workspaces/human/exercise
cp "exercises/$exercise_name/start" workspaces/ai/exercise

# Copy instructions
cp "exercises/$exercise_name/instructions.txt" workspaces/human/instructions.txt
cp "exercises/$exercise_name/instructions.txt" workspaces/ai/instructions.txt

solution_file="exercises/$exercise_name/solution"

# Ensure tmux sessions exist
./setup-sessions.sh

# Setup human session
tmux send-keys -t user-session:1.1 "cd $(pwd)/workspaces/human && clear" C-m
tmux send-keys -t user-session:1.1 "cat --pager never instructions.txt" C-m

tmux send-keys -t user-session:1.2 "cd $(pwd) && clear" C-m
tmux send-keys -t user-session:1.2 "echo 'Exercise: $exercise_name - Human Progress'" C-m
tmux send-keys -t user-session:1.2 "echo 'Task: $task_description'" C-m
tmux send-keys -t user-session:1.2 "while true; do clear; echo 'HUMAN PROGRESS:'; if cmp -s -b workspaces/human/exercise '$solution_file'; then echo '✅ COMPLETED!' | lolcat; else diff -Bbw -I '^$' workspaces/human/exercise '$solution_file' | diff-so-fancy; fi; sleep 2; done" C-m

# Setup AI session
tmux send-keys -t ai-session:1.1 "cd $(pwd)/workspaces/ai && clear" C-m
tmux send-keys -t ai-session:1.1 "echo 'AI Workspace - Exercise: $exercise_name'" C-m
tmux send-keys -t ai-session:1.1 "echo 'Task: $task_description'" C-m
tmux send-keys -t ai-session:1.1 "cat --pager never exercise" C-m
tmux send-keys -t ai-session:1.1 "echo 'Opening the AI assistant...'" C-m
tmux send-keys -t ai-session:1.1 "cd $(pwd)/workspaces/ai" C-m
tmux send-keys -t ai-session:1.1 "echo 'Exercise instructions:'" C-m
tmux send-keys -t ai-session:1.1 "cat --pager never instructions.txt" C-m
tmux send-keys -t ai-session:1.1 "claude \"Please read the instructions from the file 'instructions.txt' in this directory and follow them to complete the exercise.\"" C-m

tmux send-keys -t ai-session:1.2 "cd $(pwd) && clear" C-m
tmux send-keys -t ai-session:1.2 "echo 'Exercise: $exercise_name - AI Progress'" C-m
tmux send-keys -t ai-session:1.2 "echo 'Task: $task_description'" C-m
tmux send-keys -t ai-session:1.2 "while true; do clear; echo 'AI PROGRESS:'; if cmp -s -b workspaces/ai/exercise '$solution_file'; then echo '✅ COMPLETED!' | lolcat; else diff -Bbw -I '^$' workspaces/ai/exercise '$solution_file' | diff-so-fancy; fi; sleep 2; done" C-m

# Session navigation instructions
echo "=================================================="
echo "Sessions prepared!"
echo ""
echo "If outside tmux:"
echo "  tmux attach-session -t user-session  # For human session"
echo "  tmux attach-session -t ai-session    # For AI session"
echo ""
echo "If inside tmux:"
echo "  tmux switch-client -t user-session   # For human session"
echo "  tmux switch-client -t ai-session     # For AI session"
echo "=================================================="

# Auto-attach to human session if not in tmux
if [[ -z "${TMUX:-}" ]]; then
  echo "Attaching to human session..."
  tmux attach-session -t user-session
fi