#!/usr/bin/env bash

# Set strict mode
set -euo pipefail
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
# -o pipefail: The return value of a pipeline is the status of
#    the last command to exit with a non-zero status, or zero if
#    no command exited with a non-zero status.

# Function definition
print_header() {
	echo "==== $1 ===="
}
# Functions allow you to group commands and reuse code

# Assign command line arguments to variables
name="${1:-}"
# We quote variables to prevent word splitting and glob expansion
# ${1:-} means use $1 if set, otherwise use empty string

# Basic error handling
if [[ $# -eq 0 ]]; then
	echo "Error: Name is required."
	echo "Usage: $0 <name>"
	exit 1
fi
# $# is a special variable that holds the number of arguments
# [[ ]] is a bash keyword for conditional expressions, more powerful than single []
# Exit codes: 0 means success, any non-zero value indicates an error

print_header "Welcome"
echo "Hello, ${name}! Welcome to our bash script."

# Input with validation
while true; do
	read -p "How many files do you want to create? (0-5): " num_files
	if [[ "$num_files" =~ ^[0-5]$ ]]; then
		break
	else
		echo "Please enter a number between 0 and 5."
	fi
done
# =~ tests against a regular expression
# This loop continues until valid input is received

# Conditional operators and case statement
case $num_files in
0)
	echo "No files will be created."
	;;
[1-3])
	echo "Creating a few files..."
	;;
[4-5])
	echo "Creating many files..."
	;;
esac
# Case statements are useful for multiple conditions on a single variable

# Array and loop for file creation
files=()
for ((i = 1; i <= num_files; i++)); do
	filename="file_$i.txt"
	echo "This is file number $i" >"$filename"
	files+=("$filename")
done
# Arrays can store multiple values
# This loop uses C-style syntax, common in many programming languages

# String manipulation
print_header "Created Files"
for file in "${files[@]}"; do
	echo "${file##*/}" # Remove path, show only filename
done
# ${files[@]} expands to all array elements
# ${file##*/} is parameter expansion, removing everything up to the last '/'

# Demonstrating $? (exit status of last command)
ls non_existent_file 2>/dev/null
if [[ $? -ne 0 ]]; then
	echo "The previous command failed."
fi
# $? holds the exit status of the last command
# 2>/dev/null redirects error output to /dev/null (discarding it)
# -ne means "not equal to"

print_header "Script Completed"
exit 0
