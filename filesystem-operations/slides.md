---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# FileSystem Operations 🗂️ 

```bash
~~~just intro_toilet FileSystem Operations

~~~
```

---

## What is a FileSystem? 🌲

```bash
~~~just digraph filesystem

~~~
```

---

## Common Operations 🛠️

```bash
OS File Operations
┌─────────────────┬──────────────────┬───────────────────┐
│                 │                  │                   │
Creation      Organization        Security          Compression
│                 │                  │                   │
├─Read            ├─Copy             ├─Permissions       ├─Compress
├─Write           ├─Move             ├─Ownership         └─Encrypt
├─Make Dir        └─Search           └─Metadata          
├─Open
└─Delete
```

---

## DIY Approach: Power Tools 🔧

- `fzf`    *Fuzzy finder*
- `fd`     *Modern find*
- `rg`     *Ripgrep search*
- `zoxide` *Smart directory jumper*
- `bat`    *Better cat*
- `exa`    *Modern ls*

---

## DIY setup 🔍

```bash
tmux switchc -t demo
```

---

## Terminal File Managers 📐

> Yazi  = spatial navigator        *current location and immediate context*
> Broot = hierarchical analyzer    *tree structure as a queryable database*

```bash
~~~just digraph editor-layouts

~~~
```

---
## File Managers 🔍

```bash
tmux switchc -t tuis
```

---

## Key Takeaways 💡

1. Learn tool combinations
2. Create custom aliases
3. Use fuzzy finding everywhere
4. Leverage file previews
5. Keyboard shortcuts

---

## Resources & Links 🔗

- Modern Unix: github.com/ibraheemdev/modern-unix
- Yazi: github.com/sxyazi/yazi
- Broot: github.com/Canop/broot
- FZF: github.com/junegunn/fzf
