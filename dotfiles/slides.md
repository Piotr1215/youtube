---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM, YYYY
paging: Slide %d / %d
---

# Dotfiles

```bash
~~~just intro_toilet Manage Doftiles

~~~
```

---

## Introduction 👋

- What are dotfiles?             *Configuration files*
- Need to version control:       *Git*
- 3 Levels of managing dotfiles: *Manual, Stow, Tools*

---

## Dotfiles Repository 📁

```bash
exa ~/dev/dotfiles --color=always --long --all --header --icons --git 
```

---

## Symlink 🔄

* Symlink:  *Pointer to another file*
```bash
../cpane "man 7 symlink"
```

---

## Stow 📦

* Stow: *Symlink manager*
```bash
../cpane "man 8 stow"
```

---

## Other Tools 🛠

- YADM: *Yet Another Dotfiles Manager*
- Chezmoi: *Dotfile manager with encryption*

```bash
../cpane "man 1 yadm"
```


---

## Demo 🎬

```bash
tmux switchc -t demo
```


---

## Tips and Best Practices 💁

- Dotfiles backup != Data backup
- Careful with symlinks
- Srart small, use tools when needed

---

## Resources 🧰

- [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles)

---

## That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```

