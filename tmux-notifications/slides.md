---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Tmux Interceptor

```bash
~~~just intro_toilet Intercept & Act

~~~
```

---

## The Problem 🎯

> Reacting to text in terminal panes

- Missing prompts across tmux sessions:       *Context switching overhead*
- Quickly identify tmux session:              *Manual attention required*
- Act on the information:                     *Execute arbitrary logic*

---

## Inputs & Outputs 🔄

- Inputs:     *stdin/out/err, terminal events*
- Bindings:   *filesystem*
- Outputs:    *any executable*

---

## Architecture 🏗️

```bash
~~~just plantuml architecture

~~~
```

---

## File-Based Philosophy 📁

> Unix: Everything is a file

- Atomic operations:    *No race conditions*
- FIFO processing:      *Timestamp ordering*
- Distributed:          *No central coordination*

---

## Demo Session

```bash
tmux switchc -t demo
```

---

## Highlights 💡

- open source tools
- file system as a message queue
- distributed system with decoupled components

---

## Resources 📚

- [tmux documentation](https://github.com/tmux/tmux)
- [Argos GNOME extension](https://github.com/p-e-w/argos)
- [Unix philosophy](https://en.wikipedia.org/wiki/Unix_philosophy)

---

# That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```
