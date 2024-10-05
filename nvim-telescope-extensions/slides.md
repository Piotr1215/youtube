---
theme: ./theme.json
author: Cloud-Native Corner
date: September 21, 2024
paging: Slide %d / %d
---

# Telescope Extensions

```bash
~~~./intro.sh

~~~
```

---

## Telescope

- Created by TJ DeVries (YouTube: teej_dv) <----- Check out his channel
- Lots of built-in stuff
- Extensions enhance Telescope's functionality
- Integrates well with external tools
- Can override default behaviors (e.g., sorters)

```ascii
 Telescope Core
   __________
  /\____;;___\
 | /         /
 `. ())oo() .
  |\(%()*^^()^\
 %| |-%-------|
% \ | %  ))   |
%  \|%________|
```

---

## Telescope Extension Architecture

Telescope's power lies in its modular design:

- Pickers <----- Define what to search (files, git commits, buffers)
- Sorters <----- Determine how results are ranked (fzf algorithm, frecency)
- Previewers <----- Display selected item details (file content, git diff)
- Actions <----- Define what happens on selection (open file, checkout branch)

```ascii
    Telescope
   ┌─────────────────────────┐
   │  ┌───────┐   ┌────────┐ │
   │  │Picker │ → │ Sorter │ │
   │  └───────┘   └────────┘ │
   │        ↓                │
   │  ┌──────────┐ ┌───────┐ │
   │  │Previewer │ │Action │ │
   │  └──────────┘ └───────┘ │
   └─────────────────────────┘
```

---

## Loading Extensions

```lua
-- Load fzy_native extension
require('telescope').load_extension('fzf_native')

-- Access extension picker
:Telescope dap configurations

-- Or from Lua
require('telescope').extensions.dap.configurations()
```

---

## File Browser Extension

- Navigate file system within Neovim
- Create, delete, and rename files/directories

```lua
vim.keymap.set("n", "<leader>fi", ":Telescope file_browser hidden=true<CR>")
```

---

## File Browser Demo

```bash
tmux switchc -t file-browser-demo
```

---

## Telescope GitHub Extension

- Integrates GitHub CLI with Telescope
- Browse issues, pull requests, gists, and more
- Perform GitHub actions directly from Neovim

Prerequisites: GitHub CLI (gh)

Setup:

```lua
require('telescope').load_extension('gh')
```

Usage:

```vim
:Telescope gh issues
:Telescope gh pull_request
:Telescope gh gist
:Telescope gh run
```

---

## Telescope GitHub Demo

```bash
tmux switchc -t github-demo
```

---

## Zoxide Integration

- Quick navigation to frequently used directories
- Combines the power of `z` with Telescope's UI

Prerequisites: zoxide

```lua
vim.keymap.set("n", "<leader>fz", [[<cmd>lua require('telescope').extensions.zoxide.list()<CR>]])
```

---

## Zoxide Demo

```bash
tmux switchc -t zoxide-demo
```

---

## Live Grep Args Extension

- Enhanced live grep with argument support
- Auto-quoting for complex search patterns

Prerequisites: ripgrep

```lua
extensions = {
  live_grep_args = {
    auto_quoting = true,
  },
},
```

---

## Live Grep Args Demo

```bash
tmux switchc -t live-grep-demo
```

---

## Building Your Own Extension: Crossplane

Let's create a Telescope extension for Kubernetes Crossplane resources

## Step 1: Setup Extension Structure

```
lua/
├── telescope/
│   └── _extensions/
│       └── crossplane.lua
└── telescope-crossplane/
    └── init.lua
```

---

## Step 2: Define Core Functionality

```lua
-- lua/telescope-crossplane/init.lua
local M = {}

function M.show_managed_resources()
  -- Implementation here
end

function M.show_crossplane_resources()
  -- Implementation here
end

return M
```

---

## Step 3: Implement Picker Logic

```lua
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values

function M.show_managed_resources()
  local results = vim.fn.systemlist('kubectl get managed -o name')
  pickers.new({}, {
    prompt_title = 'Managed Resources',
    finder = finders.new_table {
      results = results,
    },
    sorter = conf.generic_sorter({}),
  }):find()
end
```

---

## Step 4: Add Custom Actions

```lua
local action_state = require('telescope.actions.state')

-- Inside picker definition:
attach_mappings = function(prompt_bufnr, map)
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    vim.cmd('edit ' .. selection[1])
  end)
  return true
end,
```

---

## Step 5: Register Extension

```lua
-- lua/telescope/_extensions/crossplane.lua
return require('telescope').register_extension {
  exports = {
    crossplane_managed = require('telescope-crossplane').show_managed_resources,
    crossplane_resources = require('telescope-crossplane').show_crossplane_resources,
  },
}
```

---

## Crossplane Extension Demo

```bash
tmux switchc -t crossplane-demo
```

---


## Bonus: Telescope Emoji 😎

- Find and insert emojis easily
- Great for documentation and comments

Setup:

```lua
require('telescope').load_extension('emoji')
```

Key mappings:

- `<CR>`: Insert emoji at cursor
- `<C-y>`: Yank emoji to clipboard

```lua
vim.keymap.set("n", "<leader>fe", "<cmd>Telescope emoji<cr>")
```

---

## Emoji Demo

```bash
tmux switchc -t emoji-demo
```

---

```ascii
   🚀
  /|\
 / | \
/  |  \
   |
   |
  / \
 /   \
```

```bash
../thats_all_folks
```
