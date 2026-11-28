---
theme:
  override:
    code:
      padding:
        horizontal: 2
        vertical: 1
      background: true
---

# Semicolon Shortcuts

> Bring the value to the cursor instead of going to find it

<!-- new_lines: 3 -->

```bash +exec_replace
echo "Semicolon Shortcuts" | figlet -f small -w 90
```

<!-- end_slide -->

## Copy and Paste

> How does a value get from where it lives to where the cursor is?

```bash +exec_replace
./journey.sh 1
```

<!-- end_slide -->

## A Teammate's Question

> The answer is a short reply, and every value in it lives somewhere else.

```bash +exec_replace
printf '  \e[90m%s\e[0m%s\n\n' 'teammate   ' 'Which file sets up your terminal, and where is that fuzzy finder?'
printf '  \e[90m%s\e[36m%s\e[1;33m%s\e[90m%s\e[33m%s\e[0m\n' 'reply      ' 'Config file:   ' '…' '     ◀── ' 'the file tree'
printf '  \e[90m%s\e[36m%s\e[1;33m%s\e[90m%s\e[33m%s\e[0m\n' '           ' 'fzf docs:      ' '…' '     ◀── ' 'the browser'
```

<!-- end_slide -->

## Copying with the Mouse

> Select it, copy it, paste it: where everyone starts.

```bash +exec_replace
./ladder.sh 1
```

```bash +exec_replace
printf '  \e[90m%s\e[0m%s\e[36m%s\e[0m\n' 'browser    ' 'the fzf page ─▶ select the URL ─▶ copy ─▶ ' 'paste in the reply'
printf '  \e[90m%s\e[0m%s\e[36m%s\e[0m\n' 'terminal   ' 'realpath …/alacritty.toml ⏎ ─▶ select it ─▶ copy ─▶ ' 'paste'
echo
printf '  \e[32m%s\e[0m\n' '✓ Works in every app.'
printf '  \e[31m%s\e[0m\n' "✗ The hand leaves the keyboard, even for a command's own output."
```

```bash +exec +acquire_terminal +no_background
/// ./demo.sh clip-demo
/// ./demo.sh shell <<'EOF'
/// realpath .config/alacritty/alacritty.toml
/// EOF
```

<!-- end_slide -->

## Copying What a Command Prints

> A capital C at the end of a command copies what it prints.

```bash +exec_replace
./ladder.sh 2
```

```bash +exec_replace
printf '  \e[90m%s\e[0m\n' "alias -g C='| tee >(sed … | perl … | xsel --clipboard)'"
printf '\n'
printf '  \e[36m%s\e[0m%s\n' 'realpath … C' ' ─▶ realpath … | tee ─┬─▶ screen'
printf '  %s\n' '                                  └─▶ drop colours, last newline ─▶ clipboard'
echo
printf '  \e[32m%s\e[0m\n' '✓ Copies from the keyboard.'
printf '  \e[31m%s\e[0m\n' '✗ Each copy replaces the last.'
```

```bash +exec +acquire_terminal +no_background
/// ./demo.sh shell <<'EOF'
/// realpath .config/alacritty/alacritty.toml C
/// EOF
```

<!-- end_slide -->

## Clipboard History

> A clipboard manager keeps every copy, so an older one is one pick away.

```bash +exec_replace
./ladder.sh 3
```

```bash +exec_replace
printf '  %s\n' 'copy ─▶ clipboard ─▶ paste'
printf '  %s\n' '            │'
printf '  %s\e[36m%s\e[0m%s\n' '            └─▶ ' 'history' ' (parcellite): every copy, newest first'
printf '  %s\e[36m%s\e[0m%s\n' '                   ' 'Ctrl+Alt+1' ', its menu key ─▶ pick ─▶ back on the clipboard'
echo
printf '  \e[32m%s\e[0m\n' '✓ The URL copied earlier comes back without the browser.'
printf '  \e[31m%s\e[0m\n' '✗ A value has to be on screen and copied first.'
```

