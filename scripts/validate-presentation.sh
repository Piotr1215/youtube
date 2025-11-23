#!/usr/bin/env bash
# Validate presentation formatting rules

set -eo pipefail

PRESENTATION_FILE="${1:-presentation.md}"

if [[ ! -f "$PRESENTATION_FILE" ]]; then
  echo "❌ File not found: $PRESENTATION_FILE"
  exit 1
fi

echo "🔍 Validating: $PRESENTATION_FILE"
echo ""

ERRORS=0

# Check for plain bullet lists outside code blocks
echo "Checking for plain bullet lists (should be in code blocks)..."

# This regex finds lines starting with - or * that are NOT inside code blocks
# We check if a line with bullet is between ``` markers
IN_CODE_BLOCK=false
IN_HEREDOC=false
LINE_NUM=0

while IFS= read -r line; do
  ((LINE_NUM++))

  # Track heredoc state
  if [[ "$line" =~ cat.*\<\<.*EOF ]] || [[ "$line" =~ \<\<.*\'EOF\' ]]; then
    IN_HEREDOC=true
  fi
  if [[ "$IN_HEREDOC" == "true" ]] && [[ "$line" =~ ^EOF ]]; then
    IN_HEREDOC=false
  fi

  # Track code block state
  if [[ "$line" =~ ^\`\`\` ]]; then
    if [[ "$IN_CODE_BLOCK" == "true" ]]; then
      IN_CODE_BLOCK=false
    else
      IN_CODE_BLOCK=true
    fi
  fi

  # Check for bullet lists outside code blocks (and not in heredocs)
  if [[ "$IN_CODE_BLOCK" == "false" ]] && [[ "$IN_HEREDOC" == "false" ]] && [[ "$line" =~ ^[[:space:]]*[-\*][[:space:]] ]]; then
    # Skip if it's inside a table (preceded by |)
    if [[ ! "$line" =~ ^\| ]]; then
      echo "  ❌ Line $LINE_NUM: Plain bullet list found (should be in code block)"
      echo "     $line"
      ((ERRORS++))
    fi
  fi
done < "$PRESENTATION_FILE"

# Check for multi-line blockquotes (sandwich pattern)
echo ""
echo "Checking for multi-line blockquotes (sandwich pattern)..."

PREV_LINE=""
PREV_PREV_LINE=""
LINE_NUM=0

while IFS= read -r line; do
  ((LINE_NUM++))

  # Detect sandwich: > ... code block ... >
  if [[ "$PREV_PREV_LINE" =~ ^\> ]] && [[ "$PREV_LINE" =~ ^\`\`\` ]] && [[ "$line" =~ ^\> ]]; then
    echo "  ❌ Line $LINE_NUM: Sandwich pattern detected (blockquote → code → blockquote)"
    ((ERRORS++))
  fi

  PREV_PREV_LINE="$PREV_LINE"
  PREV_LINE="$line"
done < "$PRESENTATION_FILE"

# Check for missing <!-- end_slide -->
echo ""
echo "Checking for slides without <!-- end_slide -->..."

SLIDE_COUNT=$(grep -c "^##" "$PRESENTATION_FILE" || true)
END_SLIDE_COUNT=$(grep -c "<!-- end_slide -->" "$PRESENTATION_FILE" || true)

if [[ $SLIDE_COUNT -ne $END_SLIDE_COUNT ]]; then
  echo "  ❌ Mismatch: $SLIDE_COUNT slides but $END_SLIDE_COUNT end_slide markers"
  ((ERRORS++))
fi

# Check figlet centering flags
echo ""
echo "Checking figlet commands for centering flags..."

while IFS= read -r line_content; do
  if [[ "$line_content" =~ figlet ]] && [[ ! "$line_content" =~ -c.*-w[[:space:]]90 ]]; then
    echo "  ❌ figlet without '-c -w 90' flags: $line_content"
    ((ERRORS++))
  fi
done < <(grep "figlet" "$PRESENTATION_FILE" || true)

# Summary
echo ""
echo "════════════════════════════════════════"
if [[ $ERRORS -eq 0 ]]; then
  echo "✅ All validation checks passed!"
  exit 0
else
  echo "❌ Found $ERRORS formatting issues"
  exit 1
fi
