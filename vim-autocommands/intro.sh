#!/usr/bin/env bash

title="Neovim Autocommands"

if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
	echo "$title" | figlet -f big | boxes -d peek
else
	echo "$title"
fi
