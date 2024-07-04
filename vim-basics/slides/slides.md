---
theme: theme.json
author: Cloud-Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

```bash
~~~./intro.sh

~~~
```

---

# Vim: A Powerful, Modal Text Editor

- 🖥️ Efficient text editing
- 🔀 Multiple modes for different tasks
- ⌨️ Keyboard-centric workflow
- 🧠 Composable commands

---

## 1. Modes: The Core of Vim's Efficiency

- Normal (default): For navigating and commanding
- Insert (i): For typing text
- Visual (v): For selecting text
- Command (Ex) (:): For executing commands
- Replace (R): Overwrites existing text

Press `ESC` to return to Normal mode from any other mode

---

## 2. Vim's Built-in Help

Vim comes with extensive built-in documentation:

- `:help`: Open general help
- `:help {topic}`: Get help on a specific topic
- `Ctrl-]`: Follow help tag
- `Ctrl-t`: Go back in help tags

Tip: Use `:help index` for a command index

Always remember: `:help` is your friend in Vim!

---

## 3. Undo and Redo

Mistakes happen, but Vim has you covered:

- `u`: Undo last change
- `Ctrl-r`: Redo last undone change
- `.`: Repeat last change
- `U`: Undo all changes on the last modified line

Tip: Vim allows for multiple levels of undo, so don't be afraid to experiment!

---

## 4. Moving Around

Navigate efficiently with these motions:

- `h`: left, `j`: down, `k`: up, `l`: right
- `w`: next word, `b`: beginning of word, `e`: end of word
- `W`, `B`, `E`: same as `w`, `b`, `e`, but for WORDS (space-separated)
- `0`: start of line, `$`: end of line
- `^`: first non-blank character of line
- `gg`: first line of file, `G`: last line of file
- `{number}G`: go to specific line number

Practice: Move around this slide using various motions

---

## 5. Text Objects

Vim understands text structures for efficient editing:

- `w`: word
- `s`: sentence
- `p`: paragraph
- `t`: tag (HTML/XML)
- `"`, `'`, `` ` ``, `(`, `[`, `{`: quoted/bracketed text
- `i` vs `a`: "inner" vs "around" (includes delimiters)

Examples:
- `diw`: delete inner word
- `ci"`: change inside quotes
- `ya)`: yank around parentheses

---

## 6. Operators

Combine operators with motions or text objects:

- `d`: delete (also cut)
- `c`: change (delete and enter Insert mode)
- `y`: yank (copy)
- `>`: indent
- `<`: unindent
- `=`: auto-indent
- `gq`: format text

Use with count for more power: `d2w` (delete two words)

> Tip: Operators + Text Objects = Vim superpowers!

---

## 7. Inserting Text

Vim offers various ways to enter Insert mode:

- `i`: Insert before cursor
- `a`: Insert after cursor
- `I`: Insert at start of line
- `A`: Insert at end of line
- `o`: Open line below
- `O`: Open line above

Remember: Press `ESC` to return to Normal mode

---

## 8. Deleting and Changing Text

Efficiently remove or modify text:

- `x`: Delete character under cursor
- `X`: Delete character before cursor
- `dw`: Delete word
- `dd`: Delete entire line
- `D`: Delete from cursor to end of line
- `cc`: Change entire line
- `C`: Change from cursor to end of line

---

## 9. Copying and Pasting

In Vim, copying is "yanking" and pasting is "putting":

- `yy` or `Y`: Yank entire line
- `yw`: Yank word
- `y$`: Yank to end of line
- `p`: Put after cursor
- `P`: Put before cursor

---

## 10. Working with Registers

Vim uses registers to store text:

- `"{register}y`: Yank into specified register
- `"{register}p`: Put from specified register
- `:reg`: View contents of all registers
- `"+y`: Yank to system clipboard
- `"+p`: Paste from system clipboard

> Tip: Use named registers (a-z) for longer-term storage

---

## 11. Visual Mode

Visual mode allows for easy text selection:

- `v`: Character-wise visual mode
- `V`: Line-wise visual mode
- `Ctrl-v`: Block-wise visual mode

After selecting, use operators like `d`, `y`, or `c`

> Tip: Use `Ctrl-v` to select a block, then `I` to insert at the beginning

---

## 12. Searching and Replacing

Find and modify text with ease:

- `/pattern`: Search forward
- `?pattern`: Search backward
- `n`: Next match, `N`: Previous match
- `*`: Search for word under cursor
- `:s/old/new/`: Replace on current line
- `:%s/old/new/g`: Replace in entire file
- `:%s/old/new/gc`: Replace with confirmation
- `:.,.+5s/old/new/g`: Replace in range (current line to 5 lines below)

> Tip: Use `:%s//new/g` to replace last search with "new"

---

## 13. Working with Multiple Files

Manage multiple files efficiently:

- `:e filename`: Edit a file
- `:bn`, `:bp`: Next/previous buffer
- `:ls`: List all buffers
- `Ctrl-w s` or `:sp`: Split window horizontally
- `Ctrl-w v` or `:vsp`: Split window vertically
- `:tabnew`: Open a new tab
- `gt`, `gT`: Navigate between tabs

> Tip: Use `:e` to open a new file, then `Ctrl-w v` to split vertically

---

## 14. Macros

Automate repetitive tasks with macros:

1. `q{register}`: Start recording to a register (a-z)
2. (perform your actions)
3. `q`: Stop recording
4. `@{register}`: Play the macro
5. `@@`: Repeat the last played macro

Example: Record a macro to increment numbers and add a period:
1. `qa` (start recording to register a)
2. `Ctrl-a` (increment number)
3. `A.` (append a period)
4. `q` (stop recording)
5. `@a` to play, `10@a` to repeat 10 times

---

## 15. Advanced Motions

Move with precision:

- `%`: Jump to matching parenthesis/bracket
- `f{char}`: Find character forward in line
- `t{char}`: Till character forward in line
- `F{char}`, `T{char}`: Backward versions
- `;`: Repeat last f, t, F, or T motion
- `,`: Repeat last f, t, F, or T motion, backwards

> Tip: Use `f(` to jump to a parenthesis, then `%` to jump to its match

---

## 16. Marks and Jumps

Navigate within and between files:

- `m{a-zA-Z}`: Set a mark
- `` ` {a-z}``: Jump to mark in current buffer
- `` ` {A-Z}``: Jump to mark in any buffer
- `Ctrl-o`: Jump to older position
- `Ctrl-i`: Jump to newer position

> Tip: Use `` ` ` `` to jump back to the last jump position

---

## 17. The Power of `g`

The `g` key unlocks many powerful commands:

- `gd`: Go to definition
- `gf`: Go to file under cursor
- `gg`: Go to first line
- `G`: Go to last line
- `gv`: Reselect last visual selection
- `gq{motion}`: Format text
- `gU{motion}`: Convert to uppercase
- `gu{motion}`: Convert to lowercase

> Tip: Use `gqip` to format the current paragraph

---

## Thank you for staying till the end!

```bash
~~~./demo.sh

~~~
```
