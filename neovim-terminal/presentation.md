# Neovim Terminal

> The shell inside your editor

```bash +exec_replace
echo "Neovim Terminal" | figlet -f small -w 90
```

<!-- end_slide -->

## What Is a Terminal?

> A program that displays text and accepts keyboard input

```bash +exec_replace
cat << 'EOF' | ccze -A
1970s: Physical hardware (VT100, VT220)
       Keyboard + CRT screen + serial cable

1980s: Software emulators (xterm)
       Same behavior, no physical hardware

Today: Terminals everywhere
       iTerm, Alacritty, Kitty, Neovim
EOF
```

<!-- end_slide -->

## VT220 and xterm

> Standards that define terminal behavior

```bash +exec_replace
cat << 'EOF' | ccze -A
VT220: Terminal made by DEC in 1983.
       Defined escape sequences for:
       - Cursor movement
       - Text colors
       - Screen clearing

xterm: Software that speaks VT220.
       Most terminals today are "xterm-compatible".
EOF
```

<!-- end_slide -->

## What Is libvterm?

> The library that powers neovim terminal

```bash +exec_replace
cat << 'EOF' | ccze -A
Written by Paul Evans (leonerd.org.uk).
Embedded in neovim at src/nvim/vterm/.

Parses bytes from shell into commands.
Neovim displays output in a buffer.

Programs like htop and vim run inside it.
EOF
```

<!-- end_slide -->

## What Are OSC Sequences?

> Messages from shell to terminal

```bash +exec_replace
cat << 'EOF' | ccze -A
OSC = Operating System Command
Format: ESC ] number ; data ST

OSC 7:   "I changed directory"
OSC 52:  "Copy this to clipboard"
OSC 133: "Prompt starts here"

Shell sends these, terminal acts on them.
EOF
```

<!-- end_slide -->

## How It Works

> From terminal.c in neovim source

```bash +exec_replace
just digraph what-is-terminal
```

```bash +exec_replace
cat << 'EOF' | ccze -A
Terminal output goes into a buffer.
Scrollback stored above visible area.
Updates batched every 10ms.
EOF
```

<!-- end_slide -->

## It's a Buffer

> The key insight for using neovim terminal

```bash +exec_replace
cat << 'EOF' | ccze -A
Terminal output IS a buffer.
Read-only, but navigation works:

- Text objects:    yiw, yap
- Search:          /, ?, *, #
- Plugins:         treesitter, mini.ai
- Marks:           m, '

Yank output, search logs, jump around.
EOF
```

<!-- end_slide -->

## Tip: Opening Terminals

> The term:// URI

```bash +exec
../wpane "./README.md"
```

<!-- end_slide -->

## Tip: Quick Splits

> :T and :VT commands

```bash +exec_replace
cat << 'EOF' | ccze -A
:T      horizontal split with shell
:VT     vertical split with shell

Both auto-enter insert mode.
EOF
```

```bash +exec
../wpane "+306 ~/.config/nvim/lua/autocommands.lua"
```

<!-- end_slide -->

## Tip: Run Command to Buffer

> :R runs anything

```bash +exec_replace
cat << 'EOF' | ccze -A
:R ls -la              list files
:R tldr tar            quick reference
:R git log --oneline   git history
:R curl example.com    fetch URL

Output goes to scratch buffer.
Press q to close.
EOF
```

```bash +exec
../wpane "+204 ~/.config/nvim/lua/autocommands.lua"
```

<!-- end_slide -->

## Tip: Execute Scripts

> Run code from within neovim

```bash +exec
../wpane "./demo.sh"
```

<!-- end_slide -->

## Tip: Evaluate Code Blocks

> Run code blocks in any markdown file

```bash +exec
../wpane "./notes.md"
```

<!-- end_slide -->

## Tip: Execute Mappings

> The implementation

```bash +exec
../wpane "+301 ~/.config/nvim/lua/mappings.lua"
```

<!-- end_slide -->

## Tip: Auto-Close on Exit

> Default nvim behavior for :terminal

```bash +exec_replace
cat << 'EOF' | ccze -A
:terminal (no args) + exit 0:  buffer closes
:terminal ls + exit 0:         buffer stays

Only shells auto-close, not one-off commands.
EOF
```

<!-- end_slide -->

## Tip: Jump Between Prompts

> ]] and [[ with OSC 133

```bash +exec_replace
cat << 'EOF' | ccze -A
Shell emits OSC 133 at each prompt.
Neovim marks those positions.

]]    jump to next prompt
[[    jump to previous prompt

Requires shell config (precmd).
EOF
```

```bash +exec
../wpane "+402 ~/dev/dotfiles/.zshrc"
```

<!-- end_slide -->

## Quirks

> Things that may surprise you

```bash +exec_replace
cat << 'EOF' | ccze -A
Buffer is read-only (can yank, not edit).
Marked modified by default.
No line numbers, wrap disabled.
Scrollback has limits (configurable).
EOF
```

<!-- end_slide -->

## Finding Help

> :helpgrep is useful

```bash +exec_replace
cat << 'EOF' | ccze -A
:h terminal              main docs
:h TermOpen              autocmd events
:helpgrep terminal       search all topics
:helpgrep scrollback     find options
EOF
```

<!-- end_slide -->

## Resources

| Resource |
|----------|
| :h terminal |
| :h terminal-config |
| neovim/neovim src/nvim/terminal.c |
| github.com/Piotr1215/dotfiles |

<!-- end_slide -->

# That's All Folks!

```bash +exec_replace
just intro_toilet That\'s all folks!
```
