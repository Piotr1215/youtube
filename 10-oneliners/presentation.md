---
title: 10 One-Liners That Save Time
author: Cloud Native Corner
date: 2025-08-24
---

# 10 One-Liners That Save Time

> You'll never remember these - that's why you need them

```bash +exec_replace
echo "ONE-LINERS" | figlet -f slant -w 90
```

<!-- end_slide -->

## The Problem

```bash
┌────────────────────────────────────────────────────┐
│                   THE REALITY                      │
│                                                    │
│  • Too useful to forget                            │
│  • Too complex to memorize                         │
│  • You'll need them again tomorrow                 │
│  • Stack Overflow won't have YOUR exact use case   │
│                                                    │
│  Solution: Save them. Use them. Profit.            │
└────────────────────────────────────────────────────┘
```

<!-- end_slide -->

## 1. Use AI to Process Anything

> fabric: github.com/danielmiessler/fabric

```bash
# Summarize any webpage
curl -s NAME | fabric --pattern summarize 

# Extract wisdom from meeting notes
cat NAME | fabric --pattern extract_wisdom

# Summarize page
curl https://cloudrumble.net | fabric -p --model o3-mini
```

<!-- end_slide -->

## 2. Share Files With Anyone

> No cloud accounts. No size limits. Just share.

```bash
# Quick HTTP server + public URL (needs ngrok auth)
python3 -m http.server 8000 & ngrok http 8000

# Build & push Docker image to ttl.sh (expires in 1 hour)
docker build -t NAME . && docker tag NAME ttl.sh/NAME:1h && docker push ttl.sh/NAME:1h

# Share any file instantly
curl -F'file=@NAME' https://tmpfiles.org/api/v1/upload
```

<!-- end_slide -->

## 3. Create Tasks From Context

> Your brain dump → Organized tasks

```bash
# Task from current directory
task add project:${PWD##*/} NAME

# Task from git branch
task add project:$(git branch --show-current) NAME

# Quick task with tomorrow deadline
task add NAME due:tomorrow+17h
```

<!-- end_slide -->

## 4. Kill Annoying Processes

> That process eating your CPU? Dead.

```bash
# Kill what's on port
lsof -ti :NAME | xargs -r kill -9

# Interactive process killer
ps aux | fzf -m | awk '{print $2}' | xargs -r kill -9

# Kill biggest CPU hog
ps aux | sort -nrk 3 | head -1 | awk '{print $2}' | xargs kill -9
```

<!-- end_slide -->

## 5. See Disk Usage

> Where did my space go?

```bash
# Current folder sorted
du -sh * | sort -hr | head -10

# Interactive explorer
ncdu --color dark

# Find big files
fd -t f -x du -h {} | sort -hr | head -20
```

<!-- end_slide -->

## 6. Schedule & Queue Commands

> Run it later. Run it in order. Forget about it.

```bash
# Queue long command (pueue)
pueue add -- rsync -av NAME/ NAME/

# Run after another finishes
pueue add --after NAME -- "make test"

# Schedule for later
echo "task add 'NAME'" | at now + 2 hours
```

<!-- end_slide -->

## 7. Encrypt & Share Secrets

> age: github.com/FiloSottile/age

```bash
# Encrypt with password
age -p NAME > NAME.age

# Decrypt file
age -d NAME.age > NAME

# Encrypt for specific person
age -r RECIPIENT NAME > NAME.age

# Encrypt and upload
tar czf - NAME | age -p > /tmp/NAME.age && curl -F'file=@/tmp/NAME.age' https://tmpfiles.org/api/v1/upload
```

<!-- end_slide -->

## 8. Working With Git

> Git magic you'll actually use

```bash
# Undo last commit but keep changes
git reset --soft HEAD~1

# Show files changed in last N commits
git diff --name-only HEAD~NAME..HEAD

# Quick commit with all changes
git add -A && git commit -m "NAME"
```

<!-- end_slide -->

## 9. Compare & Diff Things

> What changed? Let's find out.

```bash
# Compare two directories (select both)
diff <(ls $(fd -t d | fzf --header "Select first directory")) <(ls $(fd -t d | fzf --header "Select second directory"))

# Compare file with clipboard
diff NAME <(xclip -o)

# See what changed in stash (interactive)
git stash list | fzf --preview 'git stash show -p {1}' | awk '{print $1}' | xargs git stash show -p
```

<!-- end_slide -->

## 10. Find Files & Copy Path

> The most underrated workflow

```bash
# Find and copy full path
fd . | fzf | xargs realpath | xclip -selection clipboard

# Search by content, copy path
rg -l NAME | fzf | xargs realpath | xclip

# Recent files, copy path
fd . -t f --changed-within 1d | fzf | xclip
```

<!-- end_slide -->

## Save These!

> Use a snippet manager:
> • pet: github.com/knqyf263/pet
> • navi: github.com/denisidoro/navi
> • Or just a well-organized bash file

```bash +exec_replace
echo "Now go save these!" | figlet -f small -w 90
```

<!-- end_slide -->

## That's All Folks! 🎬

```bash +exec_replace
echo "That's All Folks" | figlet -f small -w 90
```
