---
theme: ./theme.json
author: Cloud-Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Mastering tmux: Terminal Multiplexer

```bash
~~~./intro.sh

~~~
```

---

## What is tmux?

- Terminal MUltipleXer
- Create, access, and control multiple terminal sessions
- Persistent sessions survive accidental disconnections
- Enhance productivity for command-line users

---

## tmux Architecture

- Server: Manages all tmux sessions
- Session: A collection of windows
- Window: Like tabs in a terminal emulator
- Pane: Splits within a window

```bash
Server
└── Session
    ├── Window 1
    │   ├── Pane 1
    │   └── Pane 2
    └── Window 2
        └── Pane 1
```

---

## Common Use Cases

1. 💻 Remote development
   - SSH into a server and start a tmux session
   - Detach and reattach without losing work

2. 🛠️ Project-specific environments
   - Create a session for each project
   - Organize windows and panes for different tasks

3. 👥 Pair programming
   - Share a tmux session for real-time collaboration

---

## Basic tmux Commands

```bash
tmux                            -----> Start a new session
tmux new -s session_name        -----> Create a named session
tmux attach -t session_name     -----> Attach to an existing session
tmux ls                         -----> List sessions
```

---

## Key Bindings

Default prefix: `Ctrl-b`

- Create window: `prefix c`
- Next window: `prefix n`
- Previous window: `prefix p`
- Split pane horizontally: `prefix %`
- Split pane vertically: `prefix "`
- Switch panes: `prefix arrow_key`
- Detach: `prefix d`

---

## Custom Configuration Highlights

```bash
# Set new prefix
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Reload config
bind r source-file ~/.tmux.conf \; display "Tmux Reloaded"

# Pane navigation with vim-like keys
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

---

## Status Line Customization

```bash
# Status line style
set -g status-style fg=colour231,bg=colour234

# Left status
set -g status-left "#[fg=colour16,bg=colour254,bold] #S #[fg=colour254,bg=colour234,nobold]"

# Window status
set -g window-status-format "#[fg=colour244,bg=colour234]#I #[fg=colour240] #[default]#W "
set -g window-status-current-format "#[fg=colour234,bg=colour31]#[fg=colour117,bg=colour31] #I  #[fg=colour231,bold]#W #[fg=colour31,bg=colour234,nobold]"
```

---

## Advanced Features

```bash
setw synchronize-panes     -----> Toggle Synchronized pane
resize-pane -Z             -----> Toggle Maximize pane
prefix [                   -----> Copy mode (vim keys)
```

---

## tmux Automation Scripts

1. Toggle status and pane border:
```bash
#!/bin/bash
status=$(tmux show-option -gqv status)
if [[ "$status" == "on" ]]; then
  tmux set-option -g pane-border-status off
  tmux set-option -g status off
elif [[ "$status" == "off" ]]; then
  tmux set-option -g pane-border-status top
  tmux set-option -g status on
fi
```

---

2. Change to session path:
```bash
function cds() {
  session=$(tmux display-message -p '#{session_path}')
  cd "$session"
}
```

---

3. Find and open repository:
   ```bash
   function repo() {
     export repo=$(fd . ${HOME}/dev --type=directory --max-depth=1 --color always| 
                   awk -F "/" '{print $5}' | 
                   fzf --ansi --preview 'onefetch /home/decoder/dev/{1}' --preview-window up)
     if [[ -n "$repo" ]]; then
       cd ${HOME}/dev/$repo
       [[ -d .git ]] && git fetch origin && onefetch
       create_tmux_session "${HOME}/dev/$repo"
     fi
   }
   ```

---

4. Create tmux session:
   ```bash
   function create_tmux_session() {
     local RESULT="$1"
     local SESSION_NAME=$(basename "$RESULT" | tr ' .:' '_')
     [[ -d "$RESULT/.git" ]] && SESSION_NAME+="_$(git -C "$RESULT" symbolic-ref --short HEAD 2>/dev/null)"
     
     tmux has-session -t "$SESSION_NAME" 2>/dev/null || 
       tmux new-session -d -s "$SESSION_NAME" -c "$RESULT"
     
     if [ -z "$TMUX" ]; then
       tmux attach -t "$SESSION_NAME"
     else
       tmux switch-client -t "$SESSION_NAME"
     fi
   }
   ```

---

## Advanced tmux Features

### 1. Linking Windows

- Share a window between multiple sessions
- Link: `tmux link-window -s src_session:src_window -t dst_session:dst_window`
- Unlink: `tmux unlink-window -t session:window`

### 2. Moving Windows

- Reorder windows within a session
- Move: `tmux move-window -s src_window -t dst_window`
- Swap: `tmux swap-window -s src_window -t dst_window`

---

## Advanced Pane Management

### Joining Panes

- Move a pane from one window to another
- Join: `tmux join-pane -s src_window.src_pane -t dst_window.dst_pane`

### Breaking Panes

- Turn a pane into its own window
- Break: `tmux break-pane -t session:window.pane`

---

## tmux Scripting

### 1. Send-Keys Command

- Automate input to panes
- Example:
  ```bash
  tmux send-keys -t session:window.pane "echo Hello, tmux!" Enter
  ```

> C-m is for enter

### 2. Run-Shell Command

- Execute shell commands from within tmux
  ```bash
  tmux run-shell "ps aux | grep tmux"
  ```

---

## Using TPM (tmux Plugin Manager)

- Easily manage tmux plugins
- Installation and usage:
  ```bash
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  # Add to tmux.conf:
  set -g @plugin 'tmux-plugins/tpm'
  set -g @plugin 'tmux-plugins/tmux-sensible'
  run '~/.tmux/plugins/tpm/tpm'
  ```

---

## Custom Status Line 

- Integrate external data into your status line
- Example (battery status):
  ```bash
  set -g status-right '#(battery -t) | %a %h-%d %H:%M '
  ```

---

## Performance Tuning

### 1. Reducing Escape Time

- Improve responsiveness in Vim/Neovim
- Add to tmux.conf:
  ```bash
  set-option -sg escape-time 10
  ```

---

### 2. Increasing History Limit

- Allow more scrollback in panes
- Add to tmux.conf:
  ```bash
  set-option -g history-limit 50000
  ```

---

## Integrating with the System

### 1. tmux Socket Control

- Control tmux via sockets for automation
- Example (create session via socket):
  ```bash
  tmux -L mysocket new-session -d -s mysession
  ```

---

### 2. tmux on startup

- Automatically start tmux sessions on boot
- Add to /etc/rc.local or create a systemd service
  
OR add this to `.zshrc`

```bash
if [[ -z $TMUX ]]; then
  tmuxinator start poke
fi
```

---

## Debugging tmux

### 1. tmux Server Info

- Get detailed server information
- Command: `tmux server-info`

### 2. Logging

- Enable tmux logging for troubleshooting
- Start tmux with: `tmux -v`
- Or set in tmux.conf: `set-option -g @logging true`

---

## Bonus

## Tmuxinator

- 📁 Project-specific tmux configurations
- 🔄 Reproducible development environments
- 🚀 Quick start-up for complex project layouts
- 🔧 Customizable pre and post-project hooks

---

## Resources

- tmux GitHub: https://github.com/tmux/tmux
- tmux Cheat Sheet: https://tmuxcheatsheet.com/
- Awesome tmux: https://github.com/rothgar/awesome-tmux

---

```bash
../thats_all_folks
```