```bash +exec +acquire_terminal +no_background
/// ./demo.sh shell <<'EOF'
/// curl -sI
/// EOF
/// ./demo.sh clip-own
```

<!-- end_slide -->

## Fuzzy Finding

> What if the value is not on screen yet?

```bash +exec_replace
./journey.sh 2
```

<!-- end_slide -->

## Any File as a Menu

> fzf turns a list of lines into a menu that narrows with every letter.

```bash +exec_replace
./ladder.sh 4
```

```bash +exec_replace
printf '  \e[90m%s\e[0m\n' 'lines in              fzf                   one line out'
printf '  %s\e[1;36m%s\e[0m%s\n' 'every file below  ─▶  ' '> alactoml' '        ─▶  .config/alacritty/alacritty.toml'
printf '  %s\n' 'this folder           letters in order,'
printf '  %s\n' '(or any input)        gaps allowed'
echo
printf '  \e[32m%s\e[0m\n' '✓ A few letters find a file that was never on screen.'
printf '  \e[31m%s\e[0m\n' '✗ The path is printed, so it still needs a copy and a paste.'
```

```bash +exec +acquire_terminal +no_background
/// ./demo.sh shell <<'EOF'
/// fzf
/// EOF
```

<!-- end_slide -->

## A Path at the Cursor

> Ctrl-T opens the same menu mid-command and puts the path at the cursor.

```bash +exec_replace
./ladder.sh 5
```

```bash +exec_replace
printf '  \e[36m%s\e[0m\n' 'rg -w Paste ▌'
printf '  %s\e[90m%s\e[0m\n' '  │ ' "Ctrl-T, fzf's key binding for zsh"
printf '  %s\n' '  ▼'
printf '  %s\e[1;36m%s\e[0m\n' 'fzf over files and folders below here ─▶ ' '> alactoml'
printf '  %s\e[90m%s\e[0m\n' '  │ ' 'Enter'
printf '  %s\n' '  ▼'
printf '  \e[36m%s\e[0m\n' 'rg -w Paste .config/alacritty/alacritty.toml'
echo
printf '  \e[32m%s\e[0m\n' '✓ No clipboard and no paste; the command carries on.'
printf '  \e[31m%s\e[0m\n' '✗ Paths only, and only in the shell.'
```

```bash +exec +acquire_terminal +no_background
/// ./demo.sh shell <<'EOF'
/// rg -w Paste
/// EOF
```

<!-- end_slide -->

## The Lookup Detour

```bash +exec_replace
printf '  \e[36m%-22s\e[33m%-24s\e[36m%s\e[0m\n' 'Draft' 'Terminal' 'Draft'
printf '  %-17s \e[90m%s\e[0m %-15s \e[90m%s\e[0m %s\n' \
	'Config file: ▌' '────▶' 'Find → copy' '────────▶' 'Paste → resume'
```

<!-- end_slide -->

## The Design

> What would a menu in every window need?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## What the Fix Needs

> Each limit met so far names a job, and each job gets a piece.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n\n' 'limit so far                    the fix needs             piece'
printf '  \e[31m%s\e[32m%s\e[1;36m%s\e[0m\n' '✗ Ctrl-T only in the shell      ' '✓ keys heard in any app   ' 'AutoKey'
printf '  \e[31m%s\e[32m%s\e[1;36m%s\e[0m\n' '✗ links and ids live elsewhere  ' '✓ lists of anything       ' 'a file or a program'
printf '  \e[31m%s\e[32m%s\e[1;36m%s\e[0m\n' '✗ fzf draws in a terminal       ' '✓ a menu over any window  ' 'rofi'
printf '  \e[31m%s\e[32m%s\e[1;36m%s\e[0m\n' '✗ a copy still needs a paste    ' '✓ the pick at the cursor  ' 'xclip and Shift+Insert'
echo
printf '  \e[33m%s\e[0m\n' 'A bash script, the value picker, ties the pieces together.'
```

<!-- end_slide -->

## Kinds of Shortcut

> A word types fixed text, or runs the picker on a list.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n\n' 'kind      word     AutoKey item             what happens'
printf '  \e[1;36m%s\e[1;33m%s\e[0m%s%s\n' 'phrase    ' ';;it     ' 'text file                ' 'types an issue template'
printf '  \e[1;36m%s\e[1;33m%s\e[0m%s%s\n' 'picker    ' ';;dot    ' 'script ─▶ picker dot     ' 'a menu of dotfiles, then paste'
printf '  \e[1;36m%s\e[1;33m%s\e[0m%s%s\n' 'instant   ' ';;date   ' 'script ─▶ picker date    ' "today's date, pasted at once"
```

