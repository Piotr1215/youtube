#!/usr/bin/env bash

set -eo pipefail

# Add source and line number when running in debug mode: __run_with_xtrace.sh generate_tmux_sessions.sh
# Set new line and tab for word splitting
IFS=$'\n\t'

# Function to create tmux sessions in the current directory
generate_sessions() {
	local current_dir=$(pwd)

	for session in "$@"; do
		if tmux has-session -t "$session" 2>/dev/null; then
			echo "Session '$session' already exists."
		else
			tmux new-session -d -s "$session" -c "$current_dir"
			echo "Created tmux session: $session"
		fi
	done
}

# Function to close (kill) tmux sessions
close_sessions() {
	for session in "$@"; do
		if tmux has-session -t "$session" 2>/dev/null; then
			tmux kill-session -t "$session"
			echo "Closed tmux session: $session"
		else
			echo "Session '$session' does not exist."
		fi
	done
}

# Function to list all tmux sessions
list_sessions() {
	echo "Current tmux sessions:"
	tmux list-sessions 2>/dev/null || echo "No active tmux sessions."
}

# Main logic
case "$1" in
start)
	shift
	if [ $# -eq 0 ]; then
		echo "Error: No session names provided."
		echo "Usage: $0 start <session_name> [<session_name> ...]"
		exit 1
	fi
	generate_sessions "$@"
	;;
stop)
	shift
	if [ $# -eq 0 ]; then
		echo "Error: No session names provided."
		echo "Usage: $0 stop <session_name> [<session_name> ...]"
		exit 1
	fi
	close_sessions "$@"
	;;
list)
	list_sessions
	;;
*)
	echo "Usage: $0 {start|stop|list} [session_name ...]"
	echo "  start: Create new tmux sessions"
	echo "  stop: Close existing tmux sessions"
	echo "  list: Show all active tmux sessions"
	exit 1
	;;
esac
