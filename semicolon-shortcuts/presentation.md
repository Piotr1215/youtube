# Semicolon Shortcuts

> The value at the cursor, in any X11 app, without leaving the keyboard

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

## Values Fetched All Day

> A path, a link or an id lives in one place and is needed in another.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n\n' 'value               lives in             needed in'
printf '  \e[36m%s\e[0m%s\e[33m%s\e[0m\n' 'a file path         ' 'the file tree        ' 'a command, a chat'
printf '  \e[36m%s\e[0m%s\e[33m%s\e[0m\n' 'a project URL       ' 'the browser          ' 'curl, an issue, an email'
printf '  \e[36m%s\e[0m%s\e[33m%s\e[0m\n' 'a ticket id         ' 'the tracker          ' 'a commit message'
printf '  \e[36m%s\e[0m%s\e[33m%s\e[0m\n' "today's date        " 'the clock            ' 'a note, a file name'
echo
printf '  \e[1;33m%s\e[0m\n' 'Each one has to travel from where it lives to the cursor.'
```

<!-- end_slide -->

## Copying with the Mouse

> The path is on screen, so the hand goes to the mouse.

```bash +exec_replace
./ladder.sh 1
```

```bash +exec_replace
{
	printf '  %s\n' 'keys    pwd ⏎ ─▶ /home/decoder/dev/dotfiles'
	printf '  %s\n' '                   │'
	printf '  %s\n' 'mouse              └─▶ drag over it ─▶ copy ─▶ click the target'
	printf '  %s\n' '                                                            │'
	printf '  %s\n' 'keys                                         paste ◀────────┘'
} | sed -E 's/^(  )(keys|mouse)/\1\x1b[90m\2\x1b[0m/; s/(pwd ⏎|paste)/\x1b[36m\1\x1b[0m/'
echo
printf '  \e[32m%s\e[0m\n' '✓ Works in every app.'
printf '  \e[31m%s\e[0m\n' '✗ The hand leaves the keyboard for every value.'
```

```bash +exec
/// ./demo.sh window <<'EOF'
pwd
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
printf '  \e[90m%s\e[0m\n\n' '-g: a global alias, expanded anywhere in the line'
printf '  \e[36m%s\e[0m%s\n' 'pwd C' ' ─▶ pwd | tee ─┬─▶ screen'
printf '  %s\n' '                    └─▶ drop colour codes ─▶ drop the last newline ─▶ clipboard'
echo
printf '  \e[32m%s\e[0m\n' '✓ Copies from the keyboard, no mouse.'
printf '  \e[31m%s\e[0m\n' '✗ Only what a command prints, and each copy replaces the last.'
```

```bash +exec
/// ./demo.sh window <<'EOF'
pwd C
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
printf '  %s\e[36m%s\e[0m%s\n' '                   ' 'Ctrl+Alt+1' ' ─▶ pick ─▶ back on the clipboard'
echo
printf '  \e[32m%s\e[0m\n' '✓ An earlier copy comes back without copying it again.'
printf '  \e[31m%s\e[0m\n' '✗ It only holds what was copied before.'
```

```bash +exec
/// ./demo.sh window <<'EOF'
date C
/// EOF
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
printf '  %s\n' 'this folder           letters in order,             │'
printf '  %s\n' '(or any input)        gaps allowed                  └─▶ xsel ─▶ clipboard'
echo
printf '  \e[32m%s\e[0m\n' '✓ A few letters find a path that was never on screen.'
printf '  \e[31m%s\e[0m\n' '✗ The path is copied. It still needs a paste.'
```

```bash +exec
/// ./demo.sh window <<'EOF'
fzf | xsel --clipboard
/// EOF
```

<!-- end_slide -->

## Breaking the Flow

> What happens halfway through a command?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## A Path at the Cursor

> Ctrl-T opens the same menu mid-command and puts the path at the cursor.

```bash +exec_replace
./ladder.sh 5
```

```bash +exec_replace
printf '  \e[36m%s\e[0m\n' 'nvim ▌'
printf '  %s\e[90m%s\e[0m\n' '  │ ' 'Ctrl-T'
printf '  %s\n' '  ▼'
printf '  %s\e[1;36m%s\e[0m\n' 'fzf over files and folders below here ─▶ ' '> alactoml'
printf '  %s\e[90m%s\e[0m\n' '  │ ' 'Enter'
printf '  %s\n' '  ▼'
printf '  \e[36m%s\e[0m\n' 'nvim .config/alacritty/alacritty.toml'
echo
printf '  \e[32m%s\e[0m\n' '✓ No clipboard and no paste; the command carries on.'
printf '  \e[31m%s\e[0m\n' '✗ Paths from this folder; URLs and ids are still elsewhere.'
```

```bash +exec
/// ./demo.sh window <<'EOF'
nvim
/// EOF
```

<!-- end_slide -->

## The Mid-Command Detour

> When the value is a link, the command waits while the hand fetches it.

```bash +exec_replace
printf '  \e[36m%s\e[0m%s\n' 'curl -sI ▌' ' ─▶ browser ─▶ find the fzf page ─▶ copy the URL'
printf '  %s\n' '   ▲                                                    │'
printf '  %s\n' '   └────────────── back, paste, carry on ───────────────┘'
echo
printf '  \e[31m%s\e[0m\n' '✗ Every value that is not a file is a trip away from the command.'
```

```bash +exec
/// ./demo.sh window <<'EOF'
curl -sI
/// EOF
```

<!-- end_slide -->

## Outside the Terminal

> A chat box or an email has no shell, so most of these stop at the terminal.

```bash +exec_replace
{
	printf '  %s\n\n' 'window      mouse   C alias   history   fzf   Ctrl-T'
	printf '  %s\n' 'terminal      ✓        ✓         ✓       ✓       ✓'
	printf '  %s\n' 'chat app      ✓        ✗         ✓       ✗       ✗'
	printf '  %s\n' 'email         ✓        ✗         ✓       ✗       ✗'
} | sed -E '1s/.*/\x1b[90m&\x1b[0m/; s/^(  )(terminal|chat app|email)/\1\x1b[36m\2\x1b[0m/; s/✓/\x1b[32m✓\x1b[0m/g; s/✗/\x1b[31m✗\x1b[0m/g'
echo
printf '  \e[31m%s\e[0m\n' '✗ Outside the shell, every value goes back to copy and paste.'
```

<!-- end_slide -->

## Semicolon Shortcuts

> What if a menu like fzf worked in every window?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## Two Semicolons and a Word

> Two semicolons, a word and a space open a menu, and the choice is pasted at the cursor.

```bash +exec_replace
./ladder.sh 6
```

```bash +exec_replace
printf '  \e[36m%s\e[0m\n' 'nvim ;;dot␣'
printf '  %s\e[90m%s\e[0m\n' '  │ ' 'typed like any other text'
printf '  %s\n' '  ▼'
printf '  %s\e[1;36m%s\e[0m\n' 'a menu over the window ─▶ ' '> alacritty.toml'
printf '  %s\e[90m%s\e[0m\n' '  │ ' 'Enter'
printf '  %s\n' '  ▼'
printf '  \e[36m%s\e[0m\n' 'nvim /home/decoder/dev/dotfiles/.config/alacritty/alacritty.toml'
echo
printf '  \e[32m%s\e[0m\n' '✓ Mid-command, no clipboard trip, in any X11 app.'
```

```bash +exec
/// ./demo.sh window <<'EOF'
nvim ;;dot
/// EOF
```

<!-- end_slide -->

## In Every Window

> The same menu works in the chat and the email.

```bash +exec_replace
{
	printf '  %s\n\n' 'window      mouse   C alias   history   fzf   Ctrl-T   ;;'
	printf '  %s\n' 'terminal      ✓        ✓         ✓       ✓       ✓     ✓'
	printf '  %s\n' 'chat app      ✓        ✗         ✓       ✗       ✗     ✓'
	printf '  %s\n' 'email         ✓        ✗         ✓       ✗       ✗     ✓'
} | sed -E '1s/.*/\x1b[90m&\x1b[0m/; s/^(  )(terminal|chat app|email)/\1\x1b[36m\2\x1b[0m/; s/✓/\x1b[32m✓\x1b[0m/g; s/✗/\x1b[31m✗\x1b[0m/g'
echo
printf '  \e[32m%s\e[0m\n' '✓ A link never copied lands in the chat and the email too.'
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

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\n' ';;?␣' ' ─▶ every trigger, with what it does ─▶ pick ─▶ it runs'
```

```bash +exec
/// ./demo.sh window <<'EOF'
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