<!-- end_slide -->

## From Keys to Value

```bash +exec_replace
just plantuml use-shortcut
```

<!-- end_slide -->

## The Code

> Where does each piece plug in?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## A Trigger Is Two Files

> AutoKey keeps each trigger as its settings and a script to run.

```bash +exec_replace
p="$HOME/dev/dotfiles/.config/autokey/data/My Phrases"
printf '\e[90m%s\e[0m\n' 'My Phrases/.dot_picker.json'
jq -C '{type, omitTrigger} + (.abbreviation | {abbreviations, immediate, backspace})' "$p/.dot_picker.json"
printf '\n\e[90m%s\e[0m\n' 'My Phrases/dot_picker.py'
grep 'Popen' "$p/dot_picker.py" | sed -E 's/(\.sh",) /\1\n                  /' |
	bat -l python --style=plain --color=always --decorations=always
```

<!-- end_slide -->

## The Picker's Interface

> A list name in, a value at the cursor out, and the list says what to paste.

```bash +exec_replace
printf '  \e[36m%s\e[0m\e[90m%s\e[0m\n\n' '__value_picker.sh <list> <letters to erase>' '     run by AutoKey'
printf '  \e[36m%s\e[0m\n' '~/.config/value-sets/<list>'
printf '    \e[33m%s\e[0m%s\n' 'a plain file          ' 'each line is a value'
printf '    \e[33m%s\e[0m%s\n\n' 'a program             ' 'each line it prints is a value'
printf '  \e[90m%s\e[0m\n' 'a line'
printf '    \e[33m%s\e[0m%s\n' 'VALUE                 ' 'pasted as it is'
printf '    \e[33m%s\e[0m%s\n' 'VALUE | label         ' 'the menu shows it all, VALUE is pasted'
printf '    \e[33m%s\e[0m%s\n' 'VALUE<TAB>label       ' 'the menu shows the label, VALUE is pasted'
```

<!-- end_slide -->

## A List Can Be a Program

> A program prints fresh values every time the word is typed.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n\n' '~/.config/value-sets/dot: fd over the dotfiles, a row per file'
"$HOME/.config/value-sets/dot" | grep -m1 'alacritty/alacritty.toml$' |
	awk -F '\t' '{ printf "  \033[36m%-60s\033[90m◀ pasted\n  \033[33m%-60s\033[90m◀ after a tab, shown\033[0m\n", $1, $2 }'
