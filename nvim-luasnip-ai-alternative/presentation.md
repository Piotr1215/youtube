# Code Intelligence

> From finding text to acting on what code means

<!-- new_lines: 3 -->

```bash +exec_replace
echo "ast-grep + classif" | figlet -f small -w 90
```

<!-- end_slide -->

## Bulk Code Changes

> Why is changing code in many places still hard?

```bash +exec_replace
./journey.sh 1
```

<!-- end_slide -->

## Before and After

```bash +exec_replace
paint gray '  logs/main.go'
paint
./migrate.sh --diff | awk '/@@/ { hunk++; if (hunk > 2) print ""; next } hunk > 1'
```

<!-- end_slide -->

## From log.Printf to log/slog

```file
path: examples/slog.go
language: go
start_line: 11
end_line: 13
```

```bash +exec
go run examples/slog.go
```

<!-- end_slide -->

## The Log Lines in Our Service

```bash +exec
rg -n 'log\.Printf' logs/main.go
```

<!-- end_slide -->

## The Usual Ways

```bash +exec_replace
paint red '  ✗  ' cyan 'find and replace   ' plain 'sees only text: changes too much, misses the rest'
paint red '  ✗  ' cyan 'by hand            ' plain 'careful, until there are a few hundred places'
paint red '  ✗  ' cyan 'an AI assistant    ' plain 'writes new code you must review line by line'
```

<!-- end_slide -->

## Text Search

> What does a text search see in code?

```bash +exec_replace
./journey.sh 2
```

<!-- end_slide -->

## Finding Error Calls with grep

```bash +exec_replace
bat --paging=never --color=always --style=numbers --line-range 12:16 examples/calls.go
```

```bash +exec
rg -n 'log\.Printf\(.*, err\)' examples/calls.go
```

<!-- end_slide -->

## Syntax Trees

> How do we see code as code, not characters?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## The Syntax Tree, Live

```bash +exec
/// nvim() { tmux new-window -c "${PWD}" -n tree nvim -i NONE --cmd 'set noswapfile' --cmd 'let g:copilot_enabled = v:false' "$1" '+normal! ^' "${@:2}" '+vertical resize 50' '+wincmd p' '+set nowrap'; }
nvim +13 examples/calls.go +InspectTree
```

<!-- end_slide -->

## A Pattern Written as Code

```bash +exec_replace
paint cyan '  we want    ' plain 'every log.Printf whose second argument is err'
paint cyan '  we write   ' plain 'log.Printf(' 'bold magenta' '$FMT' plain ', err)'
paint
paint gray '  call_expression'
paint gray '  ├─ ' yellow 'function    ' plain 'log.Printf       ' gray 'must be log.Printf'
paint gray '  └─ ' yellow 'arguments'
paint gray '     ├─ ' 'bold magenta' '$FMT                     ' gray 'any one expression'
paint gray '     └─ ' plain 'err                      ' gray 'must be err'
```

<!-- end_slide -->

## Finding Error Calls by Structure

```bash +exec
ast-grep run -p 'log.Printf($FMT, err)' examples/calls.go
```

<!-- end_slide -->

## Building the New Line from the Old

```bash +exec_replace
paint yellow '  match      ' plain 'log.Printf("login failed: %v", err)'
paint yellow '  remember   ' 'bold magenta' '$FMT  ' plain '"login failed: %v"'
paint yellow '  reshape    ' 'bold magenta' '$MSG  ' plain '"login failed"'
paint yellow '  rewrite    ' plain 'slog.Error(' 'bold magenta' '$MSG' plain ', "err", err)'
paint
paint green '             slog.Error("login failed", "err", err)'
```

<!-- end_slide -->

## The Rewrite as a Rule

```bash +exec_replace
paint gray '  rules/log-error.yml'
```

```file {2,19}
path: rules/log-error.yml
language: yaml
start_line: 10
end_line: 28
```

<!-- end_slide -->

## Every Error Line, Rewritten

```bash +exec
ast-grep scan --filter '^log-error$' -C 1 logs
```

<!-- end_slide -->

## Same Shape, Different Fixes

```bash +exec_replace
paint cyan '  pattern   ' plain 'log.Printf(' 'bold magenta' '$FMT' plain ', ' 'bold magenta' '$ARG' plain ')'
paint
paint green '  ✓  ' plain 'log.Printf("got here %v", r.URL)        ' gray 'should be deleted'
paint green '  ✓  ' plain 'log.Printf("listening on %s", addr)     ' gray 'should become slog.Info'
paint green '  ✓  ' plain 'log.Printf("retrying in %v", backoff)   ' gray 'could be either'
```

<!-- end_slide -->

## Judging Meaning

> How can we tell what a line is for, without a model writing code?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## From Meaning to an Action

