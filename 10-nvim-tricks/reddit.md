10 Built-in Neovim Features You're Probably Not Using

I keep seeing people install plugins for things Neovim already does. Wanted to share 10 built-in features that work in vanilla config - no plugins, no setup.

https://youtu.be/7D1k1l-Q8rA

---

## #1 Shell Filter: `!` and `!!`

Pipe text through external commands. Use any Unix tool as a text processor.

| Command | What it does |
|---------|--------------|
| `:.!date` | Replace line with date output |
| `!ip sort` | Sort paragraph |
| `!ap jq .` | Format JSON in paragraph |
| `:%!column -t` | Align entire file |

## #2 Visual Block Increment: `g Ctrl-a`

Create incrementing sequences in visual block. Select column of zeros, press `g Ctrl-a` - instant numbered list.

## #3 Global Command: `:g/pattern/cmd`

Run Ex command on all matching lines. Surgical bulk operations.

| Command | Effect |
|---------|--------|
| `:g/TODO/d` | Delete all TODOs |
| `:g/^$/d` | Delete empty lines |
| `:g/error/t$` | Copy error lines to end |
| `:g/func/norm A;` | Append `;` to all functions |

## #4 Command-line Registers: `Ctrl-r`

Insert register contents in `:` or `/` prompt. No more typing long paths.

| Shortcut | Inserts |
|----------|---------|
| `Ctrl-r Ctrl-w` | Word under cursor |
| `Ctrl-r "` | Last yank |
| `Ctrl-r /` | Last search pattern |
| `Ctrl-r =` | Expression result |

## #5 Normal on Selection: `:'<,'>norm`

Run normal mode commands on each selected line. Multi-cursor without plugins.

- `:'<,'>norm A,` → Append comma to each line
- `:'<,'>norm I#` → Comment each line
- `:'<,'>norm @q` → Run macro on each line

## #6 The `g` Commands

| Command | Effect |
|---------|--------|
| `gi` | Go to last insert position + insert mode |
| `g;` | Jump to previous change |
| `g,` | Jump to next change |
| `gv` | Reselect last visual selection |

## #7 Auto-Marks

Positions Vim tracks automatically.

| Mark | Jumps to |
|------|----------|
| ``` `` ``` | Previous position (toggle back) |
| `` `. `` | Last change position |
| `` `" `` | Position when file was last closed |
| `` `[ `` / `` `] `` | Start/end of last yank or change |

## #8 Command History Window: `q:`

Editable command history in a buffer. `q:` opens command history, `q/` opens search history. Edit any line, hit Enter to execute.

## #9 Live Substitution Preview: `inccommand`

See substitution results before executing. Add to config: `vim.opt.inccommand = "split"`

## #10 Copy/Move Lines: `:t` and `:m`

Duplicate or relocate lines without touching registers.

| Command | Effect |
|---------|--------|
| `:t.` | Duplicate current line below |
| `:t0` | Copy line to top of file |
| `:m+2` | Move line 2 lines down |
| `:'<,'>t.` | Duplicate selection below |

---

Presentation source: https://github.com/Piotr1215/youtube/blob/main/10-nvim-tricks/presentation.md

Dotfiles: https://github.com/Piotr1215/dotfiles

Which of these were new to you?
