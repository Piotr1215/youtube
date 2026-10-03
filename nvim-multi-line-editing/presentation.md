# Multiline Editing

> Every Neovim way to edit many lines at once, multicursor included

<!-- new_lines: 3 -->

```bash +exec_replace
echo "Multiline Editing" | figlet -f small -w 90
```

<!-- end_slide -->

## Multiline Edits

> Why not just make the edit on each line?

```bash +exec_replace
./journey.sh 1
```

<!-- end_slide -->

## Multi Line Editing

> The mechanisms this video covers, in order.

```bash +exec_replace
m() { printf '  \e[1;%sm%s\e[0m%s\e[90m%s\e[0m\n' "$1" "$2" "$3" "$4"; }
m 32 'CTRL-V  I  A     ' 'visual block        ' 'type into a column of rows'
m 36 ':%norm           ' 'normal on a range   ' 'run keys on every line'
m 36 ':g/pat/cmd       ' 'global command      ' 'run cmd on matching lines; :v on the rest'
m 36 ':g/pat/.!cmd     ' 'mix them            ' 'run a CLI on those lines only'
printf '  \e[1;36m%s\e[0m%s\e[90m%s\e[1;33m%s\e[0m\n' ':%s/\v           ' 'substitution        ' 'rewrite every match of a ' 'regex'
m 36 ':%!              ' 'external commands   ' 'pass lines through any CLI on your system'
m 36 'q  @             ' 'macros              ' 'record an edit, replay it'
m 32 'Q                ' 'multicursor         ' 'type once at every cursor'
m 32 ':g/pat/norm! nQ  ' 'mix them            ' 'a cursor on every match, then @q or keys'
printf '\n'
o() { printf '  \e[90m%s\e[0m\e[36m%s\e[0m\n' "$1" "$2"; }
o 'also             ' ':%luado   :s with \=expr'
o 'across files     ' ':cdo   :argdo   :bufdo'
printf '\n\e[33m%s\e[0m\n' 'Multicursor is the newest, and it mixes with most of the above.'
```

<!-- end_slide -->

## Basic Concepts

> What does every multiline edit need?

```bash +exec_replace
./journey.sh 2
```

<!-- end_slide -->

## Targets and Edit

> Every multiline edit answers two questions.

```bash +exec_replace
printf '  \e[36m%s\e[0m%s\n' 'where   ' 'the targets: lines, search matches, spots you pick'
printf '  \e[33m%s\e[0m%s\n\n' 'what    ' 'the edit: keys, a command, a substitution'
printf '\e[37m%s\e[0m\n' 'Each method in this video is one pair of answers.'
```

<!-- end_slide -->

## Method Families

> Describe the edit and run it, or make it on screen and watch it land.

```bash +exec_replace
printf '  \e[36m%s\e[0m\e[32m%s\e[0m\n' 'command methods                ' 'cursor methods'
printf '  \e[90m%s\e[0m\e[90m%s\e[0m\n' 'describe, then run             ' 'edit on screen, live'
printf '  %s%s\n' ':norm  :g  :v  :s  :!  macro   ' 'visual block  multicursor'
printf '  \e[90m%s\e[0m\e[90m%s\e[0m\n\n' 'you see the result             ' 'you see every key land'
printf '\e[33m%s\e[0m\n' ':g/pat/normal! Q joins them: a command picks, you type.'
```

<!-- end_slide -->

## Methods

> How does each method edit many lines?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## Visual Block

> CTRL-V selects a rectangle; I or A types into every row of it.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\n' 'CTRL-V  G  I  -␣  Esc     ' 'insert before the column'
printf '  \e[1;33m%s\e[0m%s\n\n' 'CTRL-V  G  $  A  ;  Esc   ' 'append at every line end'
printf '  \e[30;46m%s\e[0m%s\e[30;46m%s\e[0m\n' '- ' 'Buy milk' ';'
printf '  \e[30;46m%s\e[0m%s\e[30;46m%s\e[0m\n' '- ' 'Call the dentist tomorrow morning' ';'
printf '  \e[30;46m%s\e[0m%s\e[30;46m%s\e[0m\n\n' '- ' 'Fix bug' ';'
printf '  \e[32m%s\e[0m%s\n' '✓ ' 'the same column on every line'
printf '  \e[31m%s\e[0m%s\n' '✗ ' 'targets that move from line to line'
```

<!-- end_slide -->

## Normal on a Range

> :norm runs normal-mode keys on each line of a range.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m\n' ':%norm xf]D'
printf '  \e[90m%s\e[0m%s\n' ' │     ││ └─ ' 'D    delete to the end'
printf '  \e[90m%s\e[0m%s\n' ' │     │└─── ' 'f]   jump to the ]'
printf '  \e[90m%s\e[0m%s\n' ' │     └──── ' 'x    delete the ['
printf '  \e[90m%s\e[0m%s\n\n' ' └────────── ' '%    every line'
printf '  \e[32m%s\e[0m%s\n' '✓ ' "motions like f] find each line's own target"
printf '  \e[31m%s\e[0m%s\n' '✗ ' 'you see only the result, not the keys land'
```

