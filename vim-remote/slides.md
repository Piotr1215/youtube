---
theme: theme.json
author: Cloud-Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Neovim for Cloud Engineers: Boosting Productivity in the Terminal

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
../npane ~/.config/nvim/ftplugin/yaml.lua
```

**Important points:**

- Indent-based folding for YAML
- Guiding line for indentation

---

## Productivity Boosters

- ✂️ Snippets with vsnip: `open https://github.com/hrsh7th/vim-vsnip`
- Snippet example:

```bash
../npane ~/dev/dotfiles/.vsnip/yaml.json
```

---

## Remote Editing and Pair Programming

- 🌐 Remote editing on cloud instances
  - `nvim scp://user@host//path/to/file`
  - `nvim --remote` for opening files in existing Neovim instance
   
- 🔒 SSH and remote editing
  - `open https://github.com/NOSDuco/remote-sshfs.nvim`
  - `open https://github.com/amitds1997/remote-nvim.nvim`

---

## Further Learning:

- Neovim documentation: https://neovim.io/doc/
- r/neovim subreddit
- GitHub: neovim/neovim
