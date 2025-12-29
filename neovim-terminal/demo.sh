#!/usr/bin/env bash
# Demo script for neovim terminal presentation
#
# Run with <leader>ef to execute and see output
# Or :R ./demo.sh to run in scratch buffer

set -euo pipefail

echo "Hello from neovim terminal!"
echo "Current directory: $(pwd)"
echo "Date: $(date +%Y-%m-%d)"
