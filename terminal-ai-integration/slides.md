---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM, YYYY
paging: Slide %d / %d
---

# Terminal-LLM Interaction Pattern 🤖

```bash
~~~just intro_toilet AI+Terminal

~~~
```

---

## The Vision 🎯

> "A controlled dialogue system where the LLM acts as an intelligent terminal assistant, with human oversight maintaining the command execution boundary."

---

## The Idea 💡

```bash
~~~just digraph interaction-pattern
It will be overriden by command output from the interaction-pattern.dot file.
~~~
```

---

## Key Components 🔧

**Buffer System**
```
┌─────────────────────┐
│ Current Command     │ ───┐
├─────────────────────┤    │    ┌─────────────────┐
│ Previous Output     │ ───┼───>│ Context Window  │
├─────────────────────┤    │    └─────────────────┘
│ System State        │ ───┘
└─────────────────────┘
```

---

## Prerequisites 🔧

* **Neovim**
  - gp.nvim plugin installed

* **Shell**
  - zsh >= 5.8

* **LLM Access**
  - API Keys 

---

## Simple Prompt 

>Generic instructions: Keep your responses short and simple, when asked to provide command, provide only one. Do not provide explanations unless explicitly asked for. When you need to find out something about my system or the environment, rather than asking, provide a one-liner command I can execute and which output would give you the desired information, make sure to provide only one command per answer and wait for me to execute it. When providing commands that save files, make sure to use the /home/decoder/dev path. When providing commands or code always enclose them in tripple backticks with appropriate scope, bash, python etc. If you would like to search internet, run script /home/decoder/dev/dotfiles/scripts/__search_internet.py with your query, do this freely and often and especially any time you need additional information or want to confirm the current state. User request below:

---

## Command Execution Flow 📝

1. **LLM Suggestion**
   ```bash
   # Single command with context
   ls -la | grep "\.txt$"
   ```

2. **Human Review**
   ```lua
   vim.keymap.set("n", "<leader>eap", "?```<CR>k eb<c-g><c-g>", { remap = true, silent = false })
   ```

3. **Execution & Capture**
   ```bash
   # Output captured in buffer
   Output of ls -la | grep "\.txt$":
   -rw-r--r-- 1 user group 2048 Jan 26 10:30 config.txt
   ```

---

## Implementation Details ⚙️

   - ZLE widget hooks into Zsh's pre-execution phase
   - STDERR/STDOUT redirection through temp file descriptor
   - Bi-directional pipe between shell and Neovim instance
   - Rolling buffer maintains last N commands and outputs

---

## Safety Features 🛡️

- Human review checkpoint
- Controlled information flow
- Buffer-based context management
- Error capture and analysis

---

## Demo Time 🎮

1. Troubleshoot kubectl command
3. Analyze logs

```bash
tmux switchc -t demo
```

---

# That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```
