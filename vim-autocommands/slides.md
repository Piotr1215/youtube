---
theme: theme.json
author: Cloud-Native Corner 
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Neovim: Unlock the Power of AutoCommands

```bash
~~~./intro.sh

~~~
```

---

## Introduction

- 🚀 Automate repetitive tasks
- 🛠️ Improve efficiency and productivity
- 🌐 Integrate seamlessly with other tools
- 🔄 Trigger actions on specific events (file read/write, buffer enter/leave, etc.)

> Auto commands in Neovim execute specified commands automatically when certain
events occur, such as opening, reading, or writing a file. This automation can
significantly streamline your development process and improve productivity.

---

## 🦴 Anatomy of an AutoCommand

Neovim syntax

```bash
vim.api.nvim_create_augroup("Group Name", { clear = true })
|-----| |-----------------| |----------|  |--------------|
  |              |               |               | 
  |              |               |               +----------> 4. Devault: Clear existing commands in group
  |              |               +--------------------------> 3. Group name, multiple commands can belong to the same group
  |              +------------------------------------------> 2. Function that creates the autogroup 
  +---------------------------------------------------------> 1. Invokes Nvim |API| function {func} with arguments {...}

vim.api.nvim_create_autocmd({events},{opts})
|-----| |------------------| |-----|  |----| 
  |                |          |        |       
  |                |          |        |      
  |                |          |        |     
  |                |          |        +--------------------> 4. Options table
  |                |          +-----------------------------> 3. Array of events to trigger the autocmd
  |                +----------------------------------------> 2. Function that creates the autocmd event hander
  +---------------------------------------------------------> 1. Invokes Nvim |API| function {func} with arguments {...}
```

Alternative syntax using `vimscript`:

```vim
augroup mine | exe "au! BufRead *" | augroup END
augroup mine | exe "au BufRead * set tw=70" | augroup END
```

---

## Autocommand Flow

```bash
       ┌─┐                                                                                                       
       ║"│                                                                                                       
       └┬┘                                                                                                       
       ┌┼┐                                                                                                       
        │                   ┌─────┐           ┌───────────┐               ┌──────┐                               
       ┌┴┐                  │Event│           │Autocommand│               │Action│                               
      User                  └──┬──┘           └─────┬─────┘               └───┬──┘                               
        │Trigger event {event} │                    │                         │                                  
        │─────────────────────>│                    │                         │                                  
        │                      │                    │                         │                                  
        │                      │ ╔══════════════════╗                         │                                  
        │                      │ ║Examples:        ░║                         │                                  
        │                      │ ║- 'BufReadPre'    ║                         │                                  
        │                      │ ║- 'BufWritePost'  ║                         │                                  
        │                      │ ╚══════════════════╝                         │                                  
        │                      │Trigger autocommand │                         │                                  
        │                      │───────────────────>│                         │                                  
        │                      │                    │                         │                                  
        │                      │                    │Execute based on options │                                  
        │                      │                    │────────────────────────>│                                  
        │                      │                    │                         │                                  
        │                      │                    │                         │ ╔═══════════════════════════════╗
        │                      │                    │                         │ ║Options examples:             ░║
        │                      │                    │                         │ ║- group: 'MyGroup'             ║
        │                      │                    │                         │ ║- pattern: '*.txt'             ║
        │                      │                    │                         │ ║- callback: 'MyCallback'       ║
        │                      │                    │                         │ ║- OR command: ':echo "Hello"'  ║
                                                                                ╚═══════════════════════════════╝
```

---

## Example1: Highlight Yanked Text

```lua
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank { higroup = "IncSearch", timeout = 250 }
  end,
})
```

---

## Example2: Run Go Tests on Save

```lua
local goSettings = vim.api.nvim_create_augroup("Go Settings", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*test*.go" },
  command = ":silent! GoTestFile",
  group = goSettings,
})
```

---

## Example3: Dynamically Run `vale` depending on location

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    dynamicValeSetup()
  end,
})

function dynamicValeSetup()
  local file_path = vim.fn.expand("%:p:h")
  local vale_config_path = "$HOME/dev/vale/.vale.ini"

  if string.match(file_path, "crossplane%-docs/content") then
    vale_config_path = "$HOME/dev/crossplane-docs/utils/vale/.vale.ini"
  end

  local current_dir_vale_path = file_path .. "/.vale.ini"
  if vim.fn.filereadable(current_dir_vale_path) == 1 then
    vale_config_path = current_dir_vale_path
  end

  require("vale").setup {
    bin = "/usr/local/bin/vale",
    vale_config_path = vale_config_path,
  }
end
```
---

### Commands to Display AutoCommands

| Command                        | Description                                                                 |
|-------------------------------|-----------------------------------------------------------------------------|
| `:autocmd`                    | Lists all currently defined auto commands in Neovim.                        |
| `:autocmd {event}`            | Shows auto commands for a specific event (e.g., `BufWritePost`).            |
| `:verbose :autocmd {event}`   | Provides detailed information about auto commands for a specific event, including the file location where each auto command is defined. |
| `:augroup {group} | autocmd | augroup END` | Displays all auto commands within a specific group.                       |
| `:autocmd * {pattern}`        | Lists all auto commands that match a specific pattern (e.g., `*.lua`).      |
| `Telescope autocommands`        | Lists all auto commands and fuzzy find.      |

