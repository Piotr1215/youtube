---
theme: ./theme.json
author: Cloud-Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Top 10 Neovim Plugins

```bash
~~~./intro.sh

~~~
```

---

## Agenda

- 🔥 subjective list of most used and amazing plugins
- 💡 example usecases and mini-demos
- ✨ at the end you might get some ideas
- 🤓 yes, I have a small plugin-problem 😁

---

## Selection Criteria

- not only for programmers
- not super general utility like plugin managers or LSP related
- good bang for the buck, easy to setup

> Here they are in no particular order

---

## Navigation

### 1. alexghergh/nvim-tmux-navigation 🌟 286 stars 🌟

> This plugin enables seamless navigation between tmux panes and Neovim splits, enhancing productivity and workflow for developers who frequently use both tools.

```bash
tmux switchc -t navigation
```

---

## Utility

### 2. RRethy/nvim-align 🌟 35 stars 🌟

> A versatile alignment plugin that helps format text and code by aligning characters based on custom patterns, making code more readable and organized.

### 3. machakann/vim-swap 🌟 287 stars 🌟

> Swap words, lines, function arguments etc

```bash
tmux switchc -t utility
```

---

## Editing Enhancements

### 4. preservim/nerdcommenter 🌟 4955 stars 🌟

> A powerful commenting plugin that simplifies the process of adding, removing, and toggling comments in code, supporting multiple programming languages and comment styles.

### 5. kylechui/nvim-surround 🌟 2986 stars 🌟

> Provides functionalities to easily add, change, and delete surrounding characters such as parentheses, brackets, quotes, and more, enhancing text editing efficiency.

```bash
tmux switchc -t enhancements
```

---

## Search and Navigation

### 6. xiyaowong/telescope-emoji.nvim 🌟 112 stars 🌟

> An extension for Telescope.nvim that allows users to search and insert emojis into their text, improving expressiveness and fun in coding and documentation.

```bash
tmux switchc -t search
```

---

## Quickfix Enhancements

### 7. yssl/QFEnter 🌟 175 stars 🌟

> Enhances the quickfix list by allowing users to open items in the quickfix list with a single keystroke, streamlining the process of navigating and resolving issues.

### 8. kevinhwang91/nvim-bqf 🌟 1644 stars 🌟

> A better quickfix window plugin that adds more functionality and customization options to the quickfix list, making it more powerful and user-friendly.

> Those are awesome, demo time!

```bash
tmux switchc -t quickfix
```

---

## File Handling

### 9. echasnovski/mini.files 🌟 205 stars 🌟

> A minimalistic file explorer plugin that provides a simple and efficient way to navigate and manage files within Neovim, focusing on speed and ease of use.

> Alternative is `oil.nvim`, but this one works better for me.

### 10. mhinz/vim-startify 🌟 5284 stars 🌟

> A startup screen for Neovim that provides a customizable dashboard with options to quickly access recent files, sessions, bookmarks, and more, improving the initial user experience.

> There is nvim specific plugin, but I still use this one.

```bash
tmux switchc -t filehandling
```

---

## UI/UX Improvements

### 11. robitx/gp.nvim 🌟 616 stars 🌟

> A plugin focused on enhancing the graphical presentation within Neovim, providing better UI elements and aesthetics for a more pleasant coding environment.

```bash
alias -g A='| tee /tmp/nvim_buffer_input | sed -r "s/\x1b\[[0-9;]*m//g" > /tmp/nvim_buffer_cleaned && nvim -c "GpChatNew" -c "normal! Go" -c "r /tmp/nvim_buffer_cleaned" -c "normal! Gdd"'
```

---

### 12. shortcuts/no-neck-pain.nvim 🌟 487 stars 🌟

> Designed to improve ergonomics by providing better window management and layout adjustments, helping users avoid neck strain during long coding sessions.

> Can be combined with fixed scroll position. Alternative is `zen-mode.nvim`

### 13. folke/tokyonight.nvim 🌟 6013 stars 🌟

> A beautiful and popular colorscheme for Neovim, inspired by Tokyo's night life, providing vibrant colors and a visually appealing coding experience.

> I like clean and crisp dark themes

```bash
tmux switchc -t uiux
```
---

## Markdown and Documentation

### 14. jubnzv/mdeval.nvim 🌟 165 stars 🌟

> A plugin for evaluating code blocks within markdown files, supporting multiple programming languages, and enhancing documentation with executable examples.

> Has a lot of applications:
>
> - interactive learning
> - automated runbooks
> - markdown snippets evaluation

```bash
tmux switchc -t markdown
```
---

### 15. epwalsh/obsidian.nvim 🌟 3547 stars 🌟

> Integrates with Obsidian, a knowledge base application, allowing users to manage and navigate their notes and documents directly within Neovim.

> power of obsidian without the UI clutter

---

## That's all folks!

```bash
../thats_all_folks
```

