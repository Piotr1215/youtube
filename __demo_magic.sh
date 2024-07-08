#!/usr/bin/env bash

# the speed to simulate typing the text
TYPE_SPEED=20

# no wait after "p" or "pe"
NO_WAIT=false

# if > 0, will pause for this amount of seconds before automatically proceeding with any p or pe
PROMPT_TIMEOUT=0

# don't show command number unless user specifies it
SHOW_CMD_NUMS=false

# handy color vars for pretty prompts
BLACK="\033[0;30m"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
GREY="\033[0;90m"
CYAN="\033[0;36m"
RED="\033[0;31m"
PURPLE="\033[0;35m"
BROWN="\033[0;33m"
WHITE="\033[0;37m"
BOLD="\033[1m"
COLOR_RESET="\033[0m"

C_NUM=0

# prompt and command color which can be overriden
DEMO_PROMPT="$ "
DEMO_CMD_COLOR=$BOLD
DEMO_COMMENT_COLOR=$GREY

# variable to control output redirection
NO_OUTPUT=false
FIRST_COMMAND=true

# Function to clear the screen
clear_screen() {
	clear
}
##
# prints the script usage
##
function usage() {
	echo -e ""
	echo -e "Usage: $0 [options]"
	echo -e ""
	echo -e "  Where options is one or more of:"
	echo -e "  -h  Prints Help text"
	echo -e "  -d  Debug mode. Disables simulated typing"
	echo -e "  -n  No wait"
	echo -e "  -w  Waits max the given amount of seconds before "
	echo -e "      proceeding with demo (e.g. '-w5')"
	echo -e "  -o  No output mode. Redirects command output to /dev/null"
	echo -e ""
}

##
# wait for user to press ENTER
# if $PROMPT_TIMEOUT > 0 this will be used as the max time for proceeding automatically
##
function wait() {
	if [[ "$PROMPT_TIMEOUT" == "0" ]]; then
		read -rs
	else
		read -rst "$PROMPT_TIMEOUT"
	fi
}

##
# print command only. Useful for when you want to pretend to run a command
#
# takes 1 param - the string command to print
#
# usage: p "ls -l"
#
##
function p() {
	if [[ ${1:0:1} == "#" ]]; then
		cmd=$DEMO_COMMENT_COLOR$1$COLOR_RESET
	else
		cmd=$DEMO_CMD_COLOR$1$COLOR_RESET
	fi

	# render the prompt
	x=$(PS1="$DEMO_PROMPT" "$BASH" --norc -i </dev/null 2>&1 | sed -n '${s/^\(.*\)exit$/\1/p;}')

	# show command number is selected
	if $SHOW_CMD_NUMS; then
		printf "[$((++C_NUM))] $x"
	else
		printf "$x"
	fi

	# wait for the user to press a key before typing the command
	if [ $NO_WAIT = false ]; then
		wait
	fi

	if [[ -z $TYPE_SPEED ]]; then
		echo -en "$cmd"
	else
		echo -en "$cmd" | pv -qL $(($TYPE_SPEED + (-2 + RANDOM % 5)))
	fi

	# wait for the user to press a key before moving on
	if [ $NO_WAIT = false ]; then
		wait
	fi
	echo ""
}

##
# Prints and executes a command
#
# takes 1 parameter - the string command to run
#
# usage: pe "ls -l"
#
##
function pe() {
	if [ "$FIRST_COMMAND" = false ] && [ "$CLEAR_SCREEN" = true ]; then
		clear_screen
	fi
	FIRST_COMMAND=false

	# print the command
	p "$@"
	run_cmd "$@"

	# print dashes and wait for user input before proceeding
	read -r -s
	echo # Add a newline after user presses Enter
}

function pem() {
	# Display the prompt
	x=$(PS1="$DEMO_PROMPT" "$BASH" --norc -i </dev/null 2>&1 | sed -n '${s/^\(.*\)exit$/\1/p;}')
	# show command number is selected
	if $SHOW_CMD_NUMS; then
		printf "[$((++C_NUM))] $x"
	else
		printf "$x"
	fi

	# Execute the command and display its output directly
	eval "$@"

	# Wait for 2 seconds before proceeding
	sleep 2
}

##
# print and executes a command immediately
#
# takes 1 parameter - the string command to run
#
# usage: pei "ls -l"
#
##
function pei() {
	if [ "$FIRST_COMMAND" = false ] && [ "$CLEAR_SCREEN" = true ]; then
		clear_screen
	fi
	FIRST_COMMAND=false
	NO_WAIT=true p "$@"

	# Execute the command and capture all output
	output=$(eval "$@" 2>&1)

	# Display the output
	echo "$output"

	# Pause to allow reading the output
	sleep 2

	# Clear the screen only if CLEAR_SCREEN is set to true
	if [ "$CLEAR_SCREEN" = true ]; then
		clear_screen
	fi
}

##
# Enters script into interactive mode
#
# and allows newly typed commands to be executed within the script
#
# usage : cmd
#
##
function cmd() {
	# render the prompt
	x=$(PS1="$DEMO_PROMPT" "$BASH" --norc -i </dev/null 2>&1 | sed -n '${s/^\(.*\)exit$/\1/p;}')
	printf "$x\033[0m"
	read command
	run_cmd "${command}"
}

##
# Enters script into repl mode
#
# and allows newly typed commands to be executed within the script
#
# type exit to leave the repl
#
# usage : repl
#
##
function repl() {
	# render the prompt
	looping=true
	while $looping; do
		x=$(PS1="$DEMO_PROMPT" "$BASH" --norc -i </dev/null 2>&1 | sed -n '${s/^\(.*\)exit$/\1/p;}')
		printf "$x\033[0m"
		read command
		if [[ "$command" == "exit" ]]; then
			looping=false
		else
			run_cmd "$command"
		fi
	done
}

function run_cmd() {
	function handle_cancel() {
		printf ""
	}

	trap handle_cancel SIGINT
	stty -echoctl
	if $NO_OUTPUT; then
		eval $@ &>/dev/null
	else
		eval $@
	fi
	stty echoctl
	trap - SIGINT
}

function check_pv() {
	command -v pv >/dev/null 2>&1 || {

		echo ""
		echo -e "${RED}##############################################################"
		echo "# HOLD IT!! I require pv for simulated typing but it's " >&2
		echo "# not installed. Aborting." >&2
		echo -e "${RED}##############################################################"
		echo ""
		echo -e "${COLOR_RESET}Disable simulated typing: "
		echo ""
		echo -e "   unset TYPE_SPEED"
		echo ""
		echo "Installing pv:"
		echo ""
		echo "   Mac: $ brew install pv"
		echo ""
		echo "   Other: https://www.ivarch.com/programs/pv.shtml"
		echo ""
		exit 1
	}
}

#
# handle some default params
# -h for help
# -d for disabling simulated typing
#
while getopts ":dhncw:o" opt; do
	case $opt in
	h)
		usage
		exit 1
		;;
	d)
		unset TYPE_SPEED
		;;
	n)
		NO_WAIT=true
		;;
	c)
		SHOW_CMD_NUMS=true
		;;
	w)
		PROMPT_TIMEOUT=$OPTARG
		;;
	o)
		NO_OUTPUT=true
		;;
	esac
done

##
# Do not check for pv. This trusts the user to not set TYPE_SPEED later in the
# demo in which case an error will occur if pv is not installed.
##
if [[ -n "$TYPE_SPEED" ]]; then
	check_pv
fi
