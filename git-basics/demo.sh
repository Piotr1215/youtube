#!/usr/bin/env bash
set -eo pipefail

# Source the demo magic script (ensure the correct path)
. ./../__demo_magic.sh
./../__tmux_timer.sh &

TYPE_SPEED=20
CLEAR_SCREEN=true

# Pre-command hook to update prompt before each command
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

clear

# Ensure we start with a clean slate
mkdir my-git-repo
cd my-git-repo

# 1. Initialize a new Git repository
pei "git init"

# 2. Create a new file and add some content
pei "echo 'Hello, Git!' > hello.txt"
pem "cat hello.txt"

# 3. Add the file to the staging area
pei "git add hello.txt"
pei "git status"

# 4. Commit the file to the repository
pei "git commit -m 'Initial commit with hello.txt'"
pei "git show"

# 6. Create a new branch
pei "git checkout -b new-feature"
pei "git branch"

# 7. Modify the file in the new branch
pei "echo 'This is a new feature.' >> hello.txt"
pei "cat hello.txt"

# 8. Commit the changes in the new branch
pei "git add hello.txt"
pei "git commit -m 'Add new feature to hello.txt'"
pei "git log --oneline"

# 9. Switch back to the main branch
pei "git checkout main"
pei "git branch"

# 10. Merge the new branch into the main branch
pei "git merge new-feature"
pei "git log --oneline"
p "git push origin"

cd ..
rm -rf ./my-git-repo
