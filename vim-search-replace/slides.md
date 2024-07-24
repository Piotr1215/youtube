---
theme: theme.json
author: Cloud-Native Corner 
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Neovim: The Power of Search&Replace

```bash
~~~./intro.sh

~~~
```

---

## Introduction

- 🚀 Edit text faster and more efficiently
- 🛠️ Regular expressions support
- 🌐 Search and replace across multiple files
- 🔄 Repeat search and replace
- 📦 Search and replace in visual selection

---

## 🦴 Anatomy of a substitution command

```bash
:[range]s[ubstitute]/{pattern}/{string}/[flags] [count]
|-----|  |---------| |-------| |------| |-----| |----|
  |           |          |        |        |      |
  |           |          |        |        |      +-----> 6. Optional count
  |           |          |        |        +------------> 5. Flags (e.g., g, i, c)
  |           |          |        +---------------------> 4. Replacement string or regex 
  |           |          +------------------------------> 3. Search pattern (string or regex, inc atoms)
  |           +-----------------------------------------> 2. Substitution command (s)
  +-----------------------------------------------------> 2. Selection ('<,'>), line (.), file (%)
```

> Useful setting for substitution preview: `vim.opt.inccommand = "split"`

---

## Line Replacement

Replace string in a line 

```lua
:.s/old/new
```
> we can omit . as it is the default range

```lua
:s/old/new                    -----> Search&Replace first occurrence of the search string in the line 
```

```lua
:s/old/new/g                  -----> Search&Replace all occurrences of string in the line 
```

```lua
:s/\Cold/new/g                -----> Case sensitive search&replace (default is case insensitive)
```

```lua
:s/\Cold/new/gc               -----> Confirm each replacement
```

---

## Capture Groups and Regex

> Learn Regex here: [Regex101](https://regex101.com/)

### Character Classes

```bash
'[bp]le'                 -----> Matches 'ble' or 'ple'
```

### Anchors

```bash
'^apple'                 -----> Matches lines starting with 'apple'
'pie\$'                  -----> Matches lines ending with 'pie'
```

### Quantifiers & Atoms

> Atoms can be counted with {n}

```bash
'.'                      -----> Matches any single character 
'.*'                     -----> Matches zero or more of any character
'.+'                     -----> Matches one or more of any character 
'()'                     -----> Capture group
'\w'                     -----> Matches any word character
'\d'                     -----> Matches any digit
'\s'                     -----> Matches any whitespace
'\v'                     -----> Very magic mode
'\r'                     -----> Matches a newline
```
---

## Using Capture Groups and Regex

```lua
:s/\old/&-append-something    -----> Append something to the search string
```

```lua
:s/"\(.*\)"/\1                -----> Remove surrounding "" from a string 
```

```lua
:s/\v(\d+)-(\d+)/\2-\1        -----> Swap position of two number grouns around -
```

> Advanced use case
> `\zs` use patterns to find a position but only include what comes after match
> `\ze` use patterns to find a position but only include what comes before match

```lua
:s/\vstart\zs.*\zeend/replace -----> Replace text between start and end
```
---

## Match Inside Visual Selection

> Use `/\%V` atom to match inside visual selection

```lua
'<,'>s/\%Vsearch/replace/
```

## Execute External Command on Matching Lines

> :g stands for global, it executes a command on all lines that match the search
> pattern

```lua
:g/^$/d                    -----> Delete empty lines
```

```lua
:g/search_string/norm gU$  -----> Convert matching lines to uppercase
```

```lua
:v/old/new/g               -----> Negate the search pattern
```

---

## When substitution is not enough

> Quick intro to macros, this will be a full 🎥 soon

Use macros when substitution is too complex, especially when substituting on *multiple lines*

   ```lua
   q<register>              -----> Start recording macro into a register (e.g., qa)
   ```
   ```lua
   keystrokes               -----> Perform the sequence of commands you want to record.
   ```
   ```lua
   q                        -----> Stop recording macro
   ```
   ```lua
   @<register>             -----> Execute macro stored in register (e.g., @a)
   ```

---

## Args Cdo and Advanced Use Cases

### Substitution in Multiple Files

```lua
:args example1.md example2.md example3.md   -----> Set arguments to the example markdown files
```

```lua
:argdo %s/apple/orange/gc | update          -----> Perform substitution in each file and save changes
```

### Run External Command in Multiple Files

```lua
:vimgrep /apple/ **/*.md                    -----> Search 'apple' pattern in all markdown files recursively
```

```lua
:cfdo <command>                             -----> Run command in each file in the quickfix list
```

```lua
:cfdo g/apple/d | update                    -----> Delete lines matching 'apple' pattern and save changes
```

---

## Useful Key Bindings & Settings

```lua
",<space>", ":nohlsearch<CR>"              -----> Stop search highlight
"<leader>pa", "ggVGp"                      -----> select all & paste
"<leader>sa", "ggVG"                       -----> select all
"<leader>r", ":%s/\\v/g<left><left>"       -----> replace in file command mode, no need to type
"<leader>ss", ":s/"                        -----> search and replace in line
"<leader>SS", ":%s/"                       -----> search and replace
"<leader><C-s>", ":s/\\%V"                 -----> Search only in visual selection usingb%V atom
"<C-r>", '"hy:%s/\\v<C-r>h//g<left><left>' -----> change selection
"<leader>x", "*``cgn"                      -----> replace word under cursor forward
"<leader>X", "#``cgn"                      -----> replace word under cursor simultaneously
```
---

## Bonus: Create Your Own Cheatsheet

> Use `cheat` to create your own cheatsheet from this table

### Install `cheat`

```bash
brew install cheat           -----> Install cheat on Mac
sudo apt-get install cheat   -----> Install cheat on Linux
```
 
```bash
cheat -e nvim_sr             -----> Create Custom Cheatsheet:
```

> make sure that you have `EDITOR` environment variable set to nvim

Use external command to add the Table to Your Cheatsheet

```bash
:r !curl -s https://gist.githubusercontent.com/Piotr1215/19b1a1a3735e5757a1c947edc7777630/raw/7fb64434bd5601cdbca790f943ecbc2acd254257/nvim-replace.md
```

```bash
cheat -c nvim_sr             -----> Use Custom Cheatsheet
```


