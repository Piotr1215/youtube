#!/usr/bin/env bash

# Set strict mode
set -euo pipefail

# Functions
print_header() {
	echo "==== $1 ===="
}

# Assign command line arguments to variables
name="${1:-}"

# Basic error handling
if [[ $# -eq 0 ]]; then
	echo "Error: Name is required."
	echo "Usage: $0 <name>"
	exit 1
fi

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
exit 0
