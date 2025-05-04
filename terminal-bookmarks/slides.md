---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM, YYYY
paging: Slide %d / %d
---

# Terminal and Neovim Bookmark Manager

```bash
~~~just intro_toilet Bookmark Manager
  
~~~
```

---

## Why Bookmarks?

- Access to files and directories everywhere in the terminal
- List in plain text
- Easy edit, save, backup, version

---

## The Problem

> "Bookmarks are not easy to find"

> "I have separate workflows for terminal and editor"

> "I'm tired of typing the same paths over and over"

---

## Solution

A unified bookmark system that works from:

- Terminal/tmux sessions

- Neovim editor

---

## Key Features

- **Unified Storage**:                *Single bookmarks file*
- **Two-Way Access**:                 *Terminal and Neovim*
- **Smart Handling**:                 *Files vs. Directories*
- **Bookmarks Management**:           *Add, Delete, List, Edit*
- **Existing Tool Integration**:      *FZF and Telescope*

---

## Architecture Overview

```
~~~just digraph bookmarks_system

~~~
```

---

## Simple Storage Format

description;/path/to/file/or/directory


- Human-readable:       *Easy to view and edit manually*
- Easy to parse:        *Works in both Bash and Lua*
- Minimal overhead:     *Simple ASCII format, no special tools needed*

---

## Example Workflow

```
~~~just plantuml bookmark_workflow

~~~
```

---

## Demo

```bash
tmux switchc -t bookmarks-demo
```

---

## Resources 📚

- Neovim Telescope:   *github.com/nvim-telescope/telescope.nvim*

- FZF:                *github.com/junegunn/fzf*

- Tmux Sessionizer:   *github.com/Piotr1215/dotfiles/blob/master/scripts/__sessionizer.sh*

---

## That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!
  
~~~
```
