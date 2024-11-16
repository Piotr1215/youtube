---
theme: ./theme.json
author: Cloud Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Taskwarrior Setup & Workflow

```bash
~~~./intro.sh

~~~
```

---

## Introduction

- 📝 taskwarrior: CLI Task Management Tool
- 🔧 Custom Setup with:
  - Neovim Integration   <----- code-centric workflow
  - taskwarrior TUI      <----- terminal UI
  - Hooks & Scripts      <----- automation
  - Tmux Integration     <----- seamless context switching

```
┌──────────────┐         ┌──────────────┐
│   Neovim     │ ←─────→ │  taskwarrior │
└──────┬───────┘         └──────┬───────┘
       │                        │
       │         ┌──────────────┘
       │         │
       ▼         ▼
    ┌──────────────┐
    │     Tmux     │
    └──────────────┘
```

---

## Basic Workflow Demo

Taskwarrior basics:

1. Add task: `task add +work "implement new feature"`
2. List tasks: `task list`
3. Mark done: `task 1 done`
4. Filter by tag: `task +work list`

---

## Neovim Integration

Key bindings for seamless workflow:

```bash
tmux switchc -t taskwarrior
```


```
╭────────────────────────────────────╮
│ Ctrl+t    Create task from TODO    │
│ <leader>gt Go to task in TUI       │
│ <leader>dt Mark task as done       │
╰────────────────────────────────────╯
```

Example TODO comment:
```bash
# TODO: Implement error handling for edge cases
```

---

## Scripts & Hooks Demo

```bash
tmux switchc -t taskwarrior
```

Custom scripts:
- 🔄 `__cycle_tmuxinator_projects.sh`
- 🔍 `__github_issue_sync.sh`
- 📝 `__annotate_with_note.sh`
- ⚡ `__switch_to_tui.sh`

```
Task ──► Hook ──► Script ──► Action
```

---

## Reports and Contexts

Custom Reports:
```
┌─────────────┐
│ workdone    │ completed tasks
│ currentall  │ all pending tasks
│ tmark       │ tasks to report
│ tmark-next  │ upcoming tasks
└─────────────┘
```

Context Support:
- `work`      <----- work related tasks
- `home`      <----- personal tasks
- `temp`      <----- temporary tasks

---

## Advanced: Firefox Integration with AutoKey

```
┌───────────────┐         ┌───────────────┐
│    AutoKey    │─────────│    Zenity     │
│    Script     │   GUI   │    Dialog     │
└───────┬───────┘         └───────┬───────┘
        │                         │
        │         Task            │
        │         Info            │
        ▼                         ▼
    ┌─────────────────────────────────┐
    │           taskwarrior           │
    └─────────────────────────────────┘
```

---

### Integration Workflow

- 🔗 URL Integration
- 📋 Clipboard Management
- 📝 Project Selection
- 🏷️ Category Tagging (+work/+home)


```bash
+-----------+                +----------+             +-----------+          +------------+
|    User   |                |  Script  |             | Clipboard |          | Taskwarrior|
+-----------+                +----------+             +-----------+          +------------+
      |                            |                        |                       |
      | Trigger script             |                        |                       |
      | (keyboard shortcut)        |                        |                       |
      +--------------------------->|                        |                       |
      |                            |                        |                       |
      |                            | Copy URL               |                       |
      |                            +----------------------->|                       |
      |                            |                        |                       |
      |                            | Show zenity dialog     |                       |
      |                            +<-----------------------|                       |
      |                            |                        |                       |
      | Select project & category  |                        |                       |
      +--------------------------->|                        |                       |
      |                            |                        | Create task           |
      |                            |----------------------------------------------->|
      |                            |                        |                       |

```

---

### Implementation

```python
def create_task(url):
    projects = get_projects()
    task = display_task_dialog(projects)
    if task:
        category_label = f"+{task['category'].lower()}"
        project_arg = f"project:{task['project']}"
        # Execute create_task script...
```

---

## Summary

1. 🎯 Integrated Development Workflow
2. ⚡ Fast Context Switching
3. 🔧 Extensible with Scripts
4. 📝 Code-Centric Task Management

Next Steps:
- Check the docs: `man task`
- Review hooks: `~/.task/hooks/`
- Explore TUI: `taskwarrior-tui`

---

## That's All Folks!

```bash
../thats_all_folks
```