<!-- new_lines: 2 -->

```bash +exec_replace
paint plain '  log.Printf("got here %v", r.URL)'
paint gray '                 │'
paint gray '                 ▼'
paint 'bold magenta' '              classif'
paint gray '                 │'
paint gray '                 ▼'
paint 'bold yellow' '               debug'
paint gray '                 │'
paint gray '                 ▼'
paint green '          delete the line'
```

<!-- end_slide -->

## Same Shape, Different Answers

```bash +exec
ast-grep scan --filter '^log-' --include-metadata --json=stream examples/shape.go \
  | ./triage.sh --pick
```

<!-- end_slide -->

## Sure and Unsure

<!-- new_lines: 2 -->

```bash +exec_replace
paint gray '  0.5                                     ' yellow '0.85' gray '                1'
paint gray '  ├' red '─────────────────────────────────────────' yellow '┼' green '─────────────────' gray '┤'
paint red '                            ▲' green '                            ▲'
paint plain '                       retrying in                   got here'
paint red '                    left for a person' green '               fix applied'
paint
paint
paint gray '  A rule for when to act, not the chance that the answer is right.'
```

<!-- end_slide -->

## Acting on the Answer

> How can that answer change code safely?

```bash +exec_replace
./journey.sh 5
```

<!-- end_slide -->

## The Debug Rule

```bash +exec_replace
paint gray '  rules/log-debug.yml'
```

```file {2-6,16}
path: rules/log-debug.yml
language: yaml
start_line: 9
end_line: 24
```

<!-- end_slide -->

## A Second Question

```file
path: rules/log-sensitive.yml
language: yaml
start_line: 12
end_line: 15
```

```bash +exec
ast-grep scan --filter '^log-' --include-metadata --json=stream examples/veto.go \
  | ./triage.sh --pick
```

<!-- end_slide -->

## The Whole Service

```bash +exec_replace
./migrate.sh
```

<!-- end_slide -->

## Every Edit These Rules Can Make

```bash +exec
rg --sort path '^fix:' rules/log-*.yml
```

<!-- end_slide -->

## A Right Answer That Breaks the Build

```bash +exec_replace
paint plain '  path := r.URL.Path'
paint plain '  log.Printf("got here %v", path)     ' yellow 'debug' gray ' › ' plain 'delete the line'
paint
paint cyan '  go build   ' red './main.go:28:2: path declared and not used'
paint cyan '  result     ' plain 'the checks failed, so your files stay as they were'
paint
paint red '  ✗  ' cyan 'missed     ' plain 'a line wrongly called debug: deleted, and it still builds'
```

<!-- end_slide -->

## Your Own Codebase

> When is this worth doing, and how do you try it on your code?

```bash +exec_replace
./journey.sh 6
```

<!-- end_slide -->

## When a Model Should Pick the Change

```bash +exec_replace
paint green '  ✓  ' plain 'every possible change can be written as a rule'
paint green '  ✓  ' plain 'the structure of the code cannot pick between them'
paint green '  ✓  ' plain 'the deciding fact is in the text the model sees'
paint green '  ✓  ' plain 'a wrong answer is easy to catch in the diff'
paint
paint red '  ✗  ' plain 'when the deciding fact lives elsewhere, the model cannot decide'
```

<!-- end_slide -->

## Takeaways

> The model adds meaning between two deterministic steps and replaces neither.

```bash +exec_replace
paint green '  ✓  ' cyan 'the idea     ' plain 'a model chooses the change; rules make every edit'
paint green '  ✓  ' cyan 'the recipe   ' plain 'a rule per change, a model to pick, a veto, checks, a diff'
paint 'bold yellow' '  ▶  ' cyan 'next step    ' plain 'a change in your code that is right for only some places'
```

<!-- end_slide -->

## Installing the Tools

```bash +exec_replace
paint cyan '  ast-grep    ' plain 'cargo install ast-grep --locked'
paint gray '              or npm i -g @ast-grep/cli, or brew install ast-grep'
paint cyan '  classif     ' plain 'Ollama and a local model; jq for the scripts'
paint cyan '  goimports   ' plain 'go install golang.org/x/tools/cmd/goimports@latest'
paint
paint yellow '  On Linux, sg can be the group switch command: type ast-grep.'
```

<!-- end_slide -->

## Resources

```markdown
ast-grep rules:   https://ast-grep.github.io/guide/rule-config.html
Playground:       https://ast-grep.github.io/playground.html
log/slog:         https://pkg.go.dev/log/slog
Syntax tree:      :InspectTree in Neovim
classif:          https://github.com/Piotr1215/classif
Channel:          youtube.com/@cloud-native-corner
```

<!-- end_slide -->

# That's All Folks! 👋

```bash +exec_replace
just intro_toilet That\'s all folks!
```
