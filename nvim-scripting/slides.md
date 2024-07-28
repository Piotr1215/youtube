---
theme: theme.json
author: Cloud-Native Corner 
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Writing Custom Lua Functions in Neovim

```bash
~~~./intro.sh

~~~
```

---

## Introduction

- 🧑 Enhance Neovim with `lua` functions
- 🚀 Customize your text editing experience
- 🛠️ Integrate with Neovim features and plugins
- 📊 Write your own cool modules

> Discover the power of `lua` in Neovim

---

## When to use Functions

- Use `macros` for recording simple multi-step tasks
- Transition to `lua functions` for more complex or repetitive tasks
- Benefit from better integration and flexibility with `lua`

```bash
                        +-----------------------+                              
+----------------------|-+                      |     +---------------------+
|       Macros         | |    Lua Functions     |     |   Plugins/Advanced  |
|   (Simple Tasks)     | | (Complex Operations) |---> |   Customization     |
+----------------------|-|                      |     +---------------------+
                        +-----------------------+                             
```

---
## Lua API in Neovim

```lua
vim.cmd()     -----> Vim API: Ex-commands, Vimscript functions
vim.fn        -----> Access Vim functions
vim.api       -----> Nvim API: Remote plugins, GUIs
vim.*         -----> Lua API: Lua-specific functions
```

> :h lua

---

## Using Lua in Neovim

> use `:lua` to run Lua code in Neovim

```lua
:lua print("Hello!")        -----> Run `lua` code
```

```lua
:lua =_G                    -----> Print global scope
```

```lua
:dofile('myluafile.lua')    -----> Load `lua` file to _G scope 
```

```lua
:luafile myluafile.lua      -----> Run `lua` file
```

---

## Loading Lua Modules in Neovim

```lua                                          
require("myluamodule")                          -----> Load myluamodule.lua
require('folder_name.anothermodule')            -----> Dot . Separates folders/files
mymod = require('other_module')                 -----> Load module into variable
```                                             
                                                
```lua                                          
package.loaded['myluamodule'] = nil             
require('myluamodule')                          -----> Reload myluamodule.lua
```                                             

> module name is the file name without the `.lua` extension
                                                
---
                                        
## Creating and Loading `user_functions`

```lua
mkdir -p ~/.config/nvim/lua/user_functions
```

> Add the following code to `init.lua`

```lua
for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath "config" .. "/lua/user_functions", [[v:val =~ '\.lua$']])) do
  require("user_functions." .. file:gsub("%.lua$", ""))
end
```

---

## Bundle functions in `lua modules`

```bash
annotate_text.lua
grep_project.lua
header_text_object.lua
horizontal_scroll.lua
navigate_folds.lua
obsidian_notes.lua
projects.lua
registers.lua
shell_integration.lua
tasks.lua
todos.lua
utils.lua
zoom_window.lua
```

---

## Lua Modules and File Structure

- Organize `lua` code using modules
- Use `require` to load `lua` files
- Everything is a table

```lua
require('utils')

local M = {}
function M.my_function() 
    print("Hello from my_module") 
end
return M
```

> Keep your `lua` code modular and maintainable

---

## Writing a Basic Lua Function

```lua
local function greet(name)
  print("Hello, " .. name)
end

greet("Neovim User")
```

> Example: A simple function to greet a user

---

## Development Tools for Lua

- `folke/neodev.nvim`       -----> for autocompletion
- `:h nvim-lua-guide`       -----> for comprehensive Lua documentation
- `"ii14/neorepl.nvim"`     -----> Optional: interactive Lua REPL in Neovim

> Utilize development tools to enhance your `lua` coding experience
> Useful for testing `lua` code and working on function modules

---

## Developing window zoom module: Zoomer

> Goal: Create a simple module to toggle window zooming


