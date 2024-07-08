#!/usr/bin/env bash
set -eo pipefail
. ./../__demo_magic.sh
TYPE_SPEED=15
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Setup test environment
mkdir -p ./test_direnv
cd ./test_direnv
echo 'export TEST_VAR="Hello, Direnv!"' >./.envrc

# Explicitly deny the .envrc
direnv deny 2>/dev/null || true

p "we are in test_direnv directory with the .envrc file with"
bat ./.envrc

# Reload the shell to apply changes
pe "eval \"\$(direnv export bash)\""

# Show current directory and TEST_VAR value
pe "echo TEST_VAR=\$TEST_VAR"

# Allow the .envrc file
pe "direnv allow"

# Reload the shell to apply changes
pe "eval \"\$(direnv export bash)\""

# Show current directory and TEST_VAR value after allowing .envrc
pe "echo TEST_VAR=\$TEST_VAR"
