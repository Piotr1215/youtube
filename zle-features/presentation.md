# ZLE Power Features

<!-- new_lines: 3 -->


```bash +exec_replace
echo "ZLE Features" | figlet -f small -w 90
```

<!-- end_slide -->

# Built-in Bindings

| Key | Widget | What |
|-----|--------|------|
| `^X^R` | replace-string | Find/replace in line |
| `^X^T` | transpose-words | Swap words |
| `^[Enter` | accept-and-hold | Run + keep on prompt |
| `^X^E` | edit-command-line | Edit in $EDITOR (nvim) |
| `^Q` | push-line | Stash line, restore after next cmd |

<!-- end_slide -->

# Key Notation

```bash +exec_replace
printf '\e[33m%s\e[0m\n' "Symbols:"
printf '  \e[32m%-6s\e[0m %s\n' "^" "= Ctrl key"
printf '  \e[32m%-6s\e[0m %s\n' "^[" "= Alt (or Escape)"
printf '  \e[32m%-6s\e[0m %s\n' "^M" "= Enter (carriage return)"
printf '\n'
printf '\e[33m%s\e[0m\n' "Sequences (two-key combos):"
printf '  \e[32m%-6s\e[0m %s\n' "^XY" "= Ctrl+X, release Ctrl, press Y"
printf '  \e[32m%-6s\e[0m %s\n' "^X^Y" "= hold Ctrl, press X, press Y"
printf '  \e[32m%-6s\e[0m %s\n' "^X^X" "= hold Ctrl, tap X twice"
printf '\n'
printf '\e[33m%s\e[0m\n' "Case does not matter for Ctrl:"
printf '  \e[37m^x = ^X (both mean Ctrl+X)\e[0m\n'
printf '\n'
printf '\e[33m%s\e[0m\n' "Useful commands:"
printf '  \e[36m%-24s\e[0m %s\n' "bindkey | grep \"^X\"" "Show ^X bindings"
printf '  \e[36m%-24s\e[0m %s\n' "zle -la" "List all widgets"
printf '  \e[36m%-24s\e[0m %s\n' "man zshzle" "Full ZLE documentation"
```

<!-- end_slide -->

# What is ZLE?

```bash +exec_replace
printf '\e[1;36m%s\e[0m\n\n' "ZLE = Zsh Line Editor"
printf '\e[33m%s\e[0m\n'   "Keystroke Pipeline:"
printf '  \e[32m%s\e[0m  %s\n' "Terminal        " "alacritty, kitty, wezterm..."
printf '  \e[32m%s\e[0m  %s\n' "  -> zsh        " "receives raw keystrokes"
printf '  \e[32m%s\e[0m  %s\n' "    -> ZLE      " "maps keys to widgets (actions)"
printf '  \e[32m%s\e[0m  %s\n' "      -> widget " "ZLE modifies the command buffer"
printf '\n'
printf '\e[33m%s\e[0m\n'   "What ZLE controls:"
printf '  \e[35m•\e[0m %s\n' "Prompt rendering"
printf '  \e[35m•\e[0m %s\n' "Cursor movement"
printf '  \e[35m•\e[0m %s\n' "Tab completion"
printf '  \e[35m•\e[0m %s\n' "All key input"
printf '\n'
printf '\e[33m%s\e[0m\n'   "Why it matters:"
printf '  \e[37mProgrammable — create widgets, override defaults, rebind keys.\e[0m\n'
```

<!-- end_slide -->

# ZLE Architecture

```bash +exec_replace
printf '┌───────────┐           ┌─────────────┐           ┌──────────────┐           ┌─────────────────┐              ┌─────────┐\n'
printf '│           │           │   \e[36mKeymap\e[0m    │           │              │           │     \e[36mBUFFER\e[0m      │              │         │\n'
printf '│ \e[1;36mKeystroke\e[0m │  \e[33mlookup\e[0m   │ \e[36memacs/viins\e[0m │  \e[33minvoke\e[0m   │    \e[1;36mWidget\e[0m    │  \e[33mmodify\e[0m   │ \e[36mLBUFFER|RBUFFER\e[0m │  \e[33mredisplay\e[0m   │ \e[1;36mDisplay\e[0m │\n'
printf '│           │ ────────▶ │             │ ────────▶ │              │ ────────▶ │     \e[36mCURSOR\e[0m      │ ───────────▶ │         │\n'
printf '└───────────┘           └─────────────┘           └──────────────┘           └─────────────────┘              └─────────┘\n'
printf '                                                    │\n'
printf '                                                    │ \e[33maccept-line\e[0m\n'
printf '                                                    ▼\n'
printf '                                                  ┌──────────────┐\n'
printf '                                                  │   \e[1;36mExecute\e[0m    │\n'
printf '                                                  └──────────────┘\n'
```

<!-- end_slide -->

# Custom Widget Anatomy

```bash
jump-to-word() {
  # BUFFER  = entire command line contents
  # CURSOR  = current position (0-based offset)
  # ${(z)BUFFER} splits BUFFER by shell words
  local words=(${(z)BUFFER})

  # Pipe words to fzf for selection
  local target=$(printf '%s\n' "${words[@]}" | \
    fzf --height=10 --reverse)

  # ${BUFFER[(i)$target]} finds index (1-based)
  # CURSOR is 0-based, so subtract 1
  [[ -n "$target" ]] && \
    CURSOR=$((${BUFFER[(i)$target]} - 1))

  zle redisplay  # Refresh display after modifying CURSOR
}
zle -N jump-to-word        # Register widget
bindkey '^X^X' jump-to-word # Bind to keymap
```

<!-- end_slide -->

# zledit Features

```bash +exec_replace
printf '\e[33m%s\e[0m\n' "Features:"
printf '  \e[32m%-18s\e[0m %s\n' "Multiple pickers" "fzf, fzf-tmux, sk (skim), peco, percol"
printf '  \e[32m%-18s\e[0m %s\n' "Auto-detection" "prefers fzf-tmux in tmux, falls back gracefully"
printf '  \e[32m%-18s\e[0m %s\n' "Configurable" "keybindings, picker options via zstyle"
printf '  \e[32m%-18s\e[0m %s\n' "Extensible" "custom previewers and actions via config.toml"
printf '  \e[32m%-18s\e[0m %s\n' "Fast" "~0.2ms load time"
printf '\n'
printf '\e[33m%s\e[0m\n' "Installation (zinit):"
printf '  \e[36mzinit light Piotr1215/zledit\e[0m\n'
printf '\n'
printf '\e[33m%s\e[0m\n' "Configuration:"
printf '  \e[36m%s\e[0m\n' "zstyle ':zledit:' picker fzf"
printf '  \e[36m%s\e[0m\n' "zstyle ':zledit:' picker-opts '--reverse --border --prompt=\"JUMP -> \"'"
printf '  \e[36m%s\e[0m\n' "zstyle ':zledit:' binding '^X^X'"
printf '  \e[36m%s\e[0m\n' "zstyle ':zledit:' config ~/.config/zledit/config.toml"
```

> github.com/Piotr1215/zledit

<!-- end_slide -->

# That's All Folks!

<!-- new_lines: 3 -->

```bash +exec_replace
echo "That's All Folks!" | figlet -f small -w 90
```
