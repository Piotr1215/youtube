#!/usr/bin/env bash
set -euo pipefail

# Demo script for AI Tool Builder presentation

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== AI Tool Builder Demo ===${NC}"
echo -e "${YELLOW}Building Code Intelligence with ast-grep + LuaSnip${NC}\n"

# Create tmux session for demo
tmux new-session -d -s error-handling-demo

# Window 1: Show bad code
tmux send-keys -t error-handling-demo "nvim example_bad.go" C-m
sleep 1

# Window 2: Run ast-grep
tmux new-window -t error-handling-demo -n "ast-grep"
tmux send-keys -t error-handling-demo:ast-grep "clear" C-m
tmux send-keys -t error-handling-demo:ast-grep "echo -e '${GREEN}Finding error handling issues...${NC}'" C-m
tmux send-keys -t error-handling-demo:ast-grep "sg scan -r ast-grep-rules.yml example_bad.go" C-m

# Window 3: Show LuaSnip config
tmux new-window -t error-handling-demo -n "snippets"
tmux send-keys -t error-handling-demo:snippets "nvim luasnip-go-errors.lua" C-m

# Window 4: Fix with snippets
tmux new-window -t error-handling-demo -n "fix"
tmux send-keys -t error-handling-demo:fix "cp example_bad.go example_fixed.go" C-m
tmux send-keys -t error-handling-demo:fix "nvim example_fixed.go" C-m

# Switch to first window
tmux select-window -t error-handling-demo:0

echo -e "\n${GREEN}Demo session created!${NC}"
echo -e "Run: ${BLUE}tmux attach -t error-handling-demo${NC}\n"
echo -e "Windows:"
echo -e "  1. Bad code example"
echo -e "  2. ast-grep analysis" 
echo -e "  3. LuaSnip configuration"
echo -e "  4. Fixing with snippets"