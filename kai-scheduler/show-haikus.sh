#!/usr/bin/env bash

while true; do
  clear
  COLS=$(tput cols)

  # Display header - properly centered
  echo ""
  HEADER=$(echo "SRE HORROR HAIKUS" | toilet -f pagga --metal)

  # Get the actual width of the header (longest line)
  HEADER_WIDTH=$(echo "$HEADER" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print length}' | sort -nr | head -1)

  # Calculate padding for centering
  PADDING=$(( (COLS - HEADER_WIDTH) / 2 ))

  # Print header with proper padding
  echo "$HEADER" | while IFS= read -r line; do
    printf "%*s%s\n" $PADDING "" "$line"
  done

  echo ""

  # Display haikus in parchment box with colors
  curl -s http://localhost:5000/haikus | boxes -d parchment -a c -s ${COLS}x20 | while IFS= read -r line; do
    len=$(echo -n "$line" | sed 's/\x1b\[[0-9;]*m//g' | wc -c)
    padding=$(( (COLS - len) / 2 ))
    printf "%${padding}s%s\n" "" "$line"
  done | ccze -A

  # Wait for 5 seconds or 'q' key
  read -t 5 -n 1 key && [[ $key = "q" ]] && break
done