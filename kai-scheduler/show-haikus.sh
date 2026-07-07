#!/usr/bin/env bash

# Strip ANSI colour codes so width math counts glyphs, not escape sequences.
strip_ansi() { sed 's/\x1b\[[0-9;]*m//g'; }

while true; do
  clear
  COLS=$(tput cols)

  # Title. wc -L measures DISPLAY columns; the pagga font uses multi-byte block
  # glyphs, so awk/wc -c would count bytes and push the title off-centre.
  echo ""
  HEADER=$(echo "SRE HORROR HAIKUS" | toilet -f pagga --metal)
  HEADER_WIDTH=$(printf '%s\n' "$HEADER" | strip_ansi | wc -L)
  PADDING=$(( (COLS - HEADER_WIDTH) / 2 ))
  (( PADDING < 0 )) && PADDING=0
  printf '%s\n' "$HEADER" | while IFS= read -r line; do
    printf "%*s%s\n" "$PADDING" "" "$line"
  done

  echo ""

  # Parchment box sized to the haikus, block-centred with ONE shared pad so the
  # box keeps its shape and sits on the same centre axis as the title.
  BOX=$(curl -s http://localhost:5000/haikus | boxes -d parchment -a c)
  BOX_WIDTH=$(printf '%s\n' "$BOX" | strip_ansi | wc -L)
  BOX_PAD=$(( (COLS - BOX_WIDTH) / 2 ))
  (( BOX_PAD < 0 )) && BOX_PAD=0
  printf '%s\n' "$BOX" | while IFS= read -r line; do
    printf "%*s%s\n" "$BOX_PAD" "" "$line"
  done | ccze -A

  # Wait for 5 seconds or 'q' key
  read -t 5 -n 1 key && [[ $key = "q" ]] && break
done
