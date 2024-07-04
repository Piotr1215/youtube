#!/bin/bash

# Get the list of available single-word fonts
fonts=($(figlist | grep -E '^[^ ]+$'))

# Title to display
title="Vim Power"

# Check if any fonts were found
if [ ${#fonts[@]} -eq 0 ]; then
	echo "No fonts found. Make sure figlet is installed and fonts are available."
	exit 1
fi

# Iterate over the fonts
for font in "${fonts[@]}"; do
	echo "Font: $font"
	echo "--------------------------------"
	if echo "$title" | figlet -f "$font" | boxes -d peek; then
		echo "--------------------------------"
		echo # Add a blank line for better readability

		# Optional: add a pause between each font display
		read -p "Press Enter to continue..."
	else
		echo "Failed to display font: $font. Skipping..."
	fi
done
