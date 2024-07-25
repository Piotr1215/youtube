---
theme: theme.json
author: Cloud-Native Corner 
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Neovim Macros: Advanced Text Manipulation Techniques

```bash
~~~./intro.sh

~~~
```

---

## Introduction

- 🎬 Record complex sequences of commands
- 🔁 Repeat actions across multiple lines or files
- 🛠️ Customize and combine with other Neovim features
- 📊 Perfect for data manipulation and code refactoring

> It's kind of like Excel, but for text editing

---

## 🦴 Anatomy of a Macro

```bash
q{register}{commands}q
| |        |         |
| |        |         +-------> 4. Stop recording
| |        +-----------------> 3. Series of commands to record
| +--------------------------> 2. Register to store the macro (a-z)
+----------------------------> 1. Start recording
```

> Upper case registers append to the existing macro

---

### Macros vs. Dot Command:

. repeats the last change (single action)
Macros can repeat complex, multi-step operations

> Tip: Use . for quick, single-change repetitions, and macros for more complex sequences

---

## When to use macros

- Use `substitutions` in Vim for simple pattern recognition and replacements.
- For complex tasks, use `macros` to record keystrokes, similar to Excel actions.
- Transition to custom `lua/vimscript functions` for more control when macros become repetitive

```bash
                        +-----------------------+                              
+----------------------|-+                      |     +---------------------+
|   Substitutions      | |      Macros          |     |    Lua Functions    |
|    (Simple Pattern   | | (Multi-Step Editing) |     | (Advanced Scripting)|
|    Recognition &     | |                      |---> |                     |
|    Replacements)     | |                      |     |                     |
+----------------------|-|                      |     +---------------------+
                        +-----------------------+                             
```

---

## Understanding Registers

- Registers are storage locations for text and macros
- Types of registers:
  - Unnamed (") : Last yank or delete
  - Numbered (0-9) : Historical yanks and deletes
  - Named (a-z) : User-defined storage
  - Read-only (:, ., %) : Special information

  ```                       
  :reg                      -----> View register contents  
  ```                       
                            
  ```                       
  "<register>p              -----> Paste from a register  
  ```                       

---

## Telescope Integration for Registers

- Telescope.nvim plugin offers a great interface for registers

- Install Telescope and add to your config:
  ```lua
  use {'nvim-telescope/telescope.nvim'}
  ```

- Use Telescope to view and select registers:
  ```lua
  :Telescope registers
  ```

- Create a keybinding for quick access:
  ```lua
  vim.api.nvim_set_keymap('n', '<leader>fr', ':Telescope registers<CR>',
                          { noremap = true, silent = true })
  ```

> This allows for easy viewing, searching, and pasting from registers

---
## Recording a Basic Macro

   ```                      
   q{register}              -----> Start recording  
   ```                      
   ```                         
   edits                    -----> Perform your commands
   ```                         
   ```                      
   q                        -----> Stop recording  
   ```                      
                            
   ```                      
   @{register}              -----> Play back the macro  
   ```                      

> Example: `qa` to start recording into register 'a', then `q` to stop, and `@a` to play

---

## Macro Playback and Repetition

  ```
  @{register}                     -----> Play macro once  
  ```                             
                                  
  ```                             
  @@                              -----> Repeat last played macro  
  ```                             
                                  
  ```                             
  {count}@{register}              -----> Play macro multiple times  
  ```

> Example: `5@a` plays macro 'a' five times

---

## Editing Macros

   ```
   "{register}p              -----> Paste macro content  
   ```

   ``` 
   edits                     -----> Edit the macro
   ```

   ```
   "{register}y$             -----> Yank edited macro back  
   ```

> Tip: Use a scratch buffer for editing complex macros

---


## Saving Macros

- Macros are stored in registers, which are volatile
- To save macros permanently:


Create reusable mapping:
   ```lua
   vim.api.nvim_set_keymap('n', '<leader>sq', [[:let @q='<C-r><C-r>q'<Left>]],
                           { noremap = true, silent = false })
   ```

> This allows you to edit and save the macro in register 'q'


> Macroni: Simplify Macro Saving and Reuse

```lua
use 'jasonrudolph/macroni'
```
---

## Macros Across Files

1. Record your macro

   ```
   :argdo normal @a              -----> 2. Use `:argdo` or `:bufdo`  
   ```

> Applies macro 'a' to all files in the argument list

---

## Useful Key Bindings for Macros

```lua
"Q", "@q"                                         -----> Quick access to macro 'q'
"<leader>m", ":let @q=''<CR>"                     -----> Clear macro register 'q'
"<leader>M", ":'<,'>normal @q"                    -----> Apply macro 'q' to visual selection
"<leader>Q", ":'<,'>:normal @q<CR>"               -----> Run macro from q register on visual selection
"<ESC>", "<C-\\><C-n>"                            -----> Exit terminal mode (in terminal mode)
"<leader>ml", "^I-<Space>[<Space>]<Space><Esc>^j" -----> Prepend markdown list item on line
```
