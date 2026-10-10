Neovim Multi-Line Editing Overview, Multicursor Included

Neovim nightly now ships native multicursor, so I lined it up against every other built-in way to edit many lines at once and counted keystrokes on the same nine exercises. Multicursor took seven of them; visual block and `:v` still won their own cases.

https://youtu.be/S5kfUZQNzhU

---

## #1 Visual Block: `Ctrl-v`

Select a rectangle, then `I` or `A` types into every row of it.

| Keys | Effect |
|------|--------|
| `Ctrl-v G I- <Esc>` | Insert `- ` before the column on every line |
| `Ctrl-v G $ A; <Esc>` | Append `;` at every line end |

Best for the same column on adjacent lines. Breaks when the target moves from line to line.

## #2 Normal on a Range: `:norm`

Run normal-mode keys on each line of a range. Motions find each line's own target.

| Command | Effect |
|---------|--------|
| `:%norm I- ` | Prefix every line with `- ` |
| `:%norm xf]D` | Delete the `[`, jump to `]`, delete to the end |

## #3 Global Command: `:g` and `:v`

Pick lines by a condition anywhere in the file, then run a command on them.

| Command | Effect |
|---------|--------|
| `:g/pattern/cmd` | Run cmd on lines that match |
| `:v/pattern/cmd` | Run cmd on lines that do not |
| `:v/:/s/^/[ok] /` | Prefix every line without a colon |
| `:g/error/.!tr a-z A-Z` | Run a CLI on matching lines only |

## #4 Substitution: `:s`

Rewrite every match of a regex, with groups and case changes.

`:%s/\v_(.)/\u\1/g` turns snake_case into camelCase:

| Part | Meaning |
|------|---------|
| `\v` | Very magic: `( )` group without backslashes |
| `_(.)` | An underscore and the letter after it |
| `\u\1` | That letter, uppercased |
| `g` | Every match on the line |

## #5 External Commands: `:{range}!`

Any tool that reads stdin and writes stdout becomes an edit.

| Command | Effect |
|---------|--------|
| `:%!sort -u` | Sort the lines, drop duplicates |
| `:'<,'>!column -t` | Align the selection into columns |
| `:%!jq .` | Pretty-print JSON |

## #6 Macros: `q` and `@`

Record an edit once, replay it anywhere.

| Keys | Effect |
|------|--------|
| `qq ... +q` | Record the edit, end on the next line |
| `4@q` | Replay it four times |
| `"qp` | Paste the macro as text to fix it |

## #7 Multicursor: `Q` (nightly)

Place cursors, and every edit lands at each one as you type. One undo reverts all of them.

| Keys | Effect |
|------|--------|
| `{Visual}Q` | A cursor on each selected line |
| `[count]Q` | A cursor on every search match |
| `:g/pattern/normal! nQ` | A cursor on every match, by condition |
| `:cdo normal! Q` | A cursor at each quickfix item |
| `@q` | The macro replays at every cursor |

A cursor whose edit cannot start, like `ct;` on a line with no `;`, is removed.

## Which One to Use

Ask from the top; the first yes picks the method.

| Question | Method |
|----------|--------|
| A job a CLI tool already does? | `:%!` external commands |
| Across files, or too many lines to watch? | `:s` or `:norm` with `:cdo` |
| An edit you will replay later? | Macro |
| One column on adjacent lines? | Visual block |
| Lines picked by a pattern? | `:g` or `:v` |
| One fixed string swapped for another? | `:s` |
| Anything else on screen | Multicursor |

## Keystroke Scoreboard

Same exercise, cursor on line 1, `nvim --clean`. Shortest other method against multicursor.

| Exercise | Other method | Keys | Multicursor | Keys |
|----------|--------------|------|-------------|------|
| add prefix | `<C-V>GI- <Esc>` | 6 | `VGQI- <Esc>` | 7 |
| log levels | `qqxf]D+q4@q` | 11 | `VGQxf]D` | 7 |
| brackets to quotes | `qqr"f]r"+q4@q` | 13 | `VGQr"f]r"` | 9 |
| first field | `:%s/,.*<CR>` | 8 | `VGQf,D` | 6 |
| add semicolons | `:%s/$/;<CR>` | 8 | `VGQA;<Esc>` | 6 |
| wrap parens | `qqwi(<Esc>A)<Esc>+q4@q` | 14 | `VGQwi(<Esc>A)<Esc>` | 10 |
| flip assignment | `qqdt=A=<Esc>p0xjq4@q` | 16 | `VGQdt=A=<Esc>p0x` | 12 |
| conditional prefix | `:v/:/s/^/[ok] <CR>` | 15 | `/^\w*$<CR>1QI[ok] <Esc>` | 16 |
| snake to camel | `:%s/\v_(.)/\u\1/g<CR>` | 18 | `/_<CR>1Qx~` | 7 |

Multicursor wins on-screen edits. A column or a condition still favors the classics.

## Try It

- Nightly build: https://github.com/neovim/neovim/releases/tag/nightly
- `:help mcursor` covers every key, with examples
- The nine exercises, each checked against its goal: https://github.com/Piotr1215/youtube/tree/main/nvim-multi-line-editing
- Multicursor pull request: https://github.com/neovim/neovim/pull/41587
- Blog post: https://blog.olimorris.com/2026/09/02/multiple-cursors-in-neovim-0.13

Presentation source: https://github.com/Piotr1215/youtube/blob/main/nvim-multi-line-editing/presentation.md

Dotfiles: https://github.com/Piotr1215/dotfiles

Which method do you reach for first, and did multicursor change that?
