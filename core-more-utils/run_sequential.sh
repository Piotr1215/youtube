#!/bin/bash

# File to log the results
LOG_FILE="sequential_output.log"

# Clear any existing log file
>"$LOG_FILE"

# Run 50 curl requests sequentially, logging output, and tail the log file
{ time for i in $(seq 1 50); do
	curl -s -o /dev/null -w "Request $i: %{http_code}\n" https://example.com >>"$LOG_FILE"
done & } &&
	tail -f "$LOG_FILE"
