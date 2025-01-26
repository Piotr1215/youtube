#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Usage: $0 <solution_file1> [solution_file2] [solution_file3] ... or <directory>"
	exit 1
fi

exercise_file="costam"

if [ ! -f "$exercise_file" ]; then
	echo "Error: Exercise file '$exercise_file' not found."
	exit 1
fi

# Check if the first argument is a directory
if [ -d "$1" ]; then
	echo "Loading files from directory: $1"
	# Load all files from the directory, sorted by name
	solution_files=($(ls "$1"/* | sort -V))
else
	echo "Using provided files."
	# Use provided arguments as the solution files
	solution_files=("$@")
fi

# Debug: List all loaded files
echo "Loaded solution files:"
for file in "${solution_files[@]}"; do
	echo " - $file"
done

total_exercises=${#solution_files[@]}
current_exercise=1

trap "echo 'Exiting...'; exit 0" SIGINT

show_result() {
	clear
	echo "Exercise $current_exercise of $total_exercises: $(basename "${solution_file}")"
	echo "Comparing $exercise_file with $(basename "${solution_file}")"

	if diff -q "$exercise_file" "$solution_file" >/dev/null 2>&1; then
		clear
		echo 'You did it, you are a Legend!' | figlet | boxes -d unicornsay | lolcat
		echo "Exercise \"$(basename "${solution_file}")\" completed!"
	else
		diff -u "$exercise_file" "$solution_file" | diff-so-fancy
	fi

	echo 'Press n for next, p for previous, or Ctrl+C to quit.'
}

while true; do
	echo "Current exercise index: $current_exercise"

	if [ $current_exercise -gt $total_exercises ]; then
		echo "No more exercises."
		break
	elif [ $current_exercise -lt 1 ]; then
		current_exercise=1
	fi

	solution_file="${solution_files[$current_exercise - 1]}"

	echo "Selected solution file: $solution_file"

	if [ ! -f "$solution_file" ]; then
		echo "Error: Solution file '$solution_file' not found. Skipping."
		((current_exercise++))
		continue
	fi

	show_result

	inotifywait -qe modify "$exercise_file" &
	inotify_pid=$!

	while true; do
		read -t 0.1 -n 1 key

		if [ "$key" = 'n' ]; then
			echo "Next exercise"
			((current_exercise++))
			break
		elif [ "$key" = 'p' ]; then
			echo "Previous exercise"
			((current_exercise--))
			break
		elif [ -n "$key" ]; then
			echo "Ignoring unknown input: $key"
		fi

		# Check if the file has been modified
		if ! kill -0 $inotify_pid 2>/dev/null; then
			echo "File modified. Refreshing..."
			show_result
			inotifywait -qe modify "$exercise_file" &
			inotify_pid=$!
		fi
	done

	kill $inotify_pid 2>/dev/null
done

clear
echo "YAY!" | figlet | lolcat
