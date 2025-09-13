# 10 One-Liners That Save Time (You'll Never Remember These)

> These commands are too useful to forget but too complex to memorize - save them in your snippet manager!

## Process Management

### Kill CPU-hungry processes interactively
```bash
# Sort by CPU usage and kill selected process
ps aux | sort -nrk 3,3 | head -n 10 | fzf --header='Select process to kill' --preview='echo {}' | awk '{print $2}' | xargs -r kill -9

# Multiple selection with TAB
ps aux | sort -nrk 3,3 | head -n 10 | fzf -m --header='Select processes (TAB to multi-select)' | awk '{print $2}' | xargs -r kill -9
```

### Kill memory-hungry processes interactively
```bash
# Sort by memory usage (column 4)
ps aux | sort -nrk 4,4 | head -n 10 | fzf --header='Select process to kill' | awk '{print $2}' | xargs -r kill -9
```

### Kill process listening on specific port
```bash
# Find and kill what's using a port (replace PORT with actual port number)
sudo lsof -i :PORT | grep LISTEN | awk '{print $2}' | xargs -r kill -9

# Interactive version
sudo lsof -i -P | grep LISTEN | fzf | awk '{print $2}' | xargs -r kill -9
```

## File System

### Find recently modified files
```bash
# Files changed in last 24 hours
find . -type f -mtime -1 -ls

# Files changed in last hour
find . -type f -mmin -60 -ls
```

### Show biggest directories
```bash
# Human-readable sizes, sorted
du -h --max-depth=1 | sort -hr | head -20

# Interactive directory size explorer
du -h --max-depth=1 | sort -hr | fzf --preview='ls -la {2}' | awk '{print $2}'
```

### Find and copy specific files with directory structure
```bash
# Preserves directory structure when copying
fd README.md | cpio -pdm ~/backup/
```

## Git Power Commands

### Git log with visual graph and search
```bash
git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit | fzf --ansi --no-sort --reverse --tiebreak=index
```

### Check unpushed commits across all repos
```bash
# Find all repos with unpushed commits
find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(echo {} && cd {} && git log --branches --not --remotes && echo)' \;
```

### Check git status of all repos in folder
```bash
find . -maxdepth 1 -mindepth 1 -type d -exec sh -c '(echo {} && cd {} && git fetch origin && git status -s && echo)' \;
```

### Find deleted files and their commits
```bash
# Useful for undeleting files
git log --diff-filter=D --summary | grep -E 'delete|^commit\s+\S+'
```

### Search entire git history for content
```bash
# Search all commits for specific text
git log -p --all -G 'search_term'
```

## Network & Services

### Quick HTTP server with Python
```bash
# Serve current directory on port 8000
python3 -m http.server --bind 0.0.0.0 8000

# Why useful: Quick file sharing, testing web apps, serving documentation
# Access from another machine: http://YOUR_IP:8000
```

### Show all listening ports and services
```bash
# Better than netstat
ss -tulpn | grep LISTEN

# Check specific port
sudo lsof -i :PORT -P | grep LISTEN
```

### Watch for file changes and run command
```bash
# Auto-run tests on file change
fd . | entr -c make test

# Auto-apply Kubernetes manifests
ls *.yaml | entr kubectl apply -f {}
```

## System Utilities

### Generate secure password and copy to clipboard
```bash
# Generate and select password interactively
apg -M SNCL -m 22 | fzf | xsel -ib

# Or using openssl
openssl rand -base64 32 | head -c 24 | xclip -selection clipboard
```

### Apply YAML from clipboard directly
```bash
# Paste and apply Kubernetes manifest
xclip -o -sel clipboard | kubectl apply -f -
```

### List all Makefile targets
```bash
# Extract all targets from Makefile
make -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | sort -u
```

### Cleanup old system logs
```bash
# Keep only last 10MB of journal logs
sudo journalctl --vacuum-size=10M

# Delete logs older than 7 days
sudo journalctl --vacuum-time=7d
```

## Bonus: Shell Functions

### Extract any archive type
```bash
# Add to your .bashrc/.zshrc
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.tar.xz)  tar xJf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
```

---

## Why Save These?

1. **Too complex to memorize** - You'll never remember the exact syntax
2. **Too useful to forget** - You'll need them again
3. **Time savers** - Each one replaces multiple manual steps
4. **Composable** - Can be piped together for more complex operations

## Recommended Snippet Managers

- `pet` - Simple command-line snippet manager
- `navi` - Interactive cheatsheet tool
- `bropages` - Community driven examples
- Your own bash aliases/functions file

---

*Pro tip: Don't just save the command - add a description of WHEN to use it and WHY it's useful*