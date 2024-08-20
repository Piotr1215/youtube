#!/usr/bin/env bash
set -eo pipefail
IFS=$'\n\t'
. ./../__demo_magic.sh
TYPE_SPEED=30
CLEAR_SCREEN=true
clear
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

pe "combine ./syslog_day1.txt and ./syslog_day2.txt"
pe "combine ./syslog_day1.txt or ./syslog_day2.txt"
pe "combine ./syslog_day1.txt xor ./syslog_day2.txt"
pe "combine ./syslog_day1.txt not ./syslog_day2.txt"
