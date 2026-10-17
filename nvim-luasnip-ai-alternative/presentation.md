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

## Changing Code at Scale

> Every codebase eventually needs the same change in many places.

```bash +exec_replace
paint red '  ✗  ' cyan 'find and replace   ' plain 'sees only text: changes too much, misses the rest'
paint red '  ✗  ' cyan 'by hand            ' plain 'careful, until there are a few hundred places'
paint red '  ✗  ' cyan 'an AI assistant    ' plain 'reads the code, then writes new code you must review'
```

<!-- end_slide -->

## Structured Logging

> Since Go 1.21, log/slog gives every logged value a name you can filter on.

```bash +exec_replace
paint cyan '  before   ' plain 'log.Printf("login failed: %v", err)'
paint gray '           login failed: no password'
paint
paint cyan '  after    ' plain 'slog.Error("login failed", ' 'bold green' '"err", err' plain ')'
paint gray '           ERROR login failed ' green 'err="no password"'
paint
paint yellow '  Plenty of Go code still uses log.Printf, so this is a migration many teams face.'
```

<!-- end_slide -->

## Different Lines

> The log lines in one service need different changes.

```bash +exec_replace
paint plain '  log.Printf("login failed: %v", err)       ' green 'slog.Error'
paint plain '  log.Printf("got here %v", r.URL)          ' red 'delete it: leftover debugging'
paint plain '  log.Printf("listening on %s", addr)       ' green 'slog.Info: an event'
paint plain '  log.Printf("login request: %+v", creds)   ' yellow 'a person decides: it prints a password'
```

<!-- end_slide -->

## What a Tool Needs

> The right change depends on what each line is for.

```bash +exec_replace
paint cyan '  recognize text         ' plain 'grep       ' gray 'but code is more than characters'
paint gray '      │'
paint cyan '  understand structure   ' plain 'ast-grep   ' gray 'but structure cannot see purpose'
paint gray '      │'
paint cyan '  judge meaning          ' plain 'classif    ' gray 'but a judgment should not edit code'
paint gray '      │'
paint cyan '  act on the judgment    ' plain 'rules      ' gray 'checked before your files change'
paint
paint yellow '  Each step exists because the one before it hits a wall.'
```

<!-- end_slide -->

## Text Search

> What does a text search see in code?

```bash +exec_replace
./journey.sh 2
```

<!-- end_slide -->

## Characters

> grep finds every log.Printf instantly, but it only compares characters.

```bash +exec_replace
paint red '  ✗  ' plain 'a call split over two lines: ' red 'missed'
paint gray '       log.Printf('
paint gray '           "server stopped: %v", err)'
paint
paint red '  ✗  ' plain 'a call that is commented out: ' red 'matched'
paint gray '       // log.Printf("failed: %v", err)'
paint
paint red '  ✗  ' plain 'calls whose argument is err: ' red 'no way to ask'
paint gray '       to grep there are no arguments, only characters'
```

<!-- end_slide -->

## Syntax Trees

> How can a tool read code as code?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## Syntax Tree

> To see code instead of characters, a tool reads it the way a compiler does.

```bash +exec_replace
paint gray '  log.Printf("got here %v", r.URL)'
paint
paint cyan '  call_expression'
paint gray '  ├─ ' yellow 'function    ' cyan 'selector_expression             ' plain 'log.Printf'
paint gray '  └─ ' yellow 'arguments   ' cyan 'argument_list'
paint gray '                 ├─ ' cyan 'interpreted_string_literal   ' plain '"got here %v"'
paint gray '                 └─ ' cyan 'selector_expression          ' plain 'r.URL'
paint
paint yellow '  Spacing, line breaks and comments are gone; the structure is left.'
```

<!-- end_slide -->

## Tree in Neovim

> Your editor already builds this tree, to highlight and select code.

```bash +exec_replace
paint cyan '  :InspectTree   ' plain 'the syntax tree of the file, beside the code'
paint cyan '  v an           ' plain 'select a node, then each one around it'
```

```bash +exec
./demo.sh tree
```

<!-- end_slide -->

## Patterns

> ast-grep searches that tree with patterns written as code.

```bash +exec_replace
paint cyan '  pattern   ' plain 'log.Printf(' 'bold magenta' '$FMT' plain ', err)' gray '      $FMT stands for any format string'
paint
paint green '  ✓  ' plain 'log.Printf("login failed: %v", err)'
paint green '  ✓  ' plain 'log.Printf(' gray '                              line breaks make no difference'
paint plain '         "server stopped: %v", err)'
paint red '  ✗  ' plain '// log.Printf("failed: %v", err)' gray '         a comment is not a call'
paint red '  ✗  ' plain 'log.Printf("user %v", name)' gray '              the argument is not err'
```

