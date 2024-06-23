#!/usr/bin/env bash

TIMER_DURATION=60

for ((i = TIMER_DURATION; i >= 0; i--)); do
	# Set the timer without any additional formatting
	tmux set -g status-right "$i sec"
	sleep 1
done

# Set the final message when the timer is done
tmux set -g status-right "00 sec"
