# Code Intelligence

> Find code by its structure, rewrite it by its meaning

<!-- new_lines: 3 -->

```bash +exec_replace
echo "ast-grep + classif" | figlet -f small -w 90
```

<!-- end_slide -->

## Overview

> What does this video build, and why?

```bash +exec_replace
./journey.sh 1
```

<!-- end_slide -->

## Migration

> Eight log calls, one shape: each gets the fix its meaning calls for.

```bash +exec_replace
paint gray '  log.Printf to log/slog, on a copy: ast-grep rewrites, classif picks, Go checks.'
```

```bash +exec
./migrate.sh
```

<!-- end_slide -->

## Levels

> Each level adds one step to the migration you just saw.

```bash +exec_replace
paint 'bold yellow' '  1  ' cyan 'find text         ' plain 'grep             ' gray 'every log.Printf, by its characters'
paint 'bold yellow' '  2  ' cyan 'find structure    ' plain 'ast-grep         ' gray 'the calls that log err, by syntax'
paint 'bold yellow' '  3  ' cyan 'judge meaning     ' plain '+ classif        ' gray 'what each other call is for'
paint 'bold yellow' '  4  ' cyan 'act on judgment   ' plain '+ go build, vet  ' gray 'the fix for that answer, checked'
```

<!-- end_slide -->

## Find Text

> What can a text search tell you?

```bash +exec_replace
./journey.sh 2
```

<!-- end_slide -->

## Log Calls

> grep finds every call; it cannot say what any of them is for.

```bash +exec
rg -n 'log\.Printf' logs/main.go
```

<!-- end_slide -->

## Text Search

> grep compares characters, so a line break hides the match.

```bash +exec_replace
paint cyan '  search     ' plain 'if err != nil { return nil, err }'
paint cyan '  code       ' plain 'if err != nil {'
paint plain '                 return nil, err'
paint plain '             }'
paint
paint red '  ✗  ' cyan 'grep       ' plain '0 matches in example_bad.go'
paint green '  ✓  ' cyan 'ast-grep   ' plain '6 matches: it compares syntax trees, not lines'
```

<!-- end_slide -->

## Syntax Trees

> What do these tools see that grep does not?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## First Look

> One ast-grep scan flags every error-handling problem in a file.

```bash +exec_replace
paint gray '  Each line names a rule and where it matched; the next slides show how.'
```

```bash +exec +expect:failure
time ast-grep scan --report-style short example_bad.go
```

<!-- end_slide -->

## Abstract Syntax Tree

> AST, abstract syntax tree: the parts of the code and how they nest.

```bash +exec_replace
just digraph syntax-tree | awk '
{
  gsub(/if_statement|binary_expression|block|return_statement|identifier/, "\033[1;36m&\033[0m")
  gsub(/consequence|condition|left|right/, "\033[1;33m&\033[0m")
  if ($0 ~ /^│ +nil +│$/) gsub(/nil/, "\033[1;36m&\033[0m")
  print "  " $0
}'
paint
paint yellow '  Abstract: the tree keeps the parts and drops the spacing.'
paint yellow '  Kinds name nodes, fields name their parts: kind: if_statement, field: condition.'
```

<!-- end_slide -->

## Parsing

> tree-sitter builds the tree; Neovim and ast-grep both read it.

```bash +exec_replace
just digraph parsing | awk '
{
  gsub(/tree-sitter|syntax tree/, "\033[1;33m&\033[0m")
  gsub(/Neovim|ast-grep/, "\033[1;36m&\033[0m")
  gsub(/:InspectTree|patterns/, "\033[35m&\033[0m")
  print "  " $0
}'
paint
paint yellow '  One parser, a grammar per language: each rule names the language it reads.'
```

<!-- end_slide -->

## Tree in Neovim

> Watch Neovim show the tree behind the bare return from First Look.

```bash +exec_replace
paint cyan '  :InspectTree   ' plain 'the buffer'"'"'s syntax tree, beside the code'
paint cyan '  j / k          ' plain 'walk the nodes; the code under each one lights up'
paint cyan '  v an           ' plain 'select the node at the cursor, then each parent'
```

```bash +exec
./demo.sh tree
```

<!-- end_slide -->

## Tree Demo Result

```bash +exec_replace
paint green '  ✓  ' plain 'Neovim parsed the file into the nodes from the diagram'
paint green '  ✓  ' plain 'each node covers an exact range of code'
paint green '  ✓  ' plain 'v an selected by node: the if, its body, the function'
paint
paint yellow '  ast-grep matches patterns against this same kind of tree.'
```

<!-- end_slide -->

## Patterns

