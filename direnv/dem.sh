#!/usr/bin/env bash
set -eo pipefail
. ./../__demo_magic.sh
TYPE_SPEED=15
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Cleanup function
cleanup() {
	# Remove the test directory if it exists
	rm -rf ./test_direnv
	# Clear direnv allow list for this directory
	direnv_allow_path=$(direnv allow -p ./test_direnv/.envrc 2>/dev/null || true)
	if [ -n "$direnv_allow_path" ]; then
		rm -f "$direnv_allow_path"
	fi
}

# Run cleanup
cleanup

# Create test directory and .envrc file
mkdir -p ./test_direnv
echo 'export TEST_VAR="Hello, Direnv!"' >./test_direnv/.envrc

# Explicitly deny the .envrc to ensure we start in a clean state
direnv deny ./test_direnv

# Function to change directory and capture direnv message
cd_with_direnv() {
	cd "$1"
	direnv_output=$(direnv export bash 2>&1 >/dev/null)
	if [[ -n "$direnv_output" ]]; then
		echo "$direnv_output"
	fi
}

# Change directory and show direnv message
pei "cd_with_direnv ./test_direnv"

# Show current directory and TEST_VAR value
pei "pwd && echo TEST_VAR=\$TEST_VAR"

# Allow the .envrc file
pe "direnv allow"

# Change back to parent directory
pei "cd .."

# Change to test_direnv again to see the difference
pei "cd_with_direnv ./test_direnv"

# Show current directory and TEST_VAR value after allowing .envrc
pei "pwd && echo TEST_VAR=\$TEST_VAR"

echo "test completed!"

# Run cleanup again to leave a clean state
cleanup