echo
printf '  \e[90m%s\e[0m\n\n' '~/.config/value-sets/date: a single row, so ;;date skips the menu'
"$HOME/.config/value-sets/date" | sed -E 's/^(.*) \| (.*)$/  \x1b[36m\1\x1b[90m | \x1b[33m\2\x1b[0m/'
```

<!-- end_slide -->

## Semicolon Shortcuts

> What does it look like in use?

```bash +exec_replace
./journey.sh 5
```

<!-- end_slide -->

## Two Semicolons and a Word

> Two semicolons, a word and a space open a menu, and the choice is pasted at the cursor.

```bash +exec_replace
./ladder.sh 6
```

```bash +exec_replace
printf '  \e[36m%s\e[1;33m%s\e[0m\n' 'rg -w Paste ' ';;dot␣'
printf '  %s\e[90m%s\e[0m\n' '  │ ' 'typed like any other text'
printf '  %s\n' '  ▼'
printf '  %s\e[1;36m%s\e[0m\n' 'a menu over the window ─▶ ' '> alacritty.toml'
printf '  %s\e[90m%s\e[0m\n' '  │ ' 'Enter'
printf '  %s\n' '  ▼'
printf '  \e[36m%s\e[0m\n' 'rg -w Paste /home/decoder/dev/dotfiles/.config/alacritty/alacritty.toml'
echo
printf '  \e[32m%s\e[0m\n' '✓ Mid-command, with no trip to the clipboard.'
```

```bash +exec +acquire_terminal
/// ./demo.sh shell <<'EOF'
rg -w Paste ;;dot
/// EOF
```

<!-- end_slide -->

## The Value at the Cursor

```bash +exec_replace
printf '  \e[36m%s\e[0m\n' 'Draft'
printf '  %s\e[33m%s\e[0m\n' 'Config file: ' '▌'
printf '               \e[90m│\e[0m  \e[33m%s\e[0m\n' ';;dot␣ → alacritty.toml → Enter'
printf '               \e[90m▼\e[0m\n'
printf '  %s\e[32m%s\e[0m \e[33m▌\e[0m\n' 'Config file: ' '/home/decoder/dev/dotfiles/.config/alacritty/alacritty.toml'
printf '\n  %s\e[33m▌\e[0m\n' 'fzf docs: '
```

<!-- end_slide -->

## Building a Shortcut

> A new shortcut is a list and a word that points the picker at it.

```bash +exec_replace
just plantuml build-shortcut
```

<!-- end_slide -->

## A New List, Live

> Write the list, point a word at it, and the trip to the browser is gone.

```file
path: lists/docs
language: text
```

```bash +exec +acquire_terminal
/// ./demo.sh register
/// ./demo.sh shell <<'EOF'
curl -sI ;;docs
/// EOF
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
printf '  \e[90m%s\e[0m\n' 'in the dotfiles clone'
printf '  \e[35m•\e[0m \e[36m%s\e[0m%s\n' 'scripts/__value_picker.sh       ' 'the picker'
printf '  \e[35m•\e[0m \e[36m%s\e[0m%s\n' 'scripts/__lib_rofi_theme.sh     ' 'its rofi look'
printf '  \e[90m%s\e[0m\n' 'in .config/autokey/data/My Phrases/'
printf '  \e[35m•\e[0m \e[36m%s\e[0m%s\n' '.dot_picker.json                ' 'the trigger word, ;;dot'
printf '  \e[35m•\e[0m \e[36m%s\e[0m%s\n' 'dot_picker.py                   ' 'runs the picker; change its path to the clone'
echo
printf '  \e[1;33m%s\e[0m\n' '▶ First list: one value per line in ~/.config/value-sets/'
```

<!-- end_slide -->

## Takeaways

```bash +exec_replace
printf '  \e[32m%s\e[0m\e[36m%s\e[0m%s\n' '✓ ' 'so what     ' 'the value comes to the cursor, in any X11 app'
printf '  \e[32m%s\e[0m\e[36m%s\e[0m%s\n' '✓ ' 'now what    ' 'a list of values and a word that opens it'
printf '  \e[1;33m%s\e[0m\e[36m%s\e[0m%s\n' '▶ ' 'then what   ' 'a first list for the value that keeps sending you away'
```

<!-- end_slide -->

## Resources

```markdown +no_background
Dotfiles:    https://github.com/Piotr1215/dotfiles
AutoKey:     https://github.com/autokey/autokey
rofi:        https://github.com/davatorium/rofi
fzf:         https://github.com/junegunn/fzf
Channel:     youtube.com/@cloud-native-corner
```

<!-- end_slide -->

# That's All Folks! 👋

```bash +exec_replace
echo "That's all folks!" | figlet -f small -w 84
```
