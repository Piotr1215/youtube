#!/usr/bin/env bash

title="Multi-container development env with incus"

if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
	echo "$title" | figlet -f big -w 100 | boxes -d peek
else
	echo "$title"
fi
