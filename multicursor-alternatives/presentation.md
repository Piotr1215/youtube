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

## Edit Loop

> The same small change, line after line.

```bash +exec_replace
printf '  \e[36m%s\e[90m%s\e[36m%s\e[90m%s\e[1;33m%s\e[0m\n' 'find the spot' ' ──▶ ' 'make the edit' ' ──▶ ' 'next line'
printf '  \e[90m%s\e[0m\n' '▲                                         │'
printf '  \e[90m%s\e[0m\n\n' '└─────────────────────────────────────────┘'
printf '\e[33m%s\e[0m\n' 'Every extra line is another trip around the loop.'
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

## Vim Grammar

> A motion finds its own target on every line.

```bash +exec_replace
printf '  %s\n' '[INFO] server started on port 8080'
printf '  \e[1;33m%s\e[0m\e[90m%s\e[0m\n' '     ▲' ' f] stops here'
printf '  %s\n' '[ERROR 503] connection failed: timeout after 30s'
printf '  \e[1;33m%s\e[0m\e[90m%s\e[0m\n\n' '          ▲' ' f] stops here'
printf '\e[33m%s\e[0m\n' 'Replay f] on each line and it finds that line'"'"'s own bracket.'
```

<!-- end_slide -->

## Method Families

> Describe the edit and run it, or make it on screen and watch it land.

```bash +exec_replace
printf '  \e[36m%s\e[0m\e[32m%s\e[0m\n' 'command methods            ' 'cursor methods'
printf '  \e[90m%s\e[0m\e[90m%s\e[0m\n' 'describe, then run         ' 'edit on screen, live'
printf '  %s%s\n' ':norm  :g  :v  :s  macro   ' 'visual block  multicursor'
printf '  \e[90m%s\e[0m\e[90m%s\e[0m\n\n' 'you see the result         ' 'you see every key land'
printf '\e[33m%s\e[0m\n' ':g/pat/normal! Q joins them: a command picks, you type.'
```

<!-- end_slide -->

## Classic Methods

> How did Neovim edit many lines before multicursor?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## Visual Block

> CTRL-V selects a rectangle; I types into every row of it.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m\n\n' 'CTRL-V  G  I  -␣  Esc'
printf '  \e[30;46m%s\e[0m%s\n' '- ' 'Buy milk'
printf '  \e[30;46m%s\e[0m%s\n' '- ' 'Call the dentist tomorrow morning'
printf '  \e[30;46m%s\e[0m%s\n\n' '- ' 'Fix bug'
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
printf '\e[37m%s\e[0m\n' 'You type it once on the command line and see only the result.'
```

<!-- end_slide -->

## Global Command

> :g and :v pick lines by a condition.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\n' ':g/pattern/cmd       ' 'run cmd on lines that match'
printf '  \e[1;33m%s\e[0m%s\n\n' ':v/pattern/cmd       ' 'run cmd on lines that do not'
printf '  \e[36m%s\e[0m%s\n\n' ':v/:/s/^/[ok]␣       ' 'prefix every line without a colon'
printf '\e[37m%s\e[0m\n' 'The target is a condition, not a place on screen.'
```

<!-- end_slide -->

## Substitution

> :s rewrites every match of a pattern.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m\n\n' ':%s/\v_(.)/\u\1/g'
printf '  \e[36m%s\e[0m%s\n' '\v         ' 'very magic: ( ) group without backslashes'
printf '  \e[36m%s\e[0m%s\n' '_(.)       ' 'an underscore and the letter after it'
printf '  \e[36m%s\e[0m%s\n' '\u\1       ' 'that letter, uppercased'
printf '  \e[36m%s\e[0m%s\n\n' 'g          ' 'every match on the line'
printf '\e[37m%s\e[0m\n' 'Case changes, expressions, and many files with :cdo or :argdo.'
```

<!-- end_slide -->

## Macros

> Record an edit once, replay it anywhere.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\n' 'qq … +q            ' 'record the edit, end on the next line'
printf '  \e[1;33m%s\e[0m%s\n' '4@q                ' 'replay it four times'
printf '  \e[1;33m%s\e[0m%s\n\n' '"qp                ' 'paste the macro as text to fix it'
printf '\e[37m%s\e[0m\n' 'The register keeps the macro for later, in any file.'
```

<!-- end_slide -->

## Multicursor

> How does the newest method work?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## Placing Cursors

> Q adds cursors from a selection, a search, or where you stand.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\n' '{Visual}Q          ' 'a cursor on each selected line'
printf '  \e[1;33m%s\e[0m%s\n' 'Q                  ' 'toggle a cursor where you stand'
printf '  \e[1;33m%s\e[0m%s\n' '[count]Q           ' 'a cursor on every search match'
printf '  \e[1;33m%s\e[0m%s\n\n' 'CTRL-click         ' 'add one with the mouse'
printf '\e[37m%s\e[0m\n' 'Then type: the edit lands at every cursor as you go.'
```

