# tmux Pane Regex

> Paste the scrollback text you want by typing a few of its words

<!-- new_lines: 3 -->

```bash +exec_replace
echo "Pane Regex" | figlet -f small -w 90
```

<!-- end_slide -->

## Keyboard First

> Why keep your hands on the keyboard at all?

```bash +exec_replace
./journey.sh 1
```

<!-- end_slide -->

## Terminal Loop

> Most terminal work feeds one command's output into the next.

```bash +exec_replace
printf '  \e[36m%s\e[90m%s\e[36m%s\e[90m%s\e[1;33m%s\e[90m%s\e[36m%s\e[0m\n' 'run a command' ' ──▶ ' 'read the output' ' ──▶ ' 'reuse a piece of it' ' ──▶ ' 'next command'
printf '  \e[90m%s\e[0m\n' '      ▲                                                             │'
printf '  \e[90m%s\e[0m\n\n' '      └─────────────────────────────────────────────────────────────┘'
printf '\e[33m%s\e[0m\n' 'The reuse step is where the hand leaves the keyboard for the mouse.'
```

<!-- end_slide -->

## Text on Screen

> The text you need next is already on screen.

```bash +exec_replace
printf '\e[90m%s\e[0m\n' '╭─ terminal ──────────────────────────────────────────────────────────────────'
printf '\e[90m│\e[0m %s\n' 'NAME                              READY   STATUS'
printf '\e[90m│\e[0m \e[30;43m%s\e[0m%s\n' 'checkout-worker-5c6b7f9d8-m4n7z' '   0/1     CrashLoopBackOff'
printf '\e[90m│\e[0m %s\e[30;43m%s\e[0m%s\n' 'ERROR giving up: dial tcp ' '10.96.14.7:5432' ': connect: connection refused'
printf '\e[90m│\e[0m %s\e[30;43m%s\e[0m\n' 'runbook: ' 'https://github.com/acme/checkout-worker/blob/main/docs/runbook.md'
printf '\e[90m│\e[0m \e[1;37m%s\e[0m\e[90m%s\e[0m\n' '$ kubectl logs ▌' '                 ← the pod name is up there'
printf '\e[90m%s\e[0m\n\n' '╰─────────────────────────────────────────────────────────────────────────────'
printf '\e[33m%s\e[0m\n' 'Getting it to the prompt without leaving the keyboard is the slow part.'
```

<!-- end_slide -->

## First Look

> Type a few words from the text, and it lands at your prompt.

```bash +exec
./demo.sh teaser
```

<!-- end_slide -->

## Basic Concepts

> How do tmux and your terminal hold and move text?

```bash +exec_replace
./journey.sh 2
```

<!-- end_slide -->

## Scrollback Buffer

```bash +exec_replace
printf '\e[90m%s\e[0m\n' '╭─ scrollback: scrolled away, still in memory ────────────────────────'
printf '\e[90m│\e[0m %s\n' '$ kubectl get pods -n payments'
printf '\e[90m│\e[0m %s\n' 'checkout-worker-5c6b7f9d8-m4n7z   0/1   CrashLoopBackOff'
printf '\e[90m│\e[0m %s\n' 'ERROR giving up: dial tcp 10.96.14.7:5432'
printf '\e[36m%s\e[0m\n' '├─ screen ────────────────────────────────────────────────────────────'
printf '\e[36m│\e[0m \e[1;37m%s\e[0m\n' '$ kubectl get events -n payments'
printf '\e[36m│\e[0m \e[1;37m%s\e[0m\n' '4m   Normal   Sync   configmap/checkout-worker-config'
printf '\e[36m│\e[0m \e[1;37m%s\e[0m\n' '$ ▌'
printf '\e[36m%s\e[0m\n\n' '╰─────────────────────────────────────────────────────────────────────'
printf '  \e[36m%s\e[0m%s\n' 'shell history   ' 'the commands you typed'
printf '  \e[32m%s\e[0m%s\n' 'scrollback      ' 'everything they printed, 2000 lines by default'
```

> Tip: `set -g mouse on` and the wheel scrolls straight into history.

<!-- end_slide -->

## Soft Wraps

> tmux keeps a long line whole; the terminal only sees rows.

