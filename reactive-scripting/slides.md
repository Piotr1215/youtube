---
theme: ../theme.json
author: Cloud Native Corner
date: May, 2025
paging: Slide %d / %d
---

# Reactive Scripting 🔄

```bash
~~~just intro_toilet Reactive Scripting

~~~
```

---

## What is Reactive Scripting?

- 📂 Respond to file content changes  
- 🖥️ Monitor process state changes
- 📁 Watch filesystem events
- 🔍 Track command output changes

> Reactive scripting connects system events to your desired actions

---

## When to Use Reactive Scripting? 💡

- Working on your project and need to:           *respond to changes now*
- Repeatedly checking the same thing:            *automate the checks*
- Manually running commands after edits:         *let the system do it*
- Need quick automation without a service:       *perfect middle ground*

> "I need this today, not a whole systemd service"

---

## Tool #1: `entr` - React to Content Changes 📝

For when you're actively editing files:

```bash
tldr entr
```

---

## Tool #2: `watch` - React to Command Output 👀

For monitoring any command's output:

```bash
tldr watch
```

---

## Tool #3: `fswatch` - React to Filesystem Events 📁

For monitoring directories and filesystem operations:

```bash
tldr fswatch
```

---

## Key Differences

> When to use what

|                | `entr`               | `viddy`              | `fswatch`           |
|----------------|----------------------|----------------------|---------------------|
| Triggers on    | Content changes      | Command output       | Filesystem events   |
| Focus          | Files you're editing | System state changes | Directory watching  |
| Best for       | Dev workflows        | Process monitoring   | Event handling      |

---

## Demo 

```bash
tmux switchc -t reactive-demo
```

---

## Resources 📚

- `entr`: [http://eradman.com/entrproject/](http://eradman.com/entrproject/)
- `fswatch`: [https://github.com/emcrisostomo/fswatch](https://github.com/emcrisostomo/fswatch)
- Alternative: `inotifywait` (part of inotify-tools)

---

# That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```
