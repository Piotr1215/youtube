#!/usr/bin/env bash

set -eo pipefail

# Add source and line number when running in debug mode
IFS=$'\n\t'

# Source the demo magic script (ensure the correct path)
. ./../__demo_magic.sh

./../__tmux_timer.sh &

TYPE_SPEED=20
CLEAR_SCREEN=true

clear

# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Create a sample text file with richer content
echo -e "apple\nbanana\ncherry\napple pie\npineapple\nfruit\nfruit pie\nbanana bread\napple crumble\ncherry tart\na e\n" >sample.txt

# Show the content of the sample text file
pe "cat sample.txt"

# 1. Literal Characters
pe "rg 'apple' sample.txt"

# 2. Character Classes
# Character classes allow you to search for any one of a set of characters.
# For example, [bp]le will match 'ble' and 'ple'.
pe "rg '[bp]le' sample.txt"

# 3. Anchors
# Anchors are used to match the position within a line.
# ^ matches the start of a line, $ matches the end of a line.
pe "rg '^apple' sample.txt" # Matches lines starting with 'apple'
pe "rg 'pie\$' sample.txt"  # Matches lines ending with 'pie'

# 4. Quantifiers
# Quantifiers specify how many instances of a character, group, or character class must be present in the input for a match to be found.
# . matches any single character (except newline).
# .* matches any character (except newline) zero or more times.
# .+ matches any character (except newline) one or more times.
pe "rg 'a.*e' sample.txt"  # Matches 'a' followed by 'e' with any characters in between
pe "rg 'a..+e' sample.txt" # Matches 'a' followed by 'e' with one or more characters in between

# 6. Using Captured Groups in Replacement with sd
# Using sd to capture and replace multiple groups
echo -e "123-456-7890\n987-654-3210\n555-555-5555" >phone_numbers.txt

# Show the content of the phone numbers text file
pe "cat phone_numbers.txt"

# Capture the three groups of digits and format them differently
pe "sd '(\d{3})-(\d{3})-(\d{4})' '(\$1) \$2-\$3' phone_numbers.txt"

# Show the content of the modified phone numbers text file
pe "cat phone_numbers.txt"

# Cleanup
pe "rm sample.txt phone_numbers.txt"
