#!/usr/bin/env bash

title="Zsh Tricks Grab-bag"

if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
	echo "$title" | figlet -f big | boxes -d peek
else
	echo "$title"
fi