> How do you search by shape instead of text?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## Pattern Matching

> A pattern is parsed like code, then compared with every node in the file.

```bash +exec_replace
just digraph pattern-match | awk '
{
  gsub(/\$\$\$ARGS|\$MSG/, "\033[1;35m&\033[0m")
  gsub(/parse|compare with every node/, "\033[33m&\033[0m")
  gsub(/call_expression/, "\033[1;36m&\033[0m")
  print "  " $0
}'
```

<!-- end_slide -->

## Metavariables

> Metavariables capture the parts that change.

```bash +exec_replace
paint cyan '  pattern   ' plain 'if ' 'bold yellow' '$ERR' plain ' != nil { return ' 'bold magenta' '$$$ARGS' plain ', ' 'bold yellow' '$ERR' plain ' }'
paint cyan '  code      ' plain 'if ' yellow 'err' plain ' != nil { return ' magenta 'nil' plain ', ' yellow 'err' plain ' }'
paint
paint 'bold yellow' '  $ERR      ' plain 'one node, the same text everywhere it appears'
paint 'bold magenta' '  $$$ARGS   ' plain 'any number of nodes, zero included'
paint
paint green '  ✓ return nil, e2 does not match: both $ERR must agree'
```

<!-- end_slide -->

## Editor Search

> Watch the matches update while a pattern is typed into grug-far.

```bash +exec_replace
paint cyan '  Space s g   ' plain 'open grug-far with the ast-grep engine'
paint cyan '  pattern     ' plain 'the same syntax as ast-grep run -p'
```

```bash +exec
./demo.sh search
```

<!-- end_slide -->

## Search Demo Result

```bash +exec_replace
paint green '  ✓  ' plain 'both fmt.Errorf calls matched once the pattern parsed'
paint green '  ✓  ' plain 'the one-line if pattern matched every multi-line if block'
paint green '  ✓  ' plain 'grug-far ran ast-grep itself; no rule file was needed'
paint
paint yellow '  A pattern is a query; a rule turns it into a review comment.'
```

<!-- end_slide -->

## ast-grep Rules

> How does a review comment become a rule?

```bash +exec_replace
./journey.sh 5
```

<!-- end_slide -->

## Rule File

> A review comment, written once.

```file
path: rules/panic-on-error.yml
language: yaml
```

```bash +exec_replace
paint green '  ✓  ' plain 'if err != nil { panic(err) }'
paint green '  ✓  ' plain 'if e != nil { panic(e) }' gray '              any name, any layout'
paint green '  ✓  ' plain 'if load() != nil { panic(load()) }' gray '    any expression'
paint red '  ✗  ' plain 'if err != nil { panic(other) }' gray '        $ERR differs'
paint red '  ✗  ' plain '// if err != nil { panic(err) }' gray '       a comment'
paint red '  ✗  ' plain 'if err != nil { log.Print(err); panic(err) }' gray '  two statements'
```

<!-- end_slide -->

## Relations

> A relational rule checks the nodes around a match.

```bash +exec_replace
just digraph relations | awk '
{
  gsub(/inside|follows|has/, "\033[1;33m&\033[0m")
  gsub(/an ancestor|the statement before|a descendant/, "\033[38;2;128;128;128m&\033[0m")
  print "  " $0
}'
```

<!-- end_slide -->

## Autofix

> fix: rebuilds the matched code from the parts the pattern captured.

```bash +exec_replace
paint gray '  rules/fmt-errorf-without-wrap.yml'
paint
paint yellow '  1  match      ' plain 'fmt.Errorf(' 'bold magenta' '$FMT' plain ', ' 'bold magenta' '$$$REST' plain ')'
paint plain '                fmt.Errorf("failed to marshal user: %v", err)'
paint
paint yellow '  2  capture    ' 'bold magenta' '$FMT      ' green '"failed to marshal user: %v"'
paint plain '                ' 'bold magenta' '$$$REST   ' green 'err'
paint
paint yellow '  3  transform  ' 'bold magenta' '$WRAPPED  ' plain '$FMT with %v" replaced by %w"'
paint
paint yellow '  4  fix        ' plain 'fmt.Errorf(' 'bold magenta' '$WRAPPED' plain ', ' 'bold magenta' '$$$REST' plain ')'
paint plain '                fmt.Errorf("failed to marshal user: ' 'bold green' '%w' plain '", err)'
paint
paint yellow '  scan -U writes the new text over the matched call; the editor offers it on gra.'
```

<!-- end_slide -->

## Fix in Editor and Shell

> The fix lives in the rule file; the editor and the shell both run it.

