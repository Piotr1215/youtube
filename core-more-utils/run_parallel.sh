#!/bin/bash

# File to log the results
LOG_FILE="parallel_output.log"

# Clear any existing log file
>"$LOG_FILE"

# Run 50 curl requests in parallel, logging output, and tail the log file
{ time seq 1 50 | parallel --eta -j 10 "curl -s -o /dev/null -w 'Request {}: %{http_code}\n' https://example.com" >>"$LOG_FILE" & } &&
	tail -f "$LOG_FILE"