<!-- end_slide -->

## Rewrite Rule

> Finding is half the job: the placeholders remember what they matched.

```bash +exec_replace
paint yellow '  match      ' plain 'log.Printf("login failed: %v", err)'
paint yellow '  remember   ' 'bold magenta' '$FMT  ' plain '"login failed: %v"'
paint yellow '  reshape    ' 'bold magenta' '$MSG  ' plain '"login failed"' gray '   $FMT without the %v and the colon'
paint yellow '  rewrite    ' plain 'slog.Error(' 'bold magenta' '$MSG' plain ', "err", err)'
paint
paint green '             slog.Error("login failed", "err", err)'
```

<!-- end_slide -->

## Rule Run

> Running the rule shows a diff for every line that logs an error.

```bash +exec_replace
paint gray '  These lines need no judgment: the code itself says they log an error.'
```

```bash +exec
ast-grep scan --filter '^log-error$' logs
```

<!-- end_slide -->

## Formatting Limit

> slog keeps the value, but not printf formatting.

```bash +exec_replace
paint cyan '  printf   ' plain 'log.Printf("session %x", id)' gray '         prints  session 1f'
paint cyan '  slog     ' plain 'slog.Info("session", "id", id)' gray '       prints  id=31'
paint
paint yellow '  A line like this is never rewritten; another rule flags it for a person.'
```

<!-- end_slide -->

## Rules in Neovim

> The same rules run inside your editor, with the fix one key away.

```bash +exec_replace
paint cyan '  ]d    ' plain 'jump to the next line a rule flags'
paint cyan '  gra   ' plain 'the rule'"'"'s fix, offered as a code action'
```

```bash +exec
./demo.sh rules
```

<!-- end_slide -->

## Structure Limits

> To ast-grep, the other lines are all the same: a message and one value.

```bash +exec_replace
paint cyan '  pattern   ' plain 'log.Printf(' 'bold magenta' '$FMT' plain ', ' 'bold magenta' '$ARG' plain ')'
paint
paint green '  ✓  ' plain 'log.Printf("got here %v", r.URL)          ' gray 'should be deleted'
paint green '  ✓  ' plain 'log.Printf("listening on %s", addr)       ' gray 'should become slog.Info'
paint green '  ✓  ' plain 'log.Printf("login request: %+v", creds)   ' gray 'needs a person'
paint
paint yellow '  A rule carries one fix, and what separates these lines is not in the tree.'
```

<!-- end_slide -->

## Judging Meaning

> How can a tool tell what a line is for, without writing code?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## Language Models

> Reading a line for its purpose is what language models do well.

```bash +exec_replace
paint red '  ✗  ' cyan 'a chat model   ' plain 'answers in free text, and often rewrites the code too'
paint green '  ✓  ' cyan 'what we want   ' plain 'its reading of the line, without the writing'
```

<!-- end_slide -->

## classif

> classif asks a local model one question and accepts only an answer you listed.

```bash +exec_replace
paint cyan '  line       ' plain 'log.Printf("got here %v", r.URL)'
paint cyan '  question   ' plain 'What is this log line for?'
paint cyan '  answers    ' yellow 'debug       ' plain 'temporary output left while debugging'
paint plain '             ' yellow 'info        ' plain 'an event someone running the service wants'
paint plain '             ' yellow 'sensitive   ' plain 'can print a secret or personal data'
paint gray '               │'
paint gray '               ▼'
paint cyan '  classif    ' 'bold yellow' 'debug'
```

<!-- end_slide -->

## Answer Scores

> The model never writes: classif reads its probability for each answer.

```bash +exec_replace
paint plain '  log.Printf("got here %v", r.URL)'
paint yellow '    debug       ' green '██████████████████  ' plain '0.92'
paint yellow '    info        ' gray '█                   ' plain '0.04'
paint yellow '    sensitive   ' gray '█                   ' plain '0.03'
paint
paint plain '  log.Printf("retrying in %v", backoff)'
paint yellow '    info        ' red '███████████         ' plain '0.55' red '   below 0.9: nothing changes'
paint yellow '    debug       ' gray '█████████           ' plain '0.44'
paint
paint gray '  The number ranks the answers; it is not the chance the answer is right.'
paint gray '  The 0.9 floor came from a few trial runs; labeled lines should set it.'
```