```bash +exec_replace
just digraph editor-lsp | awk '
{
  gsub(/message:|fix:/, "\033[36m&\033[0m")
  gsub(/ast-grep lsp|ast-grep scan -U/, "\033[1;33m&\033[0m")
  gsub(/diagnostic|code action/, "\033[1;36m&\033[0m")
  gsub(/gra/, "\033[1;35m&\033[0m")
  print "  " $0
}'
paint
paint yellow '  gra is the default Neovim key for vim.lsp.buf.code_action(), since 0.11.'
```

<!-- end_slide -->

## Editor Diagnostics

> Watch a finding appear inline, then gra apply the rule's fix.

```bash +exec_replace
paint cyan '  ]d          ' plain 'next finding, with its message'
paint cyan '  gra         ' plain 'code actions; the rule'"'"'s fix: is one of them'
```

```bash +exec
./demo.sh diagnostics
```

<!-- end_slide -->

## Diagnostics Demo Result

```bash +exec_replace
paint green '  ✓  ' plain 'every rule showed up inline as soon as the file opened'
paint green '  ✓  ' plain 'gra listed each matching rule'"'"'s fix: as a code action'
paint green '  ✓  ' plain 'applying it turned %v into %w, and the warning went away'
paint
paint yellow '  One rule file serves the shell, the editor, and its own tests.'
```

<!-- end_slide -->

## Syntax Fix

> A call that logs err belongs in slog.Error; syntax alone says so.

```bash +exec_replace
paint gray '  rules/log-error.yml   log.Printf($FMT, err)  ›  slog.Error($MSG, "err", err)'
```

```bash +exec
ast-grep scan --filter '^log-error$' logs
```

<!-- end_slide -->

## Structure Limits

> The other six share one pattern; the right fix depends on what each is for.

```bash +exec_replace
paint cyan '  pattern   ' plain 'log.Printf(' 'bold magenta' '$FMT' plain ', ' 'bold magenta' '$ARG' plain ')'
paint
paint plain '  log.Printf("got here %v", r.URL)            ' yellow 'debug       ' plain 'remove the line'
paint plain '  log.Printf("listening on %s", addr)         ' yellow 'info        ' plain 'slog.Info'
paint plain '  log.Printf("login request: %+v", creds)     ' yellow 'sensitive   ' plain 'a person decides'
paint
paint yellow '  A rule carries one fix, and any one of these is wrong for the other two.'
```

<!-- end_slide -->

## Judge Meaning

> What can a rule ask that syntax cannot answer?

```bash +exec_replace
./journey.sh 6
```

<!-- end_slide -->

## classif

> A local model picks one option for a piece of text.

```bash +exec_replace
paint cyan '  text       ' plain 'log.Printf("got here %v", r.URL)'
paint cyan '  question   ' plain 'What is this log line for?'
paint cyan '  options    ' yellow 'debug      ' plain 'temporary output a developer left while debugging'
paint plain '             ' yellow 'info       ' plain 'an event someone operating the service wants'
paint plain '             ' yellow 'sensitive  ' plain 'can print a secret or personal data'
paint gray '               │'
paint gray '               ▼'
paint cyan '  model      ' plain 'scores the next token; classif reads the score of each option'
paint gray '               │'
paint gray '               ▼'
paint cyan '  answer     ' 'bold yellow' 'debug 0.92'
paint
paint yellow '  p is the model'"'"'s probability for that token, not how often it is right.'
```

<!-- end_slide -->

## Rules as Options

> Three rules match the same call; each offers one answer and its fix.

```bash +exec_replace
paint gray '  each rule      ' plain 'log.Printf($FMT, $ARG)   ' gray 'choose: What is this log line for?'
paint
paint cyan '  log-debug      ' yellow 'debug       ' plain 'fix: ' green "''" gray '   the line goes'
paint cyan '  log-info       ' yellow 'info        ' plain 'fix: ' green 'slog.Info($MSG, "$ARG", $ARG)'
paint cyan '  log-sensitive  ' yellow 'sensitive   ' gray 'no fix: a person decides'
paint
paint yellow '  triage.sh hands the options to classif -e; the chosen rule'"'"'s fix lands.'
paint yellow '  min_p 0.9 came from a few runs; a real threshold needs labeled rows.'
```

<!-- end_slide -->

## Judged Calls

> classif answers for each call; nothing is written yet.

```bash +exec_replace
paint gray '  ✓ the answer'"'"'s fix lands    ✗ sensitive, or below min_p: a person looks'
```

```bash +exec
ast-grep scan --filter '^log-' --json=stream --include-metadata logs \
  | ./triage.sh --pick
```

<!-- end_slide -->

## Act on Judgment