```bash +exec_replace
printf '\e[36m%s\e[0m\n' '╭─ tmux stores one line ────────────────────────────────────────────────────────'
printf '\e[36m│\e[0m %s\n' '$ helm upgrade --install checkout-worker ./charts/checkout-worker -n payments'
printf '\e[36m%s\e[0m\n\n' '╰───────────────────────────────────────────────────────────────────────────────'
printf '\e[90m%s\e[0m\n' '╭─ the terminal draws rows ─────────────'
printf '\e[90m│\e[0m %s\e[31m%s\e[0m\n' '$ helm upgrade --install checkout-wo' ' ⏎'
printf '\e[90m│\e[0m %s\e[31m%s\e[0m\n' 'rker ./charts/checkout-worker -n pay' ' ⏎'
printf '\e[90m│\e[0m %s\n' 'ments'
printf '\e[90m%s\e[0m\n\n' '╰───────────────────────────────────────'
printf '  \e[31m%s\e[0m %s\n' '✗' 'a mouse drag copies rows, with stray line breaks'
printf '  \e[32m%s\e[0m %s\n' '✓' 'copy mode and pane regex copy the line'
```

<!-- end_slide -->

## Copy Mode

> A cursor you steer through history.

```bash +exec_replace
printf '  \e[1;33m%s\e[90m%s\e[1;33m%s\e[90m%s\e[1;33m%s\e[90m%s\e[1;33m%s\e[90m%s\e[1;33m%s\e[90m%s\e[1;33m%s\e[0m\n' 'prefix [' ' ─▶ ' '?ERROR' ' ─▶ ' 'Space' ' ─▶ ' 'E E E E E E h' ' ─▶ ' 'Enter' ' ─▶ ' 'prefix ]'
printf '  \e[90m%s\e[0m\n\n' 'enter       search    select   steer            copy     paste'
printf '  \e[32m%s\e[0m %s\n' '✓' 'precise, and a wrapped line copies as one line'
printf '  \e[31m%s\e[0m %s\n' '✗' 'you steer to words you already know'
```

```bash +exec
./demo.sh copy-mode
```

<!-- end_slide -->

## Escape Sequences

> Messages between a program and its terminal

```bash +exec_replace
printf '  \e[36m%s\e[0m%s\n' 'CSI  ' 'Control Sequence Introducer: ESC ['
printf '  \e[36m%s\e[0m%s\n\n' 'OSC  ' 'Operating System Command:    ESC ]'
printf '  \e[1;33m%s\e[0m%s\e[90m%s\e[0m\n' 'ESC[?2004h            ' '"wrap my pastes"              ' 'shell → tmux'
printf '  \e[1;33m%s\e[0m%s\e[90m%s\e[0m\n' 'ESC[200~ … ESC[201~   ' '"this was pasted, not typed"  ' 'tmux → shell'
printf '  \e[1;33m%s\e[0m%s\e[90m%s\e[0m\n\n' 'ESC]52;c;…            ' '"copy this to clipboard"      ' 'tmux → terminal'
printf '\e[37m%s\e[0m\n' 'The program sends these, the terminal acts on them.'
printf '\e[90m%s\e[0m\n' 'More on escape sequences: the Neovim Terminal video.'
```

<!-- end_slide -->

## Built-in Shortcomings

> Why aren't the mouse and copy mode enough?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## Existing Options