> AutoKey hears the word, a bash script finds the list, rofi asks, and the script pastes.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m\e[90m%s\e[0m\n' ';;dot␣' '  typed in any window'
printf '  %s\n' '   │'
printf '  %s\n' '   ▼'
printf '  \e[1;36m%s\e[0m%s\n' 'AutoKey' ' ──────── watches every key on the X server; on ;;dot␣ it runs'
printf '  %s\e[36m%s\e[0m\n' '   │             ' '__value_picker.sh dot'
printf '  %s\n' '   ▼'
printf '  \e[1;36m%s\e[0m%s\n' 'value picker' ' ─── bash: reads the list named dot in ~/.config/value-sets/'
printf '  %s\n' '   │             a file, or a program that prints the lines'
printf '  %s\n' '   ▼'
printf '  \e[1;36m%s\e[0m%s\n' 'rofi' ' ─────────── a searchable menu over the window, like fzf'
printf '  %s\n' '   │             returns the chosen line'
printf '  %s\n' '   ▼'
printf '  \e[1;36m%s\e[0m%s\n' 'value picker' ' ─── erases ;;dot, pastes the value, puts the clipboard back'
```

<!-- end_slide -->

## Why These Pieces

> Each piece does the one job the others cannot.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n\n' 'piece        job                      why this one'
printf '  \e[1;36m%s\e[0m%s\e[33m%s\e[0m\n' 'AutoKey      ' 'hears ;;word             ' 'sees keys typed in every X11 app'
printf '  \e[1;36m%s\e[0m%s\e[33m%s\e[0m\n' 'rofi         ' 'shows the menu           ' 'fzf needs a terminal; rofi is a window'
printf '  \e[1;36m%s\e[0m%s\e[33m%s\e[0m\n' 'bash         ' 'finds the list, pastes   ' 'a list is a plain file or a program'
```

<!-- end_slide -->

## A List Is a File

> One value per line; the text after the bar is only there to search by.

```file
path: lists/docs
language: text
```

```bash +exec_replace
printf '\e[90m%s\e[0m\n' 'saved as ~/.config/value-sets/docs, opened by ;;docs'
```

<!-- end_slide -->

## A List Can Be a Program

> When the values change, a program prints them fresh each time the menu opens.

```bash +exec_replace
sed -n '/^root=/,/LC_ALL=C sort/p' "$HOME/.config/value-sets/dot" |
	awk 'length > 84 { l = substr($0, 1, 60); sub(/ [^ ]*$/, "", l); print l " … " $NF; next } 1' |
	bat -l bash --style=plain --color=always --decorations=always
echo
"$HOME/.config/value-sets/dot" | head -3 | sed -E 's/\t/  \x1b[90m⇥\x1b[0m  /'
echo
printf '\e[90m%s\e[0m\n' 'value ⇥ label: the menu shows the label and pastes the value'
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

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\e[36m%s\e[0m\n' '1 ' 'write the list       ' '~/.config/value-sets/docs'
printf '  \e[1;33m%s\e[0m%s\e[36m%s\e[0m\n' '2 ' 'point a word at it   ' ';;docs ─▶ __value_picker.sh docs'
```

```bash +exec
/// ./demo.sh register
/// ./demo.sh window <<'EOF'
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
printf '  \e[32m%s\e[0m\e[36m%s\e[0m%s\n' '✓ ' 'so what     ' 'any value lands at the cursor, in any X11 app'
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
echo "That's all folks!" | figlet -f small -w 84
```
