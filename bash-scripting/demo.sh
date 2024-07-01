#!/usr/bin/env bash
# set -eo pipefail

# Source the demo magic script
. ./../__demo_magic.sh

# Start the timer
./../__tmux_timer.sh &

TYPE_SPEED=20
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Remove all the txt files in the current folder
rm -f *.txt

clear

# Function to run expect script
run_expect_script() {
	local name=$1

	/usr/bin/expect <<EOF
    spawn ./example/example.sh $name
    expect {
        "How many files do you want to create? (0-5): " {
            send "10\r"
            exp_continue
        }
        "Please enter a number between 0 and 5." {
            exit
        }
    }
EOF
}

# Introduction Slides
slides ./slides.md

# Shebang
nvim -c 'FIX 25' -c 'SimulateTypingWithPause ./example/example.sh 30 paragraph'

# Run script normally
p "To run the script in the current directory we must first grant it executable permissions and then run it\n
   sudo chmod +x ./example/example.sh\n
./example/example.sh Alice"
p "./example/example.sh Alice"
./example/example.sh Alice

p "Let's test the script validation logic by running it without a valid name\n
   ./example/example.sh"
p "./example/example.sh"
./example/example.sh

p "We can also try providing incorrect number of files to create\n
   ./example/example.sh Alice \n
   and responding with wrong number of files; 10"
p "run_expect_script Alice"
run_expect_script Alice
pei ""

# Note about debug mode
p "Debug mode is very helpful when fixing bugs, use: \n
   bash -x ./example/example.sh <name>"

p "bash -x ./example/example.sh Charlie"
bash -x ./example/example.sh Charlie

clear
p "Bash scripting is fun! 🎉"
