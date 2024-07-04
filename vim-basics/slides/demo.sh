#!/usr/bin/env bash

# Add source and line number when running in debug mode: bash -xv demo.sh
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
	echo "And we are done" | figlet -f pagga | boxes -d peek
else
	echo "VIM DEMO"
fi
