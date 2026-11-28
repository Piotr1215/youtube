# Semicolon Shortcuts

> Any value at the cursor, in any window, without leaving the keyboard

<!-- new_lines: 3 -->

```bash +exec_replace
echo "Semicolon Shortcuts" | figlet -f small -w 90
```

<!-- end_slide -->

## Copy and Paste

> How does a value get to where the cursor is?

```bash +exec_replace
./journey.sh 1
```

<!-- end_slide -->

## Copying with the Mouse

> The path is right there on screen.

```bash +exec +acquire_terminal
/// ./demo.sh shell <<'EOF'
fd alacritty
/// EOF
```

```bash +exec_replace
printf '\e[31m%s\e[0m\n' '✗ The hand leaves the keyboard every time.'
```

<!-- end_slide -->

## First Look

> Two semicolons and a word, and the path lands at the cursor.

```bash +exec +acquire_terminal
/// ./demo.sh shell <<'EOF'
nvim ;;dot
/// EOF
```

<!-- end_slide -->

## Copying from the Keyboard

> Clipboard history keeps every copy, and C copies what a command prints.

```bash +exec_replace
sed -n 14p "$HOME/dev/dotfiles/.zsh_aliases" | sed 's/ | /\n    | /g' |
	bat -l bash --style=plain --color=always --decorations=always
```

```bash +exec +acquire_terminal
/// ./demo.sh shell <<'EOF'
fd alacritty C
/// EOF
```

```bash +exec_replace
printf '\e[31m%s\e[0m\n' '✗ The value has to be on screen first.'
```

<!-- end_slide -->

## Fuzzy Finding

> What if the value is not on screen yet?

```bash +exec_replace
./journey.sh 2
```

<!-- end_slide -->

## Any List as a Menu

> A few letters of a path, and fzf finds it.

```bash +exec +acquire_terminal
/// ./demo.sh shell <<'EOF'
fd --type f | fzf | xsel --clipboard
/// EOF
```

```bash +exec_replace
printf '\e[31m%s\e[0m\n' '✗ Found, copied, then pasted by hand.'
```

<!-- end_slide -->

## A Path at the Cursor

> Ctrl-T opens the same menu mid-command and drops the path at the cursor.

```bash +exec +acquire_terminal
/// ./demo.sh shell <<'EOF'
bindkey '^T'
/// EOF
```

```bash +exec_replace
printf '\e[31m%s\e[0m\n' '✗ Only files below this folder, and only in the shell.'
```

<!-- end_slide -->

## Breaking the Flow

> What happens when the value lives somewhere else?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## The Mid-Command Detour

> Halfway through a command, the value lives in another app.

```bash +exec_replace
printf '  \e[36m%s\e[90m%s\e[33m%s\e[90m%s\e[33m%s\e[90m%s\e[33m%s\e[0m\n' 'curl -sI ▌' ' ──▶ ' 'browser' ' ──▶ ' 'find the page' ' ──▶ ' 'copy the URL'
printf '  \e[90m%s\e[0m\n' '  ▲                                               │'
printf '  \e[90m%s\e[0m\n' '  └──────────── back, paste, carry on ────────────┘'
```

```bash +exec +acquire_terminal
/// ./demo.sh shell <<'EOF'
curl -sI
/// EOF
```

```bash +exec_replace
printf '\e[31m%s\e[0m\n' '✗ Every value is a trip away from the command.'
```

<!-- end_slide -->

## Outside the Terminal

> A chat box or an email has no shell to help.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n' 'window      shell   fzf     Ctrl-T'
printf '  \e[36m%s\e[32m%s\e[32m%s\e[32m%s\e[0m\n' 'terminal    ' '✓       ' '✓       ' '✓'
printf '  \e[36m%s\e[31m%s\e[31m%s\e[31m%s\e[0m\n' 'chat app    ' '✗       ' '✗       ' '✗'
printf '  \e[36m%s\e[31m%s\e[31m%s\e[31m%s\e[0m\n\n' 'email       ' '✗       ' '✗       ' '✗'
printf '\e[31m%s\e[0m\n' '✗ Every value goes through copy and paste by hand.'
```

<!-- end_slide -->

## Semicolon Shortcuts

> What if the fuzzy menu worked in every window?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## A Menu in Every Window

> Two semicolons, a word and a space open a menu, and the choice lands at the cursor.

```bash +exec +acquire_terminal
/// ./demo.sh shell <<'EOF'
bat ;;dot
/// EOF
```

<!-- end_slide -->

## A Word for Every List

> Each word opens its own list, or types its value straight away.

```bash +exec_replace
"$HOME/dev/dotfiles/scripts/__show_autokey_bindings.sh" --bang-plain |
	grep -E '^;;(agent|ai|date|dot|ghuser|obs|session|skill|task) ' |
	sed -E 's/^(;;[^ ]+ +)→/\x1b[1;36m\1\x1b[90m→\x1b[0m/'
