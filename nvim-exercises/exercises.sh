#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Usage: $0 <solution_file1> [solution_file2] [solution_file3] ..."
	exit 1
fi

exercise_file="costam"

if [ ! -f "$exercise_file" ]; then
	echo "Error: Exercise file '$exercise_file' not found."
	exit 1
fi

total_exercises=$#
current_exercise=0

for solution_file in "$@"; do
	((current_exercise++))

	if [ ! -f "$solution_file" ]; then
		echo "Error: Solution file '$solution_file' not found. Skipping."
		continue
	fi

	clear
	echo "Exercise $current_exercise of $total_exercises: ${solution_file##*/}"
	echo "Watching file: $exercise_file"
	echo "Comparing with: $solution_file"
	echo "Press Ctrl+C to stop watching and move to the next exercise."

	next_exercise=""
	if [ $current_exercise -lt $total_exercises ]; then
		next_exercise=$(echo "$@" | cut -d' ' -f$((current_exercise + 1)))
	fi

	ls "$exercise_file" | entr -c bash -c "
        if diff -q '$exercise_file' '$solution_file' >/dev/null 2>&1; then
            clear
            echo 'You did it, you are a Legend!' | figlet | boxes -d unicornsay | lolcat
            echo 'Exercise \"${solution_file##*/}\" completed!'
            if [ -n '$next_exercise' ]; then
                echo \"Next exercise will be: ${next_exercise##*/}\"
            else
                echo \"This was the last exercise!\"
            fi
            echo 'Press Ctrl+C to continue...'
            sleep infinity
        else
            diff -u '$exercise_file' '$solution_file' | diff-so-fancy
        fi
    "
done

clear
echo "Congratulations! You've completed all exercises!" | figlet | lolcat
