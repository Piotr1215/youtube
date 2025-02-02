#!/bin/bash
set -euo pipefail

command -v gh >/dev/null 2>&1 || {
	echo "Error: 'gh' is not installed." >&2
	exit 1
}
command -v jq >/dev/null 2>&1 || {
	echo "Error: 'jq' is not installed." >&2
	exit 1
}

ISSUES_FILE="$HOME/github_issues.json"

TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

gh api -X GET /search/issues -f q='is:issue is:open author:@me' --jq '
  [ .items[] | {
      id: .number,
      description: .title,
      repository: .repository_url,
      html_url: .html_url
    }
  ]
' >"$TEMP_FILE"

if [[ ! -f "$ISSUES_FILE" ]]; then
	mv "$TEMP_FILE" "$ISSUES_FILE"
	trap - EXIT
	echo "Initial issues file created."
	exit 0
fi

# Check if the stored issues file is a JSON array by inspecting its first character.
if [[ "$(head -c1 "$ISSUES_FILE")" != "[" ]]; then
	echo "Warning: The stored issues file is not in the expected format. Replacing it with new data."
	mv "$TEMP_FILE" "$ISSUES_FILE"
	trap - EXIT
	exit 0
fi

NEW_ISSUES=$(jq -s ' (.[0] | map(.id)) as $old_ids | .[1] | map(select(.id as $id | ($old_ids | index($id) | not)))
' "$ISSUES_FILE" "$TEMP_FILE")

if (($(jq 'length' <<<"$NEW_ISSUES") > 0)); then
	# Create notification message
	NOTIFICATION_MSG=$(jq -r '.[] | "• \(.description)"' <<<"$NEW_ISSUES" | head -n 3)
	ISSUE_COUNT=$(jq 'length' <<<"$NEW_ISSUES")

	if ((ISSUE_COUNT > 3)); then
		NOTIFICATION_MSG+=$'\n'"... and $((ISSUE_COUNT - 3)) more"
	fi

	notify-send -u normal "New GitHub Issues ($ISSUE_COUNT)" "$NOTIFICATION_MSG"

	echo "New issues:"
	jq -r '.[] | "- \(.description) (\(.html_url))"' <<<"$NEW_ISSUES"
	echo "Issues file updated."
else
	echo "No new issues."
	notify-send -u normal "No new issues"

fi

mv "$TEMP_FILE" "$ISSUES_FILE"
trap - EXIT