> Most text worth reusing is command output.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n\n' 'method             cost'
printf '  \e[36m%s\e[0m\e[31m%s\e[0m %s\n' 'mouse drag       ' '✗' 'wrapped lines paste with stray line breaks'
printf '  \e[36m%s\e[0m\e[31m%s\e[0m %s\n' 'copy mode        ' '✗' 'steering a cursor to text you can already see'
printf '  \e[36m%s\e[0m\e[31m%s\e[0m %s\n\n' 'shell history    ' '✗' 'has the command, never its output'
printf '  \e[1;32m%s\e[0m\e[32m%s %s\e[0m\n' 'pane regex       ' '✓' 'type a few words of what you want, paste'
```

<!-- end_slide -->

## Pane Regex

> How do you grab text by describing it?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## Landmark Query

> Press `prefix + R`, type words from the text you want, and tmux paints the match in the pane.

```bash +exec_replace
printf '\e[90m%s\e[0m\n' "╭─ pane regex ─────────────────────────────────────────────────────────────"
printf '\e[90m│\e[0m \e[1;36m%s\e[0m\e[37m%s\e[0m\n' "regex> " '^ERROR.*5432'
printf '\e[90m│\e[0m \e[90m%s\e[0m\n' 'Up/Down older/newer  Enter/Tab paste  Ctrl-Y copy  Esc cancel'
printf '\e[90m│\e[0m \e[90m%s\e[0m\n' '.*word\2 2nd word  \2t stop before  \3f, 3rd comma  \zs \ze trim'
printf '\e[90m│\e[0m \e[90m%s\e[0m\n' '$$ line end  \l line  \p paragraph  \ss sentence  \u url  \C case'
printf '\e[90m%s\e[0m\n\n' "╰──────────────────────────────────────────────────────────────────────────"
printf '\e[37m%s\e[0m\n' '2026-09-27T08:14:12Z WARN  connection refused, retry 2 of 3'
printf '\e[37m%s\e[0m\n' '2026-09-27T08:14:17Z WARN  connection refused, retry 3 of 3'
printf '\e[37m%s\e[30;43m%s\e[0m\e[37m%s\e[0m\n' '2026-09-27T08:14:17Z ' 'ERROR giving up: dial tcp 10.96.14.7:5432' ': connect: connection refused'
printf '\e[37m%s\e[0m\n' '2026-09-27T08:14:17Z INFO  runbook: https://github.com/acme/checkout-worker/...'
```

<!-- end_slide -->

## Feedback in the Pane

> The popup holds the question, the pane holds the answer.

```bash +exec_replace
printf '\e[90m%s\e[0m\e[36m%s\e[0m\n' '╭─ pane regex ─────────────────────────────────────── ' 'floating window · tmux 3.7b+'
printf '\e[90m│\e[0m \e[1;36m%s\e[0m%s\n' 'regex> ' '^ERROR.*5432▌'
printf '\e[90m%s\e[0m\n\n' '╰─────────────────────────────────────────────────────────────────────────────────'
printf '  \e[33m%s\e[0m\e[30;43m%s\e[0m\n' '^ERROR          ' '08:14:17Z ERROR giving up: dial tcp 10.96.14.7:5432: connect …'
printf '  \e[33m%s\e[0m%s\e[30;43m%s\e[0m%s\n' '^ERROR.*5       ' '08:14:17Z ' 'ERROR giving up: dial tcp 10.96.14.7:5' '432: connect …'
printf '  \e[33m%s\e[0m%s\e[30;43m%s\e[0m%s\n\n' '^ERROR.*5432    ' '08:14:17Z ' 'ERROR giving up: dial tcp 10.96.14.7:5432' ': connect …'
printf '\e[32m%s\e[0m\n' 'Every keystroke repaints the selection in the pane itself.'
```

<!-- end_slide -->

## Vim Atoms

> The query borrows vim motions to grab exactly the span you want.

```bash +exec_replace
printf '  \e[90m%s\e[0m%s\n' 'grep          ' 'every line that matches a pattern'
printf '  \e[1;32m%s\e[0m\e[32m%s\e[0m\n\n' 'pane regex    ' 'the exact span you want, like a vim motion'
printf '  \e[90m%s\e[0m\n' 'vim         query       grabs'
printf '  \e[35m%s\e[1;33m%s\e[0m%s\n' '3t,         ' '\3t,        ' 'stop before the 3rd comma'
printf '  \e[35m%s\e[1;33m%s\e[0m%s\n' '2f.         ' '\2f.        ' 'through the 2nd period'
printf '  \e[35m%s\e[1;33m%s\e[0m%s\n' '\zs \ze     ' '\zs \ze     ' 'only part of the match'
printf '  \e[35m%s\e[1;33m%s\e[0m%s\n' 'V  vip      ' '\l  \p      ' 'the line, the paragraph'
printf '  \e[35m%s\e[1;33m%s\e[0m%s\n' '$           ' '$$          ' 'to the end of the line'
printf '  \e[35m%s\e[1;33m%s\e[0m%s\n' '\C          ' '\C          ' 'match case'
printf '  \e[35m%s\e[1;33m%s\e[0m%s\n' '            ' '\ss         ' 'to the end of the sentence'
printf '  \e[35m%s\e[1;33m%s\e[0m%s\n' '            ' '\u          ' 'the newest URL'
```

```bash +exec
./demo.sh atoms
```

<!-- end_slide -->

## Under the Hood

> How do a few typed words turn into a paste?

```bash +exec_replace
./journey.sh 5
```

<!-- end_slide -->

## Pipeline

> Each query paints the match in the pane and fills a paste buffer.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m\e[90m%s\e[0m\n' '^ERROR.*5432        ' 'typed in the picker'
printf '  \e[90m%s\e[0m\n' '    ▼'
printf '  \e[36m%s\e[0m\e[90m%s\e[0m\n' 'capture-pane -J     ' 'the whole history, wrapped lines joined'
printf '  \e[90m%s\e[0m\n' '    ▼'
printf '  \e[36m%s\e[0m\e[90m%s\e[0m\n' 'strip margins       ' 'prompt glyphs and agent bullets removed'
printf '  \e[90m%s\e[0m\n' '    ▼'
printf '  \e[36m%s\e[0m\e[90m%s\e[0m\n' 'Python re           ' 'picks the exact range'
printf '  \e[90m%s\e[0m\n' '    │'
printf '  \e[90m%s\e[0m\e[32m%s\e[0m\n' '    ├──▶ ' 'tmux search paints it in the pane'
printf '  \e[90m%s\e[0m\e[32m%s\e[0m\n' '    ├──▶ ' 'Enter    bracketed paste at the prompt'
printf '  \e[90m%s\e[0m\e[32m%s\e[0m\n' '    └──▶ ' 'Ctrl-Y   clipboard through OSC 52'
```

