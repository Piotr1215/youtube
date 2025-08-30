---
title: beam.nvim - Remote Vim Operations
author: Cloud Native Corner
date: 2025-08-30
---



# beam.nvim

```bash +exec_replace
just intro_toilet beam.nvim
```

<!-- end_slide -->



## What Are Vim Operators?

> Operators are the **verbs** in Vim's editing grammar

```bash +exec +acquire_terminal
nvim -c "help operator" -c "only" -c "set nonumber" -c "norm 10j"
```

> Examples: `daw` (delete a word), `ci"` (change inside quotes)

<!-- end_slide -->



## What Are Vim Text Objects?

> Text objects define **what** you're operating on

```bash +exec +acquire_terminal
nvim -c "help text-objects" -c "only" -c "set nonumber" -c "norm 10j"
```

> Examples: `ciw` (change inner word), `da{` (delete around braces)

<!-- end_slide -->



## Native Line-Wise Operations

| Vim Native | beam.nvim |
|------------|-----------|
| `:5t10` - copy line 5 to line 10 | `,Y` + search for content |
| `:6m15` - move line 6 to line 15 | `,D` + search for content |
| Requires line numbers | Search by what you see |

> beam.nvim: No line numbers needed!

<!-- end_slide -->



## Traditional Vim Workflow

```bash +exec_replace
just plantuml traditional-vim-workflow
```

<!-- end_slide -->



## Demo

> Quick remote operations without breaking your flow!

```bash +exec
tmux switchc -t demo
```

<!-- end_slide -->



## beam.nvim Workflow

```bash +exec_replace
just plantuml beam-nvim-workflow
```

<!-- end_slide -->



## beam.nvim vs Motion Plugins

| Flash/Leap | beam.nvim |
|------------|-----------|
| Motion-first: "Jump, then operate" | Object-first: "I want *that* paragraph" |
| Great for exploratory edits | Direct when you know the target |
| Label-based navigation | Native `/` search |
| Maximum flexibility | Zero learning curve |

> They're complementary! Use flash for exploration, beam for targeted operations

<!-- end_slide -->



## Why Native Search?

| Feature | Benefit |
|---------|---------|
| Uses `/` search | Zero learning curve |
| Full buffer scan | Not limited to visible screen |
| `Ctrl-G` / `Ctrl-T` | Familiar navigation |
| Search highlights | Visual feedback before action |

> Perfect for "delete the paragraph containing TODO" workflows

<!-- end_slide -->



## Known Limitation

> Search highlights don't always match text object boundaries

| Issue | Impact |
|-------|--------|
| Search shows all matches | Visual only |
| `iw` boundaries vary by context | Operations still work correctly |
| Regex filtering needed | Not yet implemented |

<!-- end_slide -->



## Resources

| Resource | Link |
|----------|------|
| beam.nvim GitHub   | github.com/Piotr1215/beam.nvim |
| Vim Text Objects   | :help text-objects |
| Vim Operators      | :help operator |

<!-- end_slide -->



# That's All Folks!

```bash +exec_replace
just intro_toilet That\'s all folks!
```
