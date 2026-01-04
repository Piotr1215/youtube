# 10 Neovim Features You're Probably Not Using

<!-- new_lines: 3 -->

```bash +exec_replace
echo "10 Neovim Tricks" | figlet -f small -w 90
```

<!-- end_slide -->

# The Rules

```bash +exec_replace
cat << 'EOF' | ccze -A
• Built into Vim/Neovim - no plugins

• Works in vanilla config

• Actually useful in daily editing

• Not commonly known or used
EOF
```

<!-- end_slide -->

# #1 Shell Filter: `!` and `!!`

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Pipe text through external commands

WHY: Use any Unix tool as a text processor
EOF
```

| Command | What it does |
|---------|--------------|
| `:.!date` | Replace line with date output |
| `!ip sort` | Sort paragraph |
| `!ap jq .` | Format JSON in paragraph |
| `:%!column -t` | Align entire file |

```bash +acquire_terminal
nvim demo-filter.md
```

<!-- end_slide -->

# #2 Visual Block Increment: `g Ctrl-a`

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Create incrementing sequences in visual block

WHY: Generate numbered lists, indices, IDs instantly

Select column of zeros, press g Ctrl-a
EOF
```

```bash +acquire_terminal
nvim demo-increment.md
```

<!-- end_slide -->

# #3 Global Command: `:g/pattern/cmd`

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Run Ex command on all matching lines

WHY: Surgical bulk operations without regex gymnastics
EOF
```

| Command | Effect |
|---------|--------|
| `:g/TODO/d` | Delete all TODOs |
| `:g/^$/d` | Delete empty lines |
| `:g/error/t$` | Copy error lines to end |
| `:g/func/norm A;` | Append `;` to all functions |

```bash +acquire_terminal
nvim demo-global.md
```

<!-- end_slide -->

# #4 Command-line Registers: `Ctrl-r`

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Insert register contents in : or / prompt

WHY: No more typing long paths or search terms
EOF
```

| Shortcut | Inserts |
|----------|---------|
| `Ctrl-r Ctrl-w` | Word under cursor |
| `Ctrl-r "` | Last yank |
| `Ctrl-r /` | Last search pattern |
| `Ctrl-r =` | Expression (e.g., `system('date')`) |

```bash +acquire_terminal
nvim demo-ctrlr.md
```

<!-- end_slide -->

# #5 Normal on Selection: `:'<,'>norm`

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Run normal mode commands on each selected line

WHY: Multi-cursor without plugins

Select lines, then:
:'<,'>norm A,        → Append comma to each line
:'<,'>norm I#        → Comment each line
:'<,'>norm @q        → Run macro on each line
:'<,'>norm f=lD      → Delete after = on each
EOF
```

```bash +acquire_terminal
nvim demo-norm.md
```

<!-- end_slide -->

# #6 The `g` Commands You Need

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Navigation jumps with g prefix

WHY: Jump to exactly where you need to be
EOF
```

| Command | Effect |
|---------|--------|
| `gi` | Go to last insert position + insert mode |
| `g;` | Jump to previous change |
| `g,` | Jump to next change |
| `gv` | Reselect last visual selection |

```bash +acquire_terminal
nvim demo-norm.md
```

<!-- end_slide -->

# #7 Marks: Hidden Power

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Auto-marks vim sets for you

WHY: Jump to last edit, yank boundaries, etc.
EOF
```

| Mark | Jumps to |
|------|----------|
| ``` `` ``` | Previous position (toggle back!) |
| `` `. `` | Last change position |
| `` `" `` | Position when file was last closed |
| `` `[ `` / `` `] `` | Start/end of last yank or change |

```bash +acquire_terminal
nvim demo-marks.md
```

<!-- end_slide -->

# #8 Command History Window: `q:`

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Editable command history in buffer

WHY: Compose complex commands with full editing

q:       opens command history window
q/       opens search history window
Ctrl-f   in cmdline switches to window mode

Edit any line, hit Enter to execute
EOF
```

```bash +acquire_terminal
nvim demo-norm.md
```

<!-- end_slide -->

# #9 Live Substitution Preview: `inccommand`

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: See substitution results before executing

WHY: No more "oops wrong regex"

In your config:
vim.opt.inccommand = "split"

split   → shows preview in split window
nosplit → shows preview inline only
EOF
```

```bash +acquire_terminal
nvim demo-subst.md
```

<!-- end_slide -->

# #10 Copy/Move Lines: `:t` and `:m`

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Duplicate or relocate lines without registers

WHY: Keep your yank register untouched
EOF
```

| Command | Effect |
|---------|--------|
| `:t.` | Duplicate current line below |
| `:t0` | Copy line to top of file |
| `:t$` | Copy line to end of file |
| `:m+2` | Move line 2 lines down |
| `:'<,'>t.` | Duplicate selection below |

```bash +acquire_terminal
nvim demo-copy.md
```

<!-- end_slide -->

# Bonus: Remote Control with `--listen`

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Control Neovim from terminal

WHY: Integration with external tools and scripts

Left pane:  nvim --listen /tmp/nvim.sock file.txt
Right pane: nvim --server /tmp/nvim.sock --remote-send ':e new.txt<CR>'
EOF
```

```bash +acquire_terminal
tmux split-window -h \; \
  send-keys "nvim --server /tmp/nvim-demo.sock --remote-send 'ggO# Inserted remotely!<Esc>'" \; \
  select-pane -L && nvim --listen /tmp/nvim-demo.sock demo-listen.md
```

<!-- end_slide -->

# Recap

| # | Feature | One-liner |
|---|---------|-----------|
| 1 | `!` / `!!` | Pipe through shell |
| 2 | `g Ctrl-a` | Visual block increment |
| 3 | `:g/pat/cmd` | Global command |
| 4 | `Ctrl-r` | Insert registers in cmdline |
| 5 | `:'<,'>norm` | Normal on selection |
| 6 | `gi`/`g;`/`gv` | g-command jumps |
| 7 | `` `. `` | Auto-marks / mark ranges |
| 8 | `q:` | Command history window |
| 9 | `inccommand` | Live substitution preview |
| 10 | `:t` / `:m` | Copy/move lines |

<!-- end_slide -->

# That's All Folks!

<!-- new_lines: 3 -->

```bash +exec_replace
echo "Thanks!" | figlet -f small -w 90
```
