---
theme: theme.json
author: Cloud-Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Neovim for Cloud Engineers: Working with YAML

```bash
~~~./intro.sh

~~~
```

---

## Introduction


- Neovim: A hyper-extensible Vim-based text editor
- Advantages for cloud engineers:
  - 🚀 Lightweight and fast
  - 🔧 Highly customizable
  - 🧩 Powerful plugin ecosystem
    
---

## System Integration

- Set Neovim as default editor
```bash
export EDITOR=nvim
```
- Git commit message integration
```bash
git config --global core.editor "nvim"
```

---

## Initial Setup

- Kickstart your configuration:
  - `https://github.com/nvim-lua/kickstart.nvim`
  - Excellent starting point for Lua-based config

```bash
open https://github.com/nvim-lua/kickstart.nvim
```

---

## YAML settings

- Use `ftplugin` for language-specific settings

```bash
tmux select-window -t 2
```

**Important points:**

- Indent-based folding for YAML
- Guiding line for indentation

---

## Further Learning:

- Neovim documentation: https://neovim.io/doc/
- r/neovim subreddit
- GitHub: neovim/neovim
