#!/usr/bin/env bash
set -eo pipefail
IFS=$'\n\t'
. ./../__demo_magic.sh
TYPE_SPEED=12
clear

# Base path variable
export DEMO_BASE="/home/decoder/dev/youtube/backups"
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# Setup - fast background preparation
rm -rf $DEMO_BASE/demo
mkdir -p $DEMO_BASE/demo/source/documents
echo 'Important document' >$DEMO_BASE/demo/source/documents/doc1.txt
echo 'Secret file' >$DEMO_BASE/demo/source/documents/doc2.txt
dd if=/dev/urandom of=$DEMO_BASE/demo/source/documents/image.jpg bs=1M count=1 2>/dev/null

# Restic Section
p "restic"
man restic | sed -n '/^DESCRIPTION$/,/^$/p'
pe "restic init --repo ./restic"
pec "ls ./restic"
pe "tree ./demo"
pe "restic backup ./demo --repo ./restic"
pec "restic snapshots --repo ./restic"
export snapshot_id=$(restic snapshots --repo ./restic --json | jq -r '.[0].short_id')
pe "restic restore --repo ./restic --target ./restore $snapshot_id"
pec "tree ./restore"

# Rclone Section
p "rclone"
info rclone 2>/dev/null | sed -n '/About rclone/,/^$/p' | sed '1,2d;$d'
pe "rclone listremotes"
pe "rclone tree azure:backup"
pe "rclone copy ./demo azure:backup"
pec "rclone tree azure:backup"
pec "az storage blob list --account-name rclonedemosa --container-name backup --output table"
pe "rclone delete azure:backup"
pec "rclone tree azure:backup"

# Rsync Section
p "rsync"
man rsync | sed -n '/^DESCRIPTION$/,/^$/p'
pe "mkdir -p ./remote_storage"
pe "rsync -avz --progress ./demo/ ./remote_storage/"
pec "tree ./remote_storage"
pe "echo 'New file' > ./demo/source/documents/new_doc.txt"
pe "rsync -avz --progress ./demo/ ./remote_storage/"
pec "tree ./remote_storage"

rm -drf $DEMO_BASE/demo
rm -drf $DEMO_BASE/restic
rm -drf $DEMO_BASE/restore
rm -drf $DEMO_BASE/remote_storage
