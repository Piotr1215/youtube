#!/usr/bin/env bash
set -eo pipefail
. ./../__demo_magic.sh
TYPE_SPEED=45
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Create a sample text file
cat <<EOF >sample.txt
Hello World!
This is a sample file.
It contains multiple lines.
Some lines contain the word 'sample'.
This line does not.
Another sample line.
EOF

clear

# Use rg to find lines containing the word 'sample'
echo "Find lines containing the word 'sample'" | boxes -d simple | __center_text.sh
pe "rg 'sample' sample.txt"

clear

# Use sed to replace 'sample' with 'example' in the file and print to console
echo "Replace 'sample' with 'example' in the file and print to console" | boxes -d simple | __center_text.sh
pe "sed 's/sample/example/' sample.txt"

clear

# Use sed to replace 'sample' with 'example' in the file in place
echo "Replace 'sample' with 'example' in the file in place" | boxes -d simple | __center_text.sh
pe "sed -i 's/sample/example/' sample.txt"

clear

# Use rg to count the number of lines containing 'example'
echo "Count the number of lines containing 'example'" | boxes -d simple | __center_text.sh
pe "rg -c 'example' sample.txt"

clear

# Use sed to delete lines containing 'example'
echo "Delete lines containing 'example'" | boxes -d simple | __center_text.sh
pe "sed -i '/example/d' sample.txt"

clear

# Use sed to add a prefix to each line
echo "Add a prefix to each line" | boxes -d simple | __center_text.sh
pe "sed -i 's/^/PREFIX: /' sample.txt"

clear

# Combine sed and rg: Use rg to find lines containing 'PREFIX' and then use sed to replace 'PREFIX' with 'HEADER'
echo "Combine sed and rg: Replace 'PREFIX' with 'HEADER'" | boxes -d simple | __center_text.sh
pe "rg 'PREFIX' sample.txt | sed 's/PREFIX/HEADER/'"
