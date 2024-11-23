---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Taskwarrior Neovim Integration

```bash
~~~just intro_toilet Taskwarrior <--> Neovim

~~~
```

---

## Video Series 📹

```bash
~~~just plantuml videos-progress

~~~
```

---

## Introduction 👋

- Integrate `taskwarrior` with `neovim`
  > Convert TODOs to tasks
  > Open and interact with tasks/TODOs
- Central repository of tasks from comments
  > `TODO` comments in code
  > `TODO` comments in markdown

---

## Prerequisites 🛠️

- `taskopen`                         *taskwarrior plugin*  
  > taskwarrior plugin written in nim
- `tasks.lua`                        *custom neovim module*
  > custom nvim module written in lua
- `tmux`                             *terminal multiplexer*
  > custom bash script triggered via taskopen
- [optional] `taskwarrior-tui`       *tasks command center*
  > TUI written in rust  

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

## Under the Hood: Taskwarrior Annotations 📓 

- Annotations: *a way to add notes to a task.*
- Format:      *`<date>` -- `<text>`* 
- Number:      *There can be any number of them.*
- Separator:   *' -- ' separator between date and text*

```bash
Annotation:        2024-11-17 13:13:47 -- probably memory leak
Annotation:        2024-11-17 13:13:49 -- 
```

---

## Under the Hood: Taskopen ␣

> It allows you to link almost any `file`, `webpage` or `command` to a taskwarrior task by adding a filepath, web-link or uri as an `annotation`. Text notes, images, PDF files, web addresses, spreadsheets and many other types of links can then be filtered, listed and `opened` by using taskopen.

> Arbitrary actions can be configured with taskopen to filter and act on the annotations or other task attributes.

---

## Under the Hood: Nvim module 🛠️

```bash
tmux switchc -t nvim-module
```

---

## Under the Hood: Taskopen Config 🛠️

```bash
tmux switchc -t taskopen
```

---

## Under the Hood: Taskwarrior config 🛠️

```bash
tmux switchc -t taskwarrior-config
```

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