<!-- end_slide -->

## Acting on Answers

> How can that answer change code safely?

```bash +exec_replace
./journey.sh 5
```

<!-- end_slide -->

## Answers and Rules

> An answer alone changes nothing, so each answer has its own rule.

```bash +exec_replace
paint yellow '  debug       ' gray '› ' plain 'delete the line'
paint yellow '  info        ' gray '› ' plain 'rewrite as slog.Info, the value as a named field'
paint yellow '  sensitive   ' gray '› ' plain 'no fix: the line waits for a person'
paint
paint yellow '  Every change is a rule you can read in advance; the model only chooses.'
```

<!-- end_slide -->

## Model Answers

> Asked about every line, the model picks a rule or leaves the line for a person.

```bash +exec_replace
ast-grep scan --filter '^log-' --json=stream --include-metadata logs | ./triage.sh --pick
```

<!-- end_slide -->

## Checks

> Before your files change, the result must pass the checks you would run.

```bash +exec_replace
paint cyan '  on a copy    ' plain 'the error rule, then the rules the model chose'
paint gray '                 │'
paint gray '                 ▼'
paint cyan '  goimports    ' plain 'adds the log/slog import'
paint gray '                 │'
paint gray '                 ▼'
paint cyan '  go build     ' plain 'the code must compile'
paint cyan '  go vet       ' plain 'and pass the vet checks'
paint gray '                 │'
paint gray '                 ▼'
paint cyan '  your files   ' plain 'replaced only after every check passed'
```

<!-- end_slide -->

## Failed Build

> The checks catch real mistakes, even after a right answer.

```bash +exec_replace
paint plain '  path := r.URL.Path'
paint plain '  log.Printf("got here %v", path)     ' yellow 'debug' gray ' › ' plain 'delete the line'
paint
paint cyan '  go build   ' red './main.go:28:2: path declared and not used'
paint cyan '  result     ' plain 'the checks failed, so your files stay as they were'
```

<!-- end_slide -->

## Check Limits

> The checks prove the code compiles, not that every change was right.

```bash +exec_replace
paint green '  ✓  ' cyan 'caught   ' plain 'a deletion that leaves a variable unused'
paint red '  ✗  ' cyan 'missed   ' plain 'a line the model wrongly called debug: deleted, still builds'
paint
paint yellow '  So every change ends as a diff a person reads,'
paint yellow '  and lines that can leak a secret get no fix at all.'
```

<!-- end_slide -->

## Migration

> Run together, the migration ends with code that still builds.

```bash +exec_replace
paint gray '  A dry run: every change is shown and checked, and nothing is written.'
```

```bash +exec_replace
./migrate.sh
```

<!-- end_slide -->

## Where It Fits

> When is this worth doing, and how do you start?

```bash +exec_replace
./journey.sh 6
```

<!-- end_slide -->

## Good Fit

> This fits when a rule can make every change but cannot pick which one.

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
paint green '  ✓  ' cyan 'the recipe   ' plain 'a rule for each change, a model to pick, checks and a diff'
paint 'bold yellow' '  ▶  ' cyan 'next step    ' plain 'a change in your code that is right for only some places'
```

<!-- end_slide -->

## Install

> To try it you need ast-grep, a local model for classif, and Go's own tools.

```bash +exec_replace
paint cyan '  ast-grep    ' plain 'cargo install ast-grep --locked'
paint gray '              or npm i -g @ast-grep/cli, or brew install ast-grep'
paint cyan '  classif     ' plain 'Ollama and a local model; jq for the scripts'
paint cyan '  goimports   ' plain 'go install golang.org/x/tools/cmd/goimports@latest'
paint cyan '  Neovim      ' plain '0.12 or newer, for v an'
paint
paint yellow '  On Linux, sg can be the group switch command: type ast-grep.'
```

<!-- end_slide -->

## Resources

```markdown
ast-grep rules:   https://ast-grep.github.io/guide/rule-config.html
Playground:       https://ast-grep.github.io/playground.html
log/slog:         https://pkg.go.dev/log/slog
Tree selection:   :help treesitter-incremental-selection
classif:          https://github.com/Piotr1215/classif
Channel:          youtube.com/@cloud-native-corner
```

<!-- end_slide -->

# That's All Folks! 👋

```bash +exec_replace
just intro_toilet That\'s all folks!
```
