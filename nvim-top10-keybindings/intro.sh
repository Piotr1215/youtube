#!/usr/bin/env bash

title="My top 10 key bindings in Neovim"

if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
	echo "$title" | figlet -f big | boxes -d peek
else
	echo "$title"
fi
