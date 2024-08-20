#!/usr/bin/env bash

title="Neovim Keybindings"

if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
	echo "$title" | figlet -f slant -w 200 | boxes -d peek
else
	echo "$title"
fi
