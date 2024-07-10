---
theme: theme.json
author: Cloud-Native Corner 
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# 🚀 Vim External Commands: Supercharge Your Workflow

```bash
~~~./intro.sh

~~~
```

---

## 🔧 Vim External Commands: Quick Reference

- `:!{cmd}` - 🖥️ Execute shell command, display output
- `:r !{cmd}` - 📥 Execute command, insert output below cursor
- `:w !{cmd}` - 📤 Send current buffer as stdin to command
- `:.!{cmd}` - 🔄 Replace current line with command output
- `:%!{cmd}` - 📄 Replace entire buffer with command output
- `:'<,'>!{cmd}` - ✂️ Replace selection with command output

---

## 💻 Practical Examples

### 1. 📁 !{cmd}: Quick File Backup

Create a backup of the current file:
```bash
../npane ./backup.md
```

---
### 2. 📋 :r !{cmd}: Insert External Data

Insert command output into your document:
```bash
../npane ./external_insert.md
```

---
### 3. 🔨 :w !{cmd}: Use Buffer as Command Input

Create files from buffer content:
```bash
../npane ./external_send.md
```
> 💡 One line is passed as an argument to the command at a time

---

## 🔄 Line and Selection Manipulation

### 1. 🔓 :.!{cmd}: Decode Base64 String

Decode a base64 string in the current line:
```bash
../npane ./replace_line.md
```

---
### 2. 🎨 :.!{cmd}: Format JSON

Pretty-print JSON on the current line:
```bash
../npane ./replace_line_2.md
```

---
### 3. 📊 :'<,'>!{cmd}: Sort Selection

Sort a selected list numerically:
```bash
../npane ./sort_selection.md
```

---

## 🔧 Custom Key Bindings for Shell Integration

```lua
-- 🏃 Execute current line and output to command line
vim.keymap.set("n", "<leader>ex", ":.w !bash -e<cr>", opts)
-- 📜 Execute all lines and output to command line
vim.keymap.set("n", "<leader>eX", ":%w !bash -e<cr>", opts)
-- 🔁 Execute current line and replace with result
vim.keymap.set("n", "<leader>el", ":.!bash -e<cr>", { noremap = true, silent = false })
-- 📄 Execute all lines and replace with result
vim.keymap.set("n", "<leader>eL", ":% !bash %<cr>", opts)
-- 🔓 Make file executable
vim.keymap.set("n", "<leader>cx", ":!chmod +x %<cr>", opts)
-- 🚀 Execute file and show output
vim.keymap.set("n", "<leader>ef", "<cmd>lua *G.execute*file_and_show_output()<CR>", { noremap = true, silent = false })
```

---

## 📝 Summary

- Vim's external commands provide powerful integration with the shell
- Use `:!cmd` for quick shell access without leaving Vim
- `:r !cmd` and `:w !cmd` for input/output operations with external commands
- `:.!cmd` and `:%!cmd` for in-place text transformations
- `:'<,'>!cmd` for processing selected text
- Custom key bindings streamline common shell interactions

