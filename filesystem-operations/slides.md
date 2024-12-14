---
theme: ../theme.json
author: Cloud Native Corner
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

- Learn tool combinations
- Create custom aliases
- Use fuzzy finding everywhere
- Leverage file previews
- Keyboard shortcuts

---

## Resources & Links 🔗

- [Modern Unix](https://github.com/ibraheemdev/modern-unix)
- [Yazi](https://github.com/sxyazi/yazi)
- [Broot](https://github.com/Canop/broot)
- [FZF](https://github.com/junegunn/fzf)

---

## That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```

