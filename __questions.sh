#!/usr/bin/env bash

# Hide cursor and disable echo immediately
tput civis
stty -echo

GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Restore cursor and echo on exit
trap 'tput cnorm; stty echo; exit 0' EXIT INT TERM

# Check for required commands
# Check for required commands
for cmd in tmux figlet boxes lolcat beep; do
	if ! command -v $cmd &>/dev/null; then
		if [ "$cmd" = "beep" ]; then
			echo "Warning: beep is not installed. Falling back to terminal bell." >&2
		else
			echo "Error: $cmd is required but not installed. Please install it and try again." >&2
			exit 1
		fi
	fi
done
# Function to produce a beep sound
# Function to produce a beep sound
# Function to produce a gentle bell-like sound
make_beep() {
	mpg123 -q /home/decoder/Downloads/robotic-countdown-43935.mp3 &
}
# Function to get the dimensions of the current tmux pane
get_pane_dimensions() {
	tmux display-message -p '#{pane_width} #{pane_height}'
}

# Function to clear the screen and position the cursor
clear_and_position() {
	local height=$1
	local mid_row=$2
	printf '\033[2J\033[3J\033[H' # Clear screen and scrollback buffer
	tput cup $mid_row 0
}

# Function to center the text
center_text() {
	local text="$1"
	local width=$2
	local padding=$(((width - ${#text}) / 2))
	printf "%${padding}s%s\n" "" "$text"
}

# Function to display question and answers
display_question() {
	local question="$1"
	local answers="$2"
	local width=$3
	local height=$4
	local show_answer=$5

	clear_and_position "$height" $((height / 3 - 4))

	center_text "$question" "$width"
	echo

	if [ -n "$answers" ]; then
		IFS=';' read -ra ANSWERS <<<"$answers"
		local max_length=0
		for answer in "${ANSWERS[@]}"; do
			answer=${answer//||/} # Remove || if present
			[[ ${#answer} -gt $max_length ]] && max_length=${#answer}
		done

		local total_width=$((max_length + 4)) # 4 for "x) " and a space
		local padding=$(((width - total_width) / 2))
		local letter='a'
		for answer in "${ANSWERS[@]}"; do
			local display_answer
			if [[ $answer == \|\|*\|\| ]]; then
				answer=${answer//||/} # Remove ||
				if [[ $show_answer == true ]]; then
					display_answer="$letter) ${GREEN}$answer <--${NC}"
					echo -e "$(printf "%${padding}s%s\n" "" "$display_answer")"
				else
					display_answer="$letter) $answer"
					echo "$(printf "%${padding}s%s\n" "" "$display_answer")"
				fi
			else
				display_answer="$letter) $answer"
				echo "$(printf "%${padding}s%s\n" "" "$display_answer")"
			fi
			letter=$(echo "$letter" | tr "a-z" "b-za")
		done
	fi
}

# Main countdown function with quiz
countdown_quiz() {
	local question="$1"
	local answers="$2"
	local dimensions
	local width
	local height

	read -r width height <<<"$(get_pane_dimensions)"

	display_question "$question" "$answers" "$width" "$height" false
	read -p "" </dev/tty

	clear_and_position "$height" $((height / 3 - 4))
	center_text "$question" "$width"
	echo

	if [ -n "$answers" ]; then
		IFS=';' read -ra ANSWERS <<<"$answers"
		local max_length=0
		for answer in "${ANSWERS[@]}"; do
			answer=${answer//||/} # Remove || if present
			[[ ${#answer} -gt $max_length ]] && max_length=${#answer}
		done

		local total_width=$((max_length + 4)) # 4 for "x) " and a space
		local padding=$(((width - total_width) / 2))
		local letter='a'
		for answer in "${ANSWERS[@]}"; do
			local display_answer
			if [[ $answer == \|\|*\|\| ]]; then
				answer=${answer//||/} # Remove ||
				display_answer="$letter) $answer"
			else
				display_answer="$letter) $answer"
			fi
			printf "%${padding}s%s\n" "" "$display_answer"
			letter=$(echo "$letter" | tr "a-z" "b-za")
		done
	fi

	# Play the countdown sound once at the start
	mpg123 -q /home/decoder/Downloads/robotic-countdown-43935.mp3 &

	for i in {3..1}; do
		tput cup $((height / 3 + 2)) 0

		# Generate figlet text, put it in a box, center it, and colorize it
		figlet_output=$(echo "$i" | figlet -f standard)
		# Add padding to the number "1" to match the width of other numbers
		boxed_output=$(echo "$figlet_output" | boxes -d stone -p a2v1)
		if [ "$i" -eq 1 ]; then
			boxed_output=$(echo "$figlet_output" | boxes -d stone -p a4v1)
		fi

		centered_output=$(echo "$boxed_output" | while IFS= read -r line; do
			center_text "$line" "$width"
		done)
		echo -e "$centered_output" | lolcat -f -s 100 2>/dev/null
		tput cup $((height / 3 + 4)) 0

		sleep 1
	done

	clear_and_position "$height" $((height / 3 - 4))
	display_question "$question" "$answers" "$width" "$height" true

	read -p "" </dev/tty
}

# Check if the questions file path is provided
if [ $# -lt 1 ]; then
	echo "Usage: $0 <path_to_questions_file>" >&2
	exit 1
fi

questions_file="$1"

# Check if the file exists
if [ ! -f "$questions_file" ]; then
	echo "Error: Questions file not found at $questions_file" >&2
	exit 1
fi

# Read and process each question
while IFS= read -r line || [[ -n "$line" ]]; do
	eval "question_data=($line)" # This safely parses the line into an array
	if [ ${#question_data[@]} -eq 2 ]; then
		countdown_quiz "${question_data[0]}" "${question_data[1]}"
	fi
done <"$questions_file"

# Clear the screen after all questions
printf '\033[2J\033[3J\033[H'