<!-- end_slide -->

## Python Regex

> tmux search speaks POSIX regex: greedy, one line at a time.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n\n' '^ERROR.*5432 on a line that holds 5432 twice'
printf '  \e[36m%s\e[0m\e[30;41m%s\e[0m   \e[31m%s\e[0m\n' 'tmux search   ' 'ERROR ··· 5432 ··· 5432' 'greedy: runs to the last one'
printf '  \e[36m%s\e[0m\e[30;42m%s\e[0m\e[90m%s\e[0m   \e[32m%s\e[0m\n\n' 'Python re     ' 'ERROR ··· 5432' ' ··· 5432' 'lazy: stops at the first'
printf '  \e[90m%s\e[0m\n' '                      tmux search   Python re'
printf '  %s\e[31m%s\e[0m%s\e[32m%s\e[0m\n' 'stop at the first end      ' '✗' '            ' '✓'
printf '  %s\e[31m%s\e[0m%s\e[32m%s\e[0m\n' 'span several lines         ' '✗' '            ' '✓'
printf '  %s\e[31m%s\e[0m%s\e[32m%s\e[0m\n\n' 'trim with groups           ' '✗' '            ' '✓'
printf '\e[32m%s\e[0m\n' 'Python picks the range, tmux paints it.'
```

<!-- end_slide -->

## Scrollback Cleanup

> Prompt glyphs and agent bullets never reach your shell.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n' 'on screen                                pasted'
printf '  %s\e[90m%s\e[0m\e[32m%s\e[0m\n' '› helm upgrade --install           ' ' ──▶  ' 'helm upgrade --install'
printf '  %s\e[90m%s\e[0m\e[32m%s\e[0m\n' '⏺ Update(values.yaml)              ' ' ──▶  ' 'Update(values.yaml)'
printf '  %s\e[90m%s\e[0m\e[32m%s\e[0m\n' '• Search the runbook               ' ' ──▶  ' 'Search the runbook'
printf '  %s\e[90m%s\e[0m\e[32m%s\e[0m\n' '    memory: 512Mi                  ' ' ──▶  ' '    memory: 512Mi'
printf '\n\e[32m%s\e[0m\n' 'Indentation stays, so YAML keeps its shape.'
```

<!-- end_slide -->

## Bracketed Paste