<!-- end_slide -->

## Scripted Placement

> Q is a normal command, so any Ex command can place cursors.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\n' ':g/pat/normal! nQ         ' 'on every match'
printf '  \e[1;33m%s\e[0m%s\n' ':g/ERROR/normal! f]Q      ' 'after the ] on ERROR lines only'
printf '  \e[1;33m%s\e[0m%s\n' ':v/:/normal! Q            ' 'on lines without a colon'
printf '  \e[1;33m%s\e[0m%s\n' ':cdo normal! Q            ' 'at each quickfix item'
printf '  \e[1;33m%s\e[0m%s\n\n' 'nvim_mcursor(0, {r, c})   ' 'anywhere, from Lua'
printf '\e[33m%s\e[0m\n' 'A command picks the spots; you type the edit live.'
```

<!-- end_slide -->

## Command Replay

> Neovim replays the command at each cursor, not the raw keys.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n' 'typed once          runs at every cursor'
printf '  \e[1;33m%s\e[90m%s\e[0m%s\n' 'f]                ' ' ──▶ ' "each line's own ]"
printf '  \e[1;33m%s\e[90m%s\e[0m%s\n' 'dt=               ' ' ──▶ ' "each line's own text, cut to its own register"
printf '  \e[1;33m%s\e[90m%s\e[0m%s\n' '@q                ' ' ──▶ ' 'the whole macro'
printf '  \e[1;33m%s\e[90m%s\e[0m%s\n' 'u                 ' ' ──▶ ' 'one undo for every cursor'
```

<!-- end_slide -->

## Per-Cursor Registers

> Each cursor yanks and pastes its own text.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n' 'VGQ  dt=  A=<Esc>  p  0x'
printf '  %s\e[90m%s\e[0m\e[32m%s\e[0m\n' 'name=john   ' '  ──▶  ' 'john=name'
printf '  %s\e[90m%s\e[0m\e[32m%s\e[0m\n' 'age=30      ' '  ──▶  ' '30=age'
printf '  %s\e[90m%s\e[0m\e[32m%s\e[0m\n\n' 'city=london ' '  ──▶  ' 'london=city'
printf '\e[37m%s\e[0m\n' 'On clear, the yanks join into one register, a line each.'
```

<!-- end_slide -->

## Session Keys

> A few more keys work while cursors are active.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m%s\n' 'q=          ' 'follow mode: motions move every cursor'
printf '  \e[1;33m%s\e[0m%s\n' 'CTRL-L      ' 'clear the cursors'
printf '  \e[1;33m%s\e[0m%s\n' 'gQ          ' 'bring the last cursors back'
printf '  \e[1;33m%s\e[0m%s\n' ']C  [C      ' 'jump to the next or previous cursor'
printf '  \e[1;33m%s\e[0m%s\n' 'g CTRL-A    ' 'number the cursors 1, 2, 3'
printf '  \e[1;33m%s\e[0m%s\n\n' 'u           ' 'undo the last edit at every cursor'
printf '\e[90m%s\e[0m\n' 'CTRL-L taken? Map a key to clear the nvim.multicursor namespace.'
```

<!-- end_slide -->

## Limits

> From :help mcursor-limitations and the cursor rules.

```bash +exec_replace
printf '  \e[31m%s\e[0m%s\n' '✗ ' 'cursors live in one buffer; many files still need :cdo'
printf '  \e[31m%s\e[0m%s\n' '✗ ' 'Q does nothing while a macro records or runs'
printf '  \e[31m%s\e[0m%s\n' '✗ ' '"+ and "* are shared, not per cursor'
printf '  \e[31m%s\e[0m%s\n' '✗ ' 'g-, g+ and :earlier clear every cursor'
printf '  \e[31m%s\e[0m%s\n' '✗ ' 'nightly only, until Neovim 0.13 ships'
```
<!-- end_slide -->

## Choosing a Method

> Which method fits which edit?

```bash +exec_replace
./journey.sh 5
```
<!-- end_slide -->

## Rule of Thumb

> Ask from the top; the first yes picks the method.

```bash +exec_replace
q() { printf '  %s\e[90m%s\e[0m\e[%sm%s\e[0m\n' "$1" ' ──▶ ' "$2" "$3"; }
q 'Across files, or too many lines to watch? ' 36 ':s  :norm  with :cdo'
q 'An edit you will replay later?            ' 36 'macro'
q 'One column on adjacent lines?             ' 36 'visual block'
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

## Getting Started

> How do you try it today?

```bash +exec_replace
./journey.sh 6
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
printf '  \e[32m%s\e[0m\e[36m%s\e[0m%s\n' '✓ ' 'rule of thumb   ' 'files, reuse, columns, line filters, fixed strings first'
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
