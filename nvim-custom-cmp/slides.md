---
theme: ./theme.json
author: Cloud-Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Exploring Custom Completion in Neovim

```bash
~~~./intro.sh

~~~
```

---

## Agenda

- 🔥 Introduction to `nvim-cmp` and its capabilities
- 💡 Step-by-step custom completion source creation
- ✨ Example: Adding and managing project names
- 🤓 Interactive demonstration and hands-on example

---

## What is `nvim-cmp`?

- `nvim-cmp` -----> completion plugin
- It supports various completions sources:
  - LSP
  - Buffer
  - Snippet
  - Custom
More!

---

## Completion config overview

```bash
tmux switchc -t cmp-setup
```

> Other configuration options in plugin `:help nvim-cmp`

---

## Let's write our own completion!

### Goal 🥅

1. Use an external file called `~/projects.txt` to hold projects titles.

2. Load project names from the file into the completions engine.

3. Make them available under a dedicated section.

> Demo! 🚀

---

## How to wire it up

- Create folder with you custom sources
- Load in the `init.lua`

```bash
tmux switchc -t cmp-setup
```

> Super easy!

---

## Bonus Round: Module to add projects

```bash
tmux switchc -t user_functions
```

---

## How to use it

```bash
# Example usage:
# Add the project name "PROJECT: my_new_project" from the current line.
```

---

## Wrapping Up

- Setting up `cmp` sources and behavior
- Creating custom completion source

> Easy as pie!

---

```bash
../thats_all_folks
```