```

<!-- end_slide -->

## Every Trigger in One Menu

> Two semicolons and a question mark list every trigger and run the chosen one.

```bash +exec +acquire_terminal
/// ./demo.sh shell <<'EOF'
;;?
/// EOF
```

<!-- end_slide -->

## Shortcut Internals

> What runs between the keys and the menu?

```bash +exec_replace
./journey.sh 5
```

<!-- end_slide -->

## From Keys to Value

> One bash script sits between the keys and the menu.

```bash +exec_replace
row() { printf '  \e[90m%s\e[1;36m%s\e[90m%s\e[0m %s\n' "$1" "$2" "$3" "$4"; }
printf '  \e[1;33m%s\e[0m\n' ';;dot␣'
printf '  \e[90m%s\e[0m\n' '  │'
printf '  \e[90m%s\e[0m\n' '  ▼'
row '┌─ ' 'AutoKey'      ' ───────────' 'sees the keys in every window'
printf '  \e[90m%s\e[0m\n' '│'
row '├─ ' 'value picker' ' ──────'      'a bash script: one word, one list'
printf '  \e[90m%s\e[0m\n' '│'
row '├─ ' 'the list'     ' ──────────'  'a file, or a program that prints values'
printf '  \e[90m%s\e[0m\n' '│'
row '├─ ' 'rofi'         ' ──────────────' 'a fuzzy menu over the current window'
printf '  \e[90m%s\e[0m\n' '│'
row '└─ ' 'paste'        ' ─────────────'  'the choice lands at the cursor'
```

<!-- end_slide -->

## A List Is a File

> One value per line, and a label after the bar to search by.

```file
path: lists/docs
language: text
```

<!-- end_slide -->

## A List Can Be a Program

> When the values change, a program prints them fresh every time.

```bash +exec_replace
sed -n '/^root=/,/LC_ALL=C sort/p' "$HOME/.config/value-sets/dot" |
	awk 'length > 84 { l = substr($0, 1, 60); sub(/ [^ ]*$/, "", l); print l " … " $NF; next } 1' |
	bat -l bash --style=plain --color=always --decorations=always
```

```bash +exec
~/.config/value-sets/dot | head -3
```

<!-- end_slide -->

## A Word Points at a List

> A trigger is a word, and one line that runs the picker with its list.

```bash +exec_replace
p="$HOME/dev/dotfiles/.config/autokey/data/My Phrases"
printf '\e[90m%s\e[0m\n' '.dot_picker.json'
jq -C '.abbreviation | {abbreviations, immediate}' "$p/.dot_picker.json"
printf '\n\e[90m%s\e[0m\n' 'dot_picker.py'
grep 'Popen' "$p/dot_picker.py" | sed -E 's/(\.sh",) /\1\n                  /' |
	bat -l python --style=plain --color=always --decorations=always
echo
printf '\e[33m%s\e[0m\n' 'immediate false: it fires on the space after the word'
```

<!-- end_slide -->

## A New List, Live

> Write the list, point a word at it, and the detour is gone.

```bash +exec +acquire_terminal
/// ./demo.sh register
/// ./demo.sh shell <<'EOF'
curl -sI ;;docs | head -1
/// EOF
```

<!-- end_slide -->

## Pasted, Not Typed

> The value is pasted, so the app takes it as one block.

```bash +exec_replace
printf '  \e[31m%s\e[36m%s\e[1;33m%s\e[0m%s\n' '✗ ' 'typed   ' '/      ' 'a chat app opens its command menu'
printf '  \e[31m%s\e[36m%s\e[1;33m%s\e[0m%s\n' '✗ ' 'typed   ' '@      ' 'Claude Code opens its file menu'
printf '  \e[31m%s\e[36m%s\e[1;33m%s\e[0m%s\n' '✗ ' 'typed   ' '(      ' 'an editor adds its own )'
printf '  \e[32m%s\e[1;36m%s\e[0m%s\n' '✓ ' 'pasted         ' 'lands whole, exactly as picked'
```

<!-- end_slide -->

## Getting Started

> What does it take to try it?

```bash +exec_replace
./journey.sh 6
```

<!-- end_slide -->

## Install

> AutoKey is an X11 app, so this runs on Linux with Xorg.

```bash
sudo apt install autokey-gtk rofi xdotool xclip
git clone https://github.com/Piotr1215/dotfiles
```

```bash +exec_replace
printf '  \e[35m•\e[0m \e[36m%s\e[0m%s\n' 'scripts/__value_picker.sh      ' 'the picker'
printf '  \e[35m•\e[0m \e[36m%s\e[0m%s\n' 'scripts/__lib_rofi_theme.sh    ' 'its rofi look'
printf '  \e[35m•\e[0m \e[36m%s\e[0m%s\n' '.config/value-sets/            ' 'example lists'
```

<!-- end_slide -->

## Takeaways

```bash +exec_replace
printf '  \e[32m%s\e[0m\e[36m%s\e[0m%s\n' '✓ ' 'so what     ' 'any value lands at the cursor, in any window'
printf '  \e[32m%s\e[0m\e[36m%s\e[0m%s\n' '✓ ' 'now what    ' 'the fzf idea, stretched over the whole desktop'
printf '  \e[1;33m%s\e[0m\e[36m%s\e[0m%s\n' '▶ ' 'then what   ' 'a list for the value copied by hand most often'
```

<!-- end_slide -->

## Resources

```markdown
Dotfiles:    https://github.com/Piotr1215/dotfiles
AutoKey:     https://github.com/autokey/autokey
rofi:        https://github.com/davatorium/rofi
fzf:         https://github.com/junegunn/fzf
Channel:     youtube.com/@cloud-native-corner
```

<!-- end_slide -->

# That's All Folks! 👋

```bash +exec_replace
just intro_toilet That\'s all folks!
```
