#!/usr/bin/env bash

set -eo pipefail

# Add source and line number wher running in debug mode: __run_with_xtrace.sh generate_tmux_sessions.sh
# Set new line and tab for word splitting
IFS=$'\n\t'

# Declare an array to store session names from arguments
sessions=("$@")

# Function to create tmux sessions in the current directory
generate_sessions() {
	local current_dir=$(pwd)

	for session in "${sessions[@]}"; do
		tmux new-session -d -s "$session" -c "$current_dir"
		echo "Created tmux session: $session"
	done
}

# Function to close (kill) tmux sessions
close_sessions() {
	for session in "${sessions[@]}"; do
		tmux kill-session -t "$session" 2>/dev/null || echo "Session $session does not exist."
		echo "Closed tmux session: $session"
	done
}

# Call functions based on the argument provided
if [[ "$1" == "start" ]]; then
	shift
	generate_sessions "$@"
elif [[ "$1" == "stop" ]]; then
	shift
	close_sessions "$@"
else
	echo "Usage: $0 {start|stop} session1 session2 ..."
fi
