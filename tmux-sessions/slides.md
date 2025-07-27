---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM, YYYY
paging: Slide %d / %d
---

# The Five Types of tmux Sessions 🚀

```bash
~~~just intro_toilet tmux sessions

~~~
```

---

## Introduction

- 🎯 **Mental model** for session design
- 🔧 **Programmable workspaces** beyond layouts
- 📝 **Five categories** to expand possibilities

---

## What are tmux Sessions?

> Terminal sessions as **programmable, composable, and contextual workspaces**

Not just isolated terminal layouts, but a powerful framework for organizing work

---

## 1. Static Sessions 📋

**Fixed structure, predictable workflows**

- Same layout every time (docs, monitoring, daily tasks)
- Optimized for muscle memory
- Zero decision overhead

```yaml
windows:
  - editor: vim README.md
  - preview: mdbook serve
  - git: git status
```

> **Design Philosophy:** Consistency enables speed

---

## 2. Dynamic Sessions 🔄

**Parameterized blueprints that adapt to context**

- Template structure, dynamic content
- Context-aware via ERB/environment variables
- Example: `git-monitor-<repo>` sessions

```yaml
root: <%= ENV['PWD'] || Dir.pwd %>
windows:
  - git-monitor:
      panes:
        - lazygit
        - gh pr list
```

> **Design Philosophy:** Reuse patterns, adapt details

---

## 3. Event-Based Sessions 🚨

**Triggered by external tools or system states**

- System events spawn appropriate workspaces
- Hooks into monitoring, CI/CD, webhooks
- Zero manual intervention

```bash
# Triggered by systemd on high CPU
if [ $CPU_USAGE -gt 80 ]; then
  tmuxinator start debug-cpu
fi
```

> **Design Philosophy:** Automation eliminates context switching

---

## 4. Ephemeral Sessions ⏱️

**Short-lived workspaces tied to task lifecycle**

- Auto-terminate when process exits
- No manual cleanup required
- Perfect for one-off tasks

```yaml
attach: false
on_project_exit: tmux kill-session -t <%= name %>
windows:
  - build: cargo build --release
```

> **Design Philosophy:** Self-cleaning workspace management

---

## 5. Compositional Sessions 🎨

**Built interactively through incremental assembly**

- UI-driven creation (M-c for Pet snippets)
- Add panes to session bound window

```bash
# M-c → Pet search → select command
# Creates window dynamically
tmux new-window -n "$name" -c "$dir"
```

> **Design Philosophy:** Build workspaces through exploration

---

## Session Type Comparison

| Type          | Structure      | Persistence | Use Case              |
|---------------|----------------|-------------|-----------------------|
| **Static**    | Fixed          | Named file  | Routine workflows     |
| **Dynamic**   | Parameterized  | Template    | Project patterns      |
| **Event**     | Reactive       | Triggered   | System responses      |
| **Ephemeral** | Temporary      | None        | Quick tasks           |
| **Compositional** | Interactive | Optional    | Exploratory work      |

---

## Key Learnings

**Sessions as task-based workspaces, not just terminal layouts**

- **Mental model shift**: Each session type matches how you naturally work
- **Context awareness**: Sessions adapt to project, repository, or system state  
- **Abstraction layer**: tmux/tmuxinator becomes your workspace operating system

> Think task-oriented workspaces, not terminal windows.

---

## Resources 📚

- [tmuxinator Documentation](https://github.com/tmuxinator/tmuxinator)
- [tmux Cheat Sheet](https://tmuxcheatsheet.com/)
- [FZF Integration Guide](https://github.com/junegunn/fzf/wiki)
- [Event-Driven Shell Scripts](https://www.shellscript.sh/)

---

# That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```
