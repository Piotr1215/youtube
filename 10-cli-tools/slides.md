---
theme: ./theme.json
author: Cloud-Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# 10 CLI Tools That Made the Biggest Impact

```bash
~~~./intro.sh

~~~
```

---

## Sections

- 🖥️ Enhancing terminal experience and navigation
- 🚀 Improving development workflow
- 📋 Task and project management
- 🗂️ Information organization and help

---

## Terminal Enhancement and Navigation

### 🔍 fzf (Fuzzy Finder)

> fzf is a general-purpose command-line fuzzy finder.

```bash
function pkill() {
  ps aux | fzf --height 40% --layout=reverse --prompt="Select process to kill: " | awk '{print $2}' | xargs -r sudo kill
}
```

---

### 📊 bpytop (Resource Monitor)

> bpytop is a resource monitor that shows usage and stats for processor, memory, disks, network and processes.

```bash
# Add to .tmux.conf
bind -n M-b popup -d '#{pane_current_path}' -E -h 95% -w 95% -x 100% "bpytop"
```

---

### 🖥️ tmux (Terminal Multiplexer)

> tmux is a terminal multiplexer: it enables a number of terminals to be created, accessed, and controlled from a single screen.

```bash
function create_tmux_session() {
    local RESULT="$1"
    local SESSION_NAME=$(basename "$RESULT" | tr ' .:' '_')
    tmux new-session -d -s "$SESSION_NAME" -c "$RESULT"
    tmux attach -t "$SESSION_NAME"
}
```

---

## Development Workflow

### 🌳 lazygit (Git TUI)

> lazygit is a simple terminal UI for git commands, written in Go with the gocui library.

```bash
function gac() {
  git add .
  git commit -m "$1"
  git push
}
```

---

### 🐙 gh (GitHub CLI)

> gh is GitHub on the command line. It brings pull requests, issues, and other GitHub concepts to the terminal next to where you are already working with git and your code.

```bash
function repo() {
  export repo=$(fd . ${HOME}/dev --type=directory --max-depth=1 --color always | fzf --ansi --preview 'onefetch /home/decoder/dev/{1}')
  [[ -n "$repo" ]] && cd ${HOME}/dev/$repo
}
```

---

### 👀 entr (Event Notify Test Runner)

> entr is a command runner that runs arbitrary commands when files change.

```bash
# Example usage (not in the script):
# find . -name "*.py" | entr python test.py
```

---

## Task and Project Management

### ✅ just (Command Runner)

> just is a handy way to save and run project-specific commands.


---

### ✔️ taskwarrior (Task Management)

> Taskwarrior is a command line task management tool. It maintains a list of tasks that you want to do, allowing you to add/remove, and otherwise manipulate them.

---

## Information Organization and Help

### 📖 tldr (Simplified Man Pages)

> tldr is a collection of community-maintained help pages for command-line tools, that aims to be a simpler, more approachable complement to traditional man pages.

---

### 📎 pet (Command Snippet Manager)

> pet is a simple command-line snippet manager, written in Go.

```bash
function plink() {
  link=$(xclip -o -sel clipboard)
  desc="$*"
  command_name="xdg-open \\\"$link\\\""
  description="Link to $desc"
  tag="link"
  # Use expect to interact with pet new
  /usr/bin/expect <<EOF
    spawn pet new -t
    expect "Command>"
    send "${command_name}\r"
    expect "Description>"
    send "${description}\r"
    expect "Tag>"
    send "${tag}\r"
    expect eof
EOF
}
```

---

## Bonus: 🎉

- `clipboard`
- `aduin`
- `fzf-tab`

---

```bash
../thats_all_folks
```