<!-- end_slide -->

## Global Command

> :g and :v pick lines by a condition.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\n' ':g/pattern/cmd           ' 'run cmd on lines that match'
printf '  \e[1;33m%s\e[0m%s\n' ':v/pattern/cmd           ' 'run cmd on lines that do not'
printf '  \e[36m%s\e[0m%s\n' ':v/:/s/^/[ok]␣           ' 'prefix every line without a colon'
printf '  \e[36m%s\e[0m%s\n\n' ':g/error/.!tr a-z A-Z    ' 'run a CLI on matching lines only'
printf '  \e[32m%s\e[0m%s\n' '✓ ' 'targets picked by a condition, anywhere in the file'
printf '  \e[31m%s\e[0m%s\n' '✗ ' 'it picks lines; spots inside a line need :s or :norm'
```

<!-- end_slide -->

## Substitution

> :s rewrites every match of a regex.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m\n\n' ':%s/\v_(.)/\u\1/g'
printf '  \e[36m%s\e[0m%s\n' '\v         ' 'very magic: ( ) group without backslashes'
printf '  \e[36m%s\e[0m%s\n' '_(.)       ' 'an underscore and the letter after it'
printf '  \e[36m%s\e[0m%s\n' '\u\1       ' 'that letter, uppercased'
printf '  \e[36m%s\e[0m%s\n\n' 'g          ' 'every match on the line'
printf '  \e[32m%s\e[0m%s\n' '✓ ' 'regex groups and case changes, every match at once'
printf '  \e[31m%s\e[0m%s\n' '✗ ' 'a long regex is hard to write and to read back'
```

<!-- end_slide -->

## External Commands

> :{range}!cmd passes lines through any CLI on your system.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\n' ':%!sort -u          ' 'sort the lines, drop duplicates'
printf '  \e[1;33m%s\e[0m%s\n' ":'<,'>!column -t    " 'align the selection into columns'
printf '  \e[1;33m%s\e[0m%s\n\n' ':%!jq .             ' 'pretty-print JSON'
printf '  \e[32m%s\e[0m%s\n' '✓ ' 'any tool that reads stdin and writes stdout becomes an edit'
printf '  \e[31m%s\e[0m%s\n' '✗ ' 'only as portable as the tools on the machine'
```

<!-- end_slide -->

## Macros

> Record an edit once, replay it anywhere.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\n' 'qq … +q            ' 'record the edit, end on the next line'
printf '  \e[1;33m%s\e[0m%s\n' '4@q                ' 'replay it four times'
printf '  \e[1;33m%s\e[0m%s\n\n' '"qp                ' 'paste the macro as text to fix it'
printf '  \e[32m%s\e[0m%s\n' '✓ ' 'saved in a register, ready for later in any file'
printf '  \e[31m%s\e[0m%s\n' '✗ ' 'raw keys: a slip in the recording replays everywhere'
```

<!-- end_slide -->

## Multicursor

