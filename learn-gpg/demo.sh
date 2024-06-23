#!/usr/bin/env bash

set -eo pipefail

# Add source and line number when running in debug mode: __run_with_xtrace.sh demo.sh
# Set new line and tab for word splitting
IFS=$'\n\t'

# Source the demo magic script (ensure the correct path)
. ./../__demo_magic.sh

TYPE_SPEED=30

clear

# Set up the prompt
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Generate a new GPG key
p "gpg --batch --generate-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 2048
Name-Real: Demo User
Name-Email: demo_user@example.com
Expire-Date: 0
EOF"

gpg --batch --generate-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 2048
Name-Real: Demo User
Name-Email: demo_user@example.com
Expire-Date: 0
EOF

# List the generated keys to verify
pe "gpg --list-keys demo_user@example.com"

# Encrypting a file using the new key
pe "echo 'This is a secret message' > secret.txt"
pei "cat secret.txt"

RECIPIENT="demo_user@example.com"
pe "gpg --encrypt --sign --output secret.txt.gpg --recipient '$RECIPIENT' secret.txt"

# Listing files to show the encrypted file
pei "exa *.gpg *.txt --color=always"

# Create an ASCII-armored detached signature for the file
pe "gpg --armor --output secret.txt.sig --detach-sig secret.txt"

# Verify the detached signature and grep for "Good signature"
pe "gpg --verify secret.txt.sig secret.txt 2>&1 | grep 'Good signature'"

# Decrypting the file
NO_OUTPUT=true
pe "gpg --output decrypted_secret.txt --decrypt secret.txt.gpg"
NO_OUTPUT=false

# Displaying the decrypted file content
pei "bat decrypted_secret.txt"

# Enhanced Cleanup Section
# Remove all files created during the demo
pe "rm secret.txt secret.txt.gpg decrypted_secret.txt secret.txt.sig"

for fingerprint in $(gpg --list-secret-keys --with-colons demo_user@example.com | awk -F: '/^fpr/ {print $10}'); do
	gpg --batch --yes --delete-secret-keys $fingerprint
	gpg --batch --yes --delete-keys $fingerprint
done