> Without the markers, a pasted newline is an Enter.

```bash +exec_replace
printf '  \e[31m%s\e[0m\n' '✗ keystrokes'
printf '\e[90m%s\e[0m\n' '  ╭──────────────────────────────────────────'
printf '\e[90m  │\e[0m %s\e[31m%s\e[0m\n' '$ limits:            ' 'runs'
printf '\e[90m  │\e[0m %s\e[31m%s\e[0m\n' '$ cpu: 500m          ' 'runs'
printf '\e[90m  │\e[0m %s\n' '$ memory: 512Mi▌'
printf '\e[90m%s\e[0m\n\n' '  ╰──────────────────────────────────────────'
printf '  \e[32m%s\e[0m\n' '✓ bracketed paste'
printf '\e[90m%s\e[0m\n' '  ╭──────────────────────────────────────────'
printf '\e[90m  │\e[0m %s\n' '$ limits:'
printf '\e[90m  │\e[0m %s\n' '    cpu: 500m'
printf '\e[90m  │\e[0m %s\e[32m%s\e[0m\n' '    memory: 512Mi▌   ' 'waits for your Enter'
printf '\e[90m%s\e[0m\n\n' '  ╰──────────────────────────────────────────'
printf '\e[32m%s\e[0m\n' 'The plugin always pastes bracketed.'
```

<!-- end_slide -->

## Clipboard

> Ctrl-Y copies instead of pasting, with no xclip or pbcopy.

```bash +exec_replace
printf '  \e[1;33m%s\e[0m\n' 'Ctrl-Y'
printf '  \e[90m%s\e[0m\n' '    ▼'
printf '  \e[36m%s\e[0m\e[90m%s\e[0m\n' 'tmux load-buffer -w     ' 'wraps the text as base64'
printf '  \e[90m%s\e[0m\e[1;33m%s\e[0m\n' '    │  ' 'ESC]52;c;aHR0cHM6Ly9kb2Nz…BEL'
printf '  \e[90m%s\e[0m\n' '    ▼'
printf '  \e[36m%s\e[0m\e[90m%s\e[0m\n' 'terminal                ' 'decodes it, locally or over SSH'
printf '  \e[90m%s\e[0m\n' '    ▼'
printf '  \e[1;32m%s\e[0m\n\n' 'system clipboard'
printf '\e[33m%s\e[0m\n' 'Your terminal has to allow OSC 52 writes.'
```

<!-- end_slide -->

## Getting Started

> What should you know before you try it?

```bash +exec_replace
./journey.sh 6
```

<!-- end_slide -->

## Limits

```bash +exec_replace
printf '  \e[36m%s\e[0m%s\n' '.*        ' 'stops at the first end, Up walks to older matches'
printf '  \e[36m%s\e[0m%s\n' 'case      ' 'ignored until \C'
printf '  \e[36m%s\e[0m%s\n' "don't     " "also matches a rendered don’t"
printf '  \e[36m%s\e[0m%s\n' 'reach     ' 'as far back as history-limit'
```

<!-- end_slide -->

## Install

> tmux 3.7b or newer: the picker is a floating window.

```bash +exec_replace
printf '  \e[36m%s\e[0m%s\n' 'tmux 3.7b+     ' 'floating picker, native wrapped selections'
printf '  \e[36m%s\e[0m%s\n' 'Python 3.10+   ' 'standard library only'
printf '  \e[36m%s\e[0m%s\n' 'fzf            ' 'the query box'
```

```bash
set -g @plugin 'Piotr1215/tmux-pane-regex'
```

```bash +exec_replace
printf '\e[32m%s\e[0m\n' 'prefix + R, then a word from the text you want.'
```

<!-- end_slide -->

## Resources

```markdown
Plugin:            https://github.com/Piotr1215/tmux-pane-regex
Selectors:         https://github.com/Piotr1215/tmux-pane-regex#use
Blog post:         https://cloudrumble.net/blog/2026/09/05/tmux-pane-regex
Escape sequences:  Neovim Terminal, youtube.com/@cloud-native-corner
```

<!-- end_slide -->

# That's All Folks! 👋

```bash +exec_replace
just intro_toilet That\'s all folks!
```