> Q places cursors; every edit lands at each one as you type.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\n' '{Visual}Q              ' 'a cursor on each selected line'
printf '  \e[1;33m%s\e[0m%s\n' '[count]Q               ' 'a cursor on every search match'
printf '  \e[1;33m%s\e[0m%s\n' ':g/pattern/normal! nQ  ' 'a cursor on every match, by condition'
printf '  \e[1;33m%s\e[0m%s\n' ':cdo normal! Q         ' 'a cursor at each quickfix item'
printf '  \e[1;33m%s\e[0m%s\n\n' '@q                     ' 'the macro replays at every cursor'
printf '  \e[32m%s\e[0m%s\n' '✓ ' 'you watch every edit land, with one undo for all'
printf '  \e[31m%s\e[0m%s\n' '✗ ' 'a cursor whose edit cannot start, like ct; with no ;, is removed'
```

<!-- end_slide -->

## Choosing a Method

> Which method fits which edit?

```bash +exec_replace
./journey.sh 4
```
<!-- end_slide -->

## Rule of Thumb

> Ask from the top; the first yes picks the method.

```bash +exec_replace
q() { printf '  %s\e[90m%s\e[0m\e[%sm%s\e[0m\n' "$1" ' ──▶ ' "$2" "$3"; }
q 'A job a CLI tool already does?            ' 36 ':%!  external commands'
q 'Across files, or too many lines to watch? ' 36 ':s  :norm  with :cdo'
q 'An edit you will replay later?            ' 36 'macro'
q 'One column on adjacent lines?             ' 32 'visual block'
q 'Lines picked by a pattern?                ' 36 ':g  :v'
q 'One fixed string swapped for another?     ' 36 ':s'
q 'Anything else on screen                   ' 32 'multicursor'
```
<!-- end_slide -->

## Rules in Play

> Three exercises, the ledger counting keys: each rule picks the winner.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n' 'exercise              rule'
printf '  \e[36m%s\e[0m%s\n' 'add prefix            ' 'one column on adjacent lines'
printf '  \e[36m%s\e[0m%s\n' 'flip assignment       ' 'anything else on screen'
printf '  \e[36m%s\e[0m%s\n' 'conditional prefix    ' 'lines picked by a pattern'
```

```bash +exec
./demo.sh
```
<!-- end_slide -->

## Scoreboard

> Keys typed for each exercise: the shortest other method found, and multicursor.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n' 'exercise             other method       multicursor'
row() { if (($2 < $4)); then w=32 m=90; else w=90 m=32; fi; printf '  %s\e[%sm%3d  %s\e[0m\e[%sm%3d\e[0m\n' "$1" "$w" "$2" "$3" "$m" "$4"; }
row '01 add prefix       ' 6 'visual block     ' 7
row '02 log levels       ' 11 'macro            ' 7
row '03 bracket quotes   ' 13 'macro            ' 9
row '04 first field      ' 8 ':s               ' 6
row '05 semicolons       ' 8 ':s               ' 6
row '06 wrap parens      ' 14 'macro            ' 10
row '07 flip assignment  ' 16 'macro            ' 12
row '08 cond prefix      ' 15 ':v               ' 16
row '09 snake to camel   ' 18 ':s               ' 7
printf '\n\e[33m%s\e[0m\n' 'Multicursor wins on-screen edits; a column or a condition favors the classics.'
```
<!-- end_slide -->

## What's Next

> How do you try it today?

```bash +exec_replace
./journey.sh 5
```
<!-- end_slide -->

## First Steps

> Grab a nightly build and try it on the exercises.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\n' 'nightly         ' 'github.com/neovim/neovim/releases/tag/nightly'
printf '  \e[1;33m%s\e[0m%s\n' ':help mcursor   ' 'every key, with examples'
printf '  \e[1;33m%s\e[0m%s\n' './exercises.sh  ' 'nine exercises, each checked against its goal'
```
<!-- end_slide -->

## Takeaways

```bash +exec_replace
printf '  \e[32m%s\e[0m\e[36m%s\e[0m%s\n' '✓ ' 'multicursor     ' 'the newest method: it replays commands at every cursor'
printf '  \e[32m%s\e[0m\e[36m%s\e[0m%s\n' '✓ ' 'rule of thumb   ' 'tools, files, reuse, columns, patterns, fixed strings first'
printf '  \e[1;33m%s\e[0m\e[36m%s\e[0m%s\n' '▶ ' 'next            ' 'install a nightly, press VGQ, run the exercises'
```

<!-- end_slide -->

## Resources

```markdown
Pull request:   github.com/neovim/neovim/pull/41587
Help:           :help mcursor
Blog post:      blog.olimorris.com/2026/09/02/multiple-cursors-in-neovim-0.13
```

<!-- end_slide -->

# That's All Folks! 👋

```bash +exec_replace
just intro_toilet That\'s all folks!
```
