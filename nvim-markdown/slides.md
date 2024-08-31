---
theme: ./theme.json
author: Cloud-Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Writing Markdown in Neovim

```bash
~~~./intro.sh

~~~
```

---

## Introduction

- 📝 Writing READMEs or prose in neovim
- 🔧 Useful Plugins
- 🌟 Grammar, thesaurus, and image handling tools
- 📜 Custom settings and keybindings

---

## Plugins

### Markdown Editing

- `sbdchd/neoformat`: Auto-format Markdown files
- `ixru/nvim-markdown`: Markdown-specific enhancements
- `iamcco/markdown-preview.nvim`: Live preview of Markdown files
- `dhruvasagar/vim-open-url`: Open URLs directly from Neovim

### Nice To Have

- `jubnzv/mdeval.nvim`: Evaluate code blocks within Markdown. Alternative newer one `sniprun.nvim`
- `AckslD/nvim-FeMaco.lua`: Inject LSP into code blocks

---

## Use `ftplugin` for configuration

- Load settings only when editing Markdown files
- Keep global configuration clean and minimal
- Create a directory: `~/.config/nvim/ftplugin/`
- Add a file named `markdown.lua` in the directory

---
## Folding

> by default <Tab> is used for folding

---

## Spelling

```lua
vim.cmd "setlocal spell spelllang=en_us"
```

```
     +-----------------------------+     +-----------------------------+     +-----------------------------+
     | Enable spell checking       | --> | Disable spell checking      | --> | Navigate to next misspelled |
     | Command: :set spell         |     | Command: :set nospell       |     | word                        |
     +-----------------------------+     +-----------------------------+     | Command: ]s                 |
                                                                            +-----------------------------+
                                                                                      |
                                                                                      v
     +-----------------------------+     +-----------------------------+     +-----------------------------+
     | Navigate to previous        | --> | Add word to spell file      | --> | Mark word as incorrect      |
     | misspelled word             |     | Command: zg                 |     | Command: zw                 |
     | Command: [s                 |     +-----------------------------+     +-----------------------------+
     +-----------------------------+                                                  |
                                                                                      v
                                                                            +-----------------------------+
                                                                            | Suggest corrections         |
                                                                            | Command: z=                 |
                                                                            +-----------------------------+
```

---

## Auto-correct

```lua
vim.api.nvim_exec(
  [[
iabbrev teh the
iabbrev recieve receive
iabbrev >> →
iabbrev << ←
iabbrev ^^ ↑
iabbrev VV ↓
]],
  false
)
```

---

## Key Bindings Part1

```lua
vim.keymap.set("n", "<leader>pi", ":call mdip#MarkdownClipboardImage()<CR>", { desc = "Paste image from clipboard" })
vim.keymap.set("n", "]]", "<Plug>Markdown_MoveToNextHeader")
vim.keymap.set("n", "[[", "<Plug>Markdown_MoveToPreviousHeader")
```

---

## Key Bindings Part2

```lua
vim.keymap.set(
  "n",
  "<leader>ml",
  "^I-<Space>[<Space>]<Space><Esc>^j",
  { remap = true, silent = false, desc = "Prepend markdown list item on line" }
)
```

```lua
:Toc       -----> Table of Contents
:InsertToc -----> Insert Table of Contents
```

---

## Handling Images

- `3rd/image.nvim`: Seamless integration for handling images within Markdown

```lua
package.path = package.path .. ";" .. vim.fn.expand "$HOME" .. "/.luarocks/share/lua/5.1/?/init.lua"
package.path = package.path .. ";" .. vim.fn.expand "$HOME" .. "/.luarocks/share/lua/5.1/?.lua"
```

> Paste image with keybinding or link and preview in-file (requires terminal
> with image capabilities and previewers)

---

## Pandoc Integration

- `vim-pandoc/vim-pandoc`: Pandoc integration
- easy to do without plugins: `:!pandoc % -o %:r.pdf`

---

## Fenced Code Blocks

````lua
function MarkdownCodeBlock(outside)
  vim.cmd "call search('```', 'cb')"
  if outside then
    vim.cmd "normal! Vo"
  else
    vim.cmd "normal! j0Vo"
  end
  vim.cmd "call search('```')"
  if not outside then
    vim.cmd "normal! k"
  end
end
````

---

## Run & edit code in code blocks

> Using `mdeval.nvim` and `femaco.nvim`


---

## Vale Linter

- integrating `vale` linter for docs


---

## Bonus: No Distractions - No Neck Pain

- no-neck-pain plugin
- setting scrollfix to 25% of the screen height

---

```bash
../thats_all_folks
```