> What keeps it safe to let the answer pick the fix?

```bash +exec_replace
./journey.sh 7
```

<!-- end_slide -->

## Pipeline

> migrate.sh runs the levels in order, on a copy of the package.

```bash +exec_replace
paint 'bold yellow' '  1  ' cyan 'syntax    ' plain 'ast-grep    ' gray 'log.Printf(…, err) becomes slog.Error, no model'
paint 'bold yellow' '  2  ' cyan 'meaning   ' plain 'classif     ' gray 'picks each other call'"'"'s rule; its fix lands'
paint 'bold yellow' '  3  ' cyan 'verify    ' plain 'Go          ' gray 'goimports, go build, go vet must pass'
paint 'bold yellow' '  4  ' cyan 'write     ' plain '--apply     ' gray 'copies the files back, only after 3 passed'
paint
paint yellow '  An unsure answer lands nothing; a failed check writes nothing.'
```

<!-- end_slide -->

## Failed Check

> A right answer can still break the build; then nothing is written.

```bash +exec_replace
paint gray '  a run on a copy where the debug line logs a variable used nowhere else'
paint
paint plain '  path := r.URL.Path'
paint plain '  log.Printf("got here %v", path)     ' yellow 'debug 0.96   ' plain 'the line is removed'
paint
paint cyan '  3  verify   ' red './main.go:28:2: path declared and not used'
paint plain '              ' red 'verification failed; the package is unchanged'
```

<!-- end_slide -->

## Where It Fits

> classif earns its place where all four hold.

```bash +exec_replace
paint green '  ✓  ' plain 'a fixed set of actions, each one a rule'"'"'s fix'
paint green '  ✓  ' plain 'syntax and types cannot tell which one a match needs'
paint green '  ✓  ' plain 'the text in front of the model holds the answer'
paint green '  ✓  ' plain 'a wrong or missing answer stays for a person, or fails the build'
paint
paint red '  ✗  ' plain 'an error message judged against its function: one comment flipped it'
```

<!-- end_slide -->

## Migration Result

```bash +exec_replace
paint green '  ✓  ' cyan 'syntax      ' plain '2 calls logging err moved to slog.Error'
paint green '  ✓  ' cyan 'meaning     ' plain '2 events moved to slog.Info; the debug line went'
paint green '  ✓  ' cyan 'a person    ' plain '2 sensitive calls and 1 unsure call, left as they were'
paint green '  ✓  ' cyan 'verify      ' plain 'goimports added log/slog; go build and go vet passed'
paint
paint yellow '  The model adds meaning between two deterministic steps and replaces neither.'
```

<!-- end_slide -->

## Getting Started

> What do you need to try it?

```bash +exec_replace
./journey.sh 8
```

<!-- end_slide -->

## Install

> ast-grep 0.51 was used here.

```bash +exec_replace
paint cyan '  ast-grep   ' plain 'cargo install ast-grep --locked'
paint gray '             or npm i -g @ast-grep/cli, or brew install ast-grep'
paint cyan '  classif    ' plain 'needs Ollama and a local model; triage.sh uses jq'
paint cyan '  goimports  ' plain 'go install golang.org/x/tools/cmd/goimports@latest'
paint cyan '  Neovim     ' plain '0.12 or newer for v an; nvim-lspconfig for the LSP'
paint cyan '  grug-far   ' plain 'optional, ast-grep search and replace in a buffer'
paint
paint yellow '  On Linux, sg can be the group switch command: type ast-grep.'
```

<!-- end_slide -->

## Takeaways

```bash +exec_replace
paint green '  ✓  ' cyan 'structure   ' plain 'ast-grep finds code by its tree and rewrites it with a rule'"'"'s fix'
paint green '  ✓  ' cyan 'meaning     ' plain 'classif picks the rule where syntax cannot; unsure means no fix'
paint 'bold yellow' '  ▶  ' cyan 'next        ' plain 'find a rule of yours whose fix is right for only some matches'
```

<!-- end_slide -->

## Resources

```markdown
ast-grep rules:   https://ast-grep.github.io/guide/rule-config.html
Rule tests:       https://ast-grep.github.io/guide/test-rule.html
Playground:       https://ast-grep.github.io/playground.html
log/slog:         https://pkg.go.dev/log/slog
grug-far:         https://github.com/MagicDuck/grug-far.nvim
Code actions:     :help gra
Tree selection:   :help treesitter-incremental-selection
classif:          https://github.com/Piotr1215/classif
Channel:          youtube.com/@cloud-native-corner
```

<!-- end_slide -->

# That's All Folks! 👋

```bash +exec_replace
just intro_toilet That\'s all folks!
```
