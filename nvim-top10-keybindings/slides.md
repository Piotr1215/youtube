---
theme: ./theme.json
author: Cloud-Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Top 20 Keybingins in Neovim

```bash
~~~./intro.sh

~~~
```

---

## Introduction

- 🔑 key bindings setup with `vim.keymap.set`
- 🚫 avoid application specific bindings
- 🛠️ focus on utility
- ❓ what are your favorite?

---

## Terminal

```lua
vim.keymap.set("n", "<leader>Tsv", ":vsp term://", { desc = "Open vertical terminal split" })
vim.keymap.set("n", "<leader>Tsh", ":sp term://",  { desc = "Open horizontal terminal split" })
```

---

## Selection

```lua
vim.keymap.set("n", "L", "vg_",    { desc = "Select to end of line" })
vim.keymap.set('n', '<leader>pa', 'ggVGp',         { desc = "select all and paste" })
vim.keymap.set('n', '<leader>sa', 'ggVG',          { desc = "select all" })
vim.keymap.set("n", "<leader>gp", "`[v`]", { desc = "select pasted text" })
```

---

## Center screen after various operations

```lua
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "scroll up and center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "scroll down and center" })
vim.keymap.set("n", "n", "nzzzv",       { desc = "keep cursor centered" })
vim.keymap.set("n", "N", "Nzzzv",       { desc = "keep cursor centered" })
                                        
```

---

## Git related

```lua
vim.keymap.set({ "n", "v" }, "<leader>gbf", ":GBrowse<cr>", { desc = "Git browse current file in browser" })
vim.keymap.set("n", "<leader>gbc", function()               
  vim.cmd "GBrowse!"                                       
end,                                                       { desc = "Copy URL to current file" })
vim.keymap.set("v", "<leader>gbl", ":GBrowse!<CR>",         { desc = "Git browse current file and selected line in browser" })
vim.keymap.set("n", "gd", ":Gvdiffsplit<CR>",              { desc = "Git diff current file" })
```

---

## Remap backspace to ^

```lua
vim.keymap.set("n", "<BS>", "^", { desc = "Move to first non-blank character" })
```

---

## Move current line/selection up/down

```lua
vim.keymap.set("n", "<leader>mj", ":m .+1<CR>==",     { desc = "Move line down" })
vim.keymap.set("n", "<leader>mk", ":m .-2<CR>==",     { desc = "Move line up" })
vim.keymap.set("v", "<leader>mj", ":m '>+1<CR>gv=gv", { desc = "Move Line Down in Visual Mode" })
vim.keymap.set("v", "<leader>mk", ":m '<-2<CR>gv=gv", { desc = "Move Line Up in Visual Mode" })
```

---

## Search and replace

```lua
vim.keymap.set('n', '<leader>ss', ':s/\\v',                             { desc = "search and replace on line" })
vim.keymap.set('n', '<leader>SS', ':%s/\\v',                            { desc = "search and replace in file" })
vim.keymap.set('v', '<leader><C-s>', ':s/\\%V',                 { desc = "Search only in visual selection using %V atom" })
vim.keymap.set('v', '<leader><C-r>', '"hy:%s/\\v<C-r>h//g<left><left>', { desc = "change selection" })
```

---

## Yank and put mappings

```lua
vim.keymap.set("i", "<c-p>", function()
  require("telescope.builtin").registers()
end, { remap = true, silent = false, desc = " and paste register in insert mode", })

vim.keymap.set("n", "<leader>yf", ":%y<cr>", { desc = "yank current file to the clipboard buffer" })


```

---

## Delete mappings

```lua
vim.keymap.set('n', '<leader>df', ':%d_<cr>', { desc = 'delete file content to black hole register' })
```

---

## File operations

```lua
vim.keymap.set("n", "<leader>w", ":w<CR>",    { desc = "Quick save" })
vim.keymap.set("n", "<leader>cx", ":!chmod +x %<cr>", { desc = "make file executable" })
vim.keymap.set(
  "n",
  "<leader>cpf",
  ':let @+ = expand("%:p")<cr>:lua print("Copied path to: " .. vim.fn.expand("%:p"))<cr>',
  { desc = "Copy current file name and path", silent = false }
)
```

---

```bash
../thats_all_folks
```
