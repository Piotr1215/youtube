#!/usr/bin/env bash
set -eo pipefail
. ./../__demo_magic.sh
TYPE_SPEED=30
clear
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

pei "# Let's create a directory with an .envrc file"
pei "mkdir -p direnv_demo"
pei "echo 'export HELLO=\"World\"' > ./direnv_demo/.envrc"
pei "cat ./direnv_demo/.envrc"

pei "# Now, let's try to use the environment variable"
p "cd direnv_demo"
cd ./direnv_demo

pei "# Oops! We see a permission error. Let's allow the .envrc"
pei "direnv allow"

pei "# Now, let's try again"
pei "echo \$HELLO"

pei "# Let's exit the directory"
pei "cd .."
pei "echo \$HELLO"

pei "# And enter again to see automatic loading"
pei "cd direnv_demo"
pei "echo \$HELLO"

echo "Demo completed!"
