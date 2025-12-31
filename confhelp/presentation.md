# confhelp

```bash +exec_replace
echo "config parser" | figlet -f small -w 90
```

> Find it. Edit it. Done.

<!-- end_slide -->

## What Is confhelp?

> Regex-powered config file parser

```bash +exec_replace
cat << 'EOF' | ccze -A
Extract anything from config files via regex:
keybindings, aliases, functions, abbreviations...

Input:  TOML config + directory to scan
Output: Structured list with file:line locations

[type]|key|description|file:line
EOF
```

<!-- end_slide -->

## The Problem

> You customized everything. Now you can't find it.

```bash +exec
find ~/dev/dotfiles -type f \( -name "*.conf" -o -name "*.zsh*" -o -name "*.lua" \) 2>/dev/null | head -12
```

<!-- end_slide -->

## Two Pain Points

> The old way: grep, scan, open, scroll, find...

```bash +exec
grep -rn "split" ~/dev/dotfiles/.tmux.conf 2>/dev/null
```

```bash +exec_replace
cat << 'EOF' | ccze -A

Which line was it? 62 or 63?
Let me open the file and scroll...

(tmux has `list-keys` but no jump-to-file)
EOF
```

<!-- end_slide -->

## The Solution

> Find instantly. Edit instantly.

```bash +exec_replace
cat << 'EOF' | ccze -A
confhelp --edit

1. Fuzzy search ALL your bindings
2. Select one
3. Opens $EDITOR at exact file:line

confhelp --edit → type "split" → Enter → editing line 62.
EOF
```

<!-- end_slide -->

## Quick fzf Refresher

> The Swiss Army knife of CLI selection

```bash +exec_replace
cat << 'EOF' | ccze -A
fzf by junegunn - 60k+ GitHub stars

Pipe anything → fuzzy filter → get result
The "grep meets autocomplete" of the terminal
EOF
```

```bash +acquire_terminal
ls -d ~/dev/dotfiles/*/ | fzf --prompt="Pick a dir: " --preview="ls {}"
```

<!-- end_slide -->

## How It Works

```bash +exec_replace
cat << 'EOF' | ccze -A
┌─────────────┐     ┌──────────────────┐
│ config.toml │     │ Your Dotfiles    │
│             │     │                  │
│ [tmux]      │     │ .tmux.conf       │
│ regex=...   │────>│ .zshrc           │
│ paths=[...] │     │ lua/mappings.lua │
└─────────────┘     └────────┬─────────┘
                             │
                      ┌──────▼──────┐
                      │   confhelp  │
                      │   parser    │
                      └──────┬──────┘
                             │
              ┌──────────────▼──────────────┐
              │ [tmux]|prefix+r|reload|:42  │
              │ [nvim]|<leader>f|find|:15   │
              │ [alias]|gs|git status|:3    │
              └─────────────────────────────┘
EOF
```

<!-- end_slide -->

## My Config

> From my dotfiles

```bash +exec
bat --language toml --plain --color always ~/.config/confhelp/config.toml 2>/dev/null | head -25
```

<!-- end_slide -->

## XDG Compatibility

> freedesktop.org standard for config locations

```bash +exec_replace
cat << 'EOF' | ccze -A
XDG Base Directory - freedesktop.org, 2003

Organizes dotfiles: ~/.config, ~/.local/share, ~/.cache
On your Mac/Linux? Probably yes - npm, Docker, k8s use it
EOF
```

```bash +exec
echo "XDG_CONFIG_HOME = ${XDG_CONFIG_HOME:-'(unset → ~/.config)'}"
ls -la ~/.config/confhelp/config.toml 2>/dev/null || echo "Run: confhelp --init"
```

<!-- end_slide -->

## See All Bindings

```bash +exec
confhelp -b ~/dev/dotfiles 2>/dev/null | head -25
```

<!-- end_slide -->

## Column Formatting

```bash +exec
confhelp -b ~/dev/dotfiles 2>/dev/null | column -t -s'|' | head -15
```

<!-- end_slide -->

## JSON Output

```bash +exec
confhelp -b ~/dev/dotfiles -f json 2>/dev/null | head -20
```

<!-- end_slide -->

## Find Conflicts

> Same key bound twice? confhelp catches it.

```bash +exec
confhelp -b ~/dev/dotfiles --conflicts 2>/dev/null | head -20
```

<!-- end_slide -->

## Missing Entries?

> Find patterns your regex might have missed

```bash +exec
confhelp -b ~/dev/dotfiles --check 2>/dev/null | head -10
```

<!-- end_slide -->

## The --edit Flag

> Select binding → open $EDITOR at exact line

```bash +acquire_terminal
confhelp -b ~/dev/dotfiles --edit
```

<!-- end_slide -->

## Integration: tmux Popup

> Bind to a hotkey in .tmux.conf

```bash +acquire_terminal
tmux display-popup -w 80% -h 80% -E 'confhelp -b ~/dev/dotfiles --edit'
```

<!-- end_slide -->

## Integration: rofi

> Pipe to rofi for GUI selection

```bash +acquire_terminal
confhelp -b ~/dev/dotfiles | column -t -s'|' | rofi -dmenu -i -p "config"
```

<!-- end_slide -->

## Integration: Global Hotkey

> Available from any application

```bash +exec_replace
cat << 'EOF' | ccze -A
autokey + alacritty floating terminal
  - Press hotkey anywhere → confhelp appears
  - Select entry → editor opens at exact line

Also integrated with Tealder (custom cheatsheets)
EOF
```

<!-- end_slide -->

## Before / After

| Old Way | confhelp |
|---------|----------|
| `grep -rn "split" ~/dotfiles` | `confhelp -s` |
| Scan output for file:line | Fuzzy search all entries |
| `nvim +62 .tmux.conf` | `confhelp --edit` |
| 3 commands, 30 seconds | 1 command, 3 seconds |

<!-- end_slide -->

## Install

```bash +exec_replace
cat << 'EOF' | ccze -A
pip install confhelp

confhelp --init          # create sample config
confhelp -b ~/dotfiles   # scan a directory
confhelp                 # uses base_dirs from config.toml
EOF
```

<!-- end_slide -->

## Resources

| Resource |
|----------|
| PyPI: https://pypi.org/project/confhelp/ |
| GitHub: https://github.com/Piotr1215/confhelp |
| Blog: https://blog.cloudrumble.net/dynamic-shortcuts-help-system |

<!-- end_slide -->

# That's All Folks!

```bash +exec_replace
just intro_toilet That\'s all folks!
```
