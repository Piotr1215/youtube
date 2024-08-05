---
theme: theme.json
author: Cloud-Native Corner 
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Nvim LSP Setup

```bash
~~~./intro.sh

~~~
```

---

## Agenda

- 💔 Not for the faint of heart, there is some configuring ahead
- 📄 Completion, LSP and code snippets go hand in hand
- 🔌 Must-have plugins
- 🛠️ Go through existing config and get recommendations
- 🎯 Goal is to understand the config and have a starter

> Great starter already exists: https://github.com/nvim-lua/kickstart.nvim

---

## What is LSP

- [Created by Microsoft](https://microsoft.github.io/language-server-protocol/)
> The idea behind the Language Server Protocol (LSP) is to standardize the
> protocol for how such servers and development tools communicate. This way, a
> single Language Server can be re-used in multiple development tools, which in
> turn can support multiple languages with minimal effort.

- Contract between editors and languages
- Connect external programs and process in nvim

```bash
       ┌─┐                                          
       ║"│                                          
       └┬┘                                          
       ┌┼┐                                          
        │             ┌──────┐                 ┌───┐
       ┌┴┐            │ nvim │                 │LSP│
      User            └───┬──┘                 └─┬─┘
        │         Installs LSP program           │  
        │───────────────────────────────────────>│  
        │                 │                      │  
        │                 │      Connects        │  
        │                 │─────────────────────>│  
        │                 │                      │  
        │                 │Send/Receive messages │  
        │                 │<────────────────────>│  
        │                 │                      │  
        │                 │                      │  
```

---

## LSP in Neovim

- builtin client exposing API via `vim.lsp`
- diagnostics with `vim.diagnostics`  
- `Lsp...` commands from `nvim-lspconfig`

---

## LSP Features

> Depends on the LSP server implementaiton

- Go to declaration and definition
- Lists implementations and references
- Display a function's signature information (normal and insert mode)
- Rename 
- Code actions
- Format file or range

---


## LSP Plugins

- `mason.nvim`                      -----> manage external editor tooling (LSP servers, DAP servers, linters, formatters)
- [Optional] `mason-lspconfig.nvim` -----> mason <> nvim-lspconfig integration 
- `nvim-lspconfig`                  -----> configure LSP settings and language servers (:Lsp... commands)

> There are many more

---

## LSP and completion

> Code completion comes from LSP but is implemented via a completion plugin

- `vim.lsp.buf.completion()`      -----> get completion items in insert mode
- `nvim.cmp`                      -----> completion plugin that integrates with LSP

```lua
local lspconfig = require('lspconfig')
local def = require('lsp.default-lsp')

lspconfig.lua_ls.setup({
  capabilities = def.capabilities
  on_attach = def.on_attach,
})
```

---

## Default LSP settings

> Recommendation: create reusable module with the default LSP settings

Let's implement the module

---

## LSP Setup for Go

> LSP in action editing simple *.go file

---

## Bonus: inlay hints

> Available in nvim > 0.10.0 toggle virtual inlay hints

```lua
vim.keymap.set("n", "<leader>ih", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { silent = true, noremap = true, desc = "Toggle inlay hints" })
```                                             

---

## That's all folks

```
~~~chafa --format symbols folks.jpg
placeholder text
~~~
```
