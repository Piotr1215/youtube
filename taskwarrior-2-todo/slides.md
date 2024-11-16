---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Taskwarrior Neovim Integration

```bash
~~~just intro_toilet TODO to Task Magic

~~~
```

---

## Introduction 👋

- Integrate `taskwarrior` with `neovim`
  > Convert TODOs to tasks
  > Open and interact with tasks/TODOs

```bash
~~~just plantuml videos-progress

~~~
```

---

## Prerequisites 🛠️

- `taskopen`                         *taskwarrior plugin*  
  > taskwarrior plugin written in nim
- `tasks.lua`                        *custom neovim module*
  > custom nvim module written in lua
- `tmux`                             *terminal multiplexer*
  > custom bash script triggered via taskopen
- [optional] `taskwarrior-tui`       *taskwarrior TUI*
  > taskwarrior TUI written in rust  

---

### Flow 💮

```bash
~~~just plantuml prerequisites

~~~
```

---

## Quick Demo 🚀

```bash
tmux switchc -t demo
```

---

## Under the Hood: Nvim module 🛠️

```bash
tmux switchc -t nvim-module
```

---

## Under the Hood: Taskopen 🛠️

```bash
tmux switchc -t taskopen
```

---

## Under the Hood: Taskwarrior config 🛠️

```bash
tmux switchc -t taskwarrior-config
```

---

## Best Practices 💡

- Keep TODOs single-line
- Use consistent format
- Add project context
- Consider task urgency
- Regular task review

---

## Coming Next 🚀

```bash
~~~just freetext Reminders and Follow-ups

~~~
```

---

## That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```

