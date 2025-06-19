---
theme: ../theme.json
author: Cloud Native Corner
date: June 14, 2025
paging: Slide %d / %d
---

# Terminal Shortcuts System 🚀

```bash
~~~just intro_toilet Terminal Shortcuts

~~~
```

---

## The Problem 🤔

- Too many apps, too many shortcuts
- Can't remember all keybindings  
- No unified way to search shortcuts
- Documentation scattered everywhere

```bash
~~~just freetext Solution: Build Your Own!

~~~
```

---

## What We'll Build Today 🎯

> A searchable, extensible shortcuts help system

- Instant access
- Fuzzy searchable
- YAML-based
- Category browsing

---

## System Architecture 🔧

```bash
~~~just digraph shortcuts-architecture

~~~
```

---

## The YAML Structure 📝

```yaml
app_name:
  description: "What the app does"
  shortcuts:
    - description: "Action description"
      binding: "Key combination"
    - description: "Another action"  
      binding: "Another key"
```

---

## Demo Time! 🎬

```bash
tmux switchc -t demo
```

---

## Core Script Components

Core components:
- `yq` for YAML parsing
- `fzf` for fuzzy search  
- `autokey` for bindings, but xbind or others would work just fine
- Custom preview formatting
- Category/all mode switching

---

## Benefits

- Centralized:  *One source of truth*
- Searchable:   *Find anything instantly*
- Extensible:   *Add any app easily*
- Maintainable: *Simple YAML format*

---

### Resources 📚

- [fzf documentation](https://github.com/junegunn/fzf)
- [yq YAML processor](https://github.com/mikefarah/yq)
- [Autokey setup](https://github.com/autokey/autokey)

---

# That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```

