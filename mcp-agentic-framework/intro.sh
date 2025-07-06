#!/usr/bin/env bash
set -euo pipefail

# Default title if not provided
TITLE="${1:-MCP Agentic Framework}"

# Clear screen
clear

# Check if toilet is available for fancy ASCII art
if command -v toilet &> /dev/null; then
    # Use toilet with a nice font
    toilet -f future --metal "$TITLE"
else
    # Fallback to figlet if available
    if command -v figlet &> /dev/null; then
        figlet -c "$TITLE"
    else
        # Ultimate fallback - just echo with some decoration
        echo
        echo "=================================="
        echo "     $TITLE"
        echo "=================================="
        echo
    fi
fi

# Add subtitle
echo
echo "     Multi-Agent Collaboration Made Simple"
echo "     ─────────────────────────────────────"
echo
echo "          🤖 → 💬 → 🤖 → 💬 → 🤖"
echo
echo "     Press any key to start..."
read -n 1 -s