---
theme: theme.json
author: Cloud-Native Corner 
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Zsh Tips and Tricks

```bash
~~~./intro.sh

~~~
```
---

## Presentation Overview:

-   🖱️ Cursor Navigation and Line Editing
-   🌐 Globbing
-   🔄 Command Manipulation and Execution
-   📜 History Utilization and Expansion
-   🧩 Parameter and Variable Handling
-   🛠️ Path and Filename Operations
-   🧮 Brace and Range Expansions
-   📂 Directory Navigation Techniques
-   ⌨️ Custom Commands and Key Bindings

---
## 🖱️ Cursor Navigation and Line Editing

Zsh provides powerful shortcuts for efficient cursor movement and text manipulation:

### Cursor Movement:
- `Ctrl + A` - Move cursor to beginning of line
- `Ctrl + E` - Move cursor to end of line

### Text Deletion:
- `Ctrl + U` - Delete from cursor to start of line
- `Ctrl + K` - Cut from cursor to end of line
- `Ctrl + W` - Cut from cursor to start of preceding word
- `Alt + D` - Remove from cursor to end of next word

### Text Manipulation:
- `Ctrl + Y` - Paste (yank) previously cut text
- `Ctrl + Shift + _` - Undo last keystroke in command
- `Ctrl + XT` - Swap the current word with previous word

### Command Editing:
- `Ctrl + XE` - Edit current command in default editor
- `Ctrl + L` - Clear terminal screen
- `Ctrl + q` - Move current command to buffer, clear line for new command

---
## 🌐 Globbing

Zsh provides powerful globbing features for flexible file matching:

### Standard Globbing:
- `*.txt` - Match all `.txt` files in the current directory

### Recursive Globbing:
- `**/*.txt` - Match all `.txt` files recursively within directories

### Extended Globbing:
- Enable extended globbing for more advanced pattern matching:
  ```zsh
  setopt EXTENDED_GLOB
  ```
  Examples:
  - `ls *(.)` - List only regular files
  - `ls *(/)` - List only directories

---

## 📜 Command History and Expansion

Zsh offers powerful features for recalling and manipulating previous commands:

### History Recall:
- `Alt + .` or `<Esc> + .` - Insert last argument of previous command (same as `!$`)
- `<Esc> + _` - Insert last word of previous command, cycles through arguments
- `!:0` - Repeat the previous command without arguments
- `!vi` - Run the most recent command that started with 'vi'

### History Modification:
- `!!:s/x/y` - Substitute 'x' with 'y' in the previous command
- `^foo^bar` - Replace 'foo' with 'bar' in the previous command and execute

### Current Command Expansion:
- `!#^` - Expand first argument of the current command
- `!#$` - Expand last argument of the current command

### Quick Fixes:
- `fc` - Fix command: opens last command in editor
- `r` - Repeat last command (can be combined with substitution, e.g., r foo=bar)

---
## 🧩 Parameter Expansion and Shell Variables

Zsh provides powerful features for working with parameters and shell variables:

### Positional Parameters:
- `$#` - Number of positional parameters passed to the script or function
- `$@` - All positional parameters, individually quoted
- `$*` - All positional parameters as a single, space-separated string

### Special Variables:
- `$?` - Exit status of the last executed command
- `$_` - Last argument of the previous command

---

## 🛠️ Path and Filename Operations

Zsh provides various shortcuts for working with file paths and filenames:

### Path Expansion:
- `/u/lo/b<Tab>` - Quick path expansion (e.g., expands to /usr/local/bin)

### Filename Manipulation:
- `$file:r` - Remove extension from a filename variable
- `$file:e` - Get just the extension from a filename variable
- `$file:u` - Convert a filename variable to uppercase

These operations simplify working with file paths and filenames, making it easier to handle files in your scripts and commands.

---

## 🧮 Brace and Range Expansions

Zsh offers powerful features for generating sequences and sets of items:

### Brace Expansion:
- `mkdir -p {apple,banana,cherry}` - Expand to multiple terms

### Range Expansion:
- `{1..5}` - Expand to a numeric range (outputs: 1 2 3 4 5)

---

## 📂 Directory Navigation Techniques

Efficient directory navigation is crucial for command-line productivity:

### Directory Shortcuts:

- `cd -` - Go to previous directory
- `cd -<TAB>` - Show directories selection list

These shortcuts streamline directory navigation, making it easier to move between frequently used directories.

---

## 🔧 Custom Commands and Key Bindings

Zsh allows for the creation of custom commands and key bindings to further enhance your workflow:

### Understanding `BUFFER` and `zle`:
- `BUFFER` - Represents the current command line content.
- `zle` - Zsh Line Editor, used to manipulate the command line.

### Custom Command Example:
To create a custom command to copy the entire command line to the clipboard:
```zsh
copy-line-to-clipboard() {
  echo -n $BUFFER | xclip -selection clipboard
}
zle -N copy-line-to-clipboard
```
This function uses `xclip` to copy the content of `BUFFER` (the current command line) to the clipboard.

---

### Adding Custom Key Bindings:
Bind custom functions or existing ZLE commands to specific key sequences:
```zsh
bindkey '^Y' copy-line-to-clipboard          # Bind Ctrl+Y to copy-line-to-clipboard
bindkey '^@' autosuggest-accept              # Bind Ctrl+Space to accept autosuggestion
bindkey '^X^T' transpose-words               # Bind Ctrl+X followed by Ctrl+T to transpose words
```
- `bindkey '^Y' copy-line-to-clipboard`: Binds the `Ctrl+Y` shortcut to the `copy-line-to-clipboard` function.
- `bindkey '^@' autosuggest-accept`: Binds the `Ctrl+Space` shortcut to accept autosuggestions.
- `bindkey '^X^T' transpose-words`: Binds the `Ctrl+X` followed by `Ctrl+T` shortcut to transpose words.

---

## 📝 Summary

In this session, we covered essential Zsh features and shortcuts to improve your command-line efficiency:

- Cursor Navigation and Line Editing
- Globbing
- Command Manipulation and Execution
- History Utilization and Expansion
- Parameter and Variable Handling
- Path and Filename Operations
- Brace and Range Expansions
- Directory Navigation Techniques
- Custom Commands and Key Bindings

By mastering these techniques, you'll significantly enhance your terminal productivity, enabling more efficient development, system administration, and daily command-line tasks.
