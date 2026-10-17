# Code Intelligence

> Rules that read syntax, and a local model for what syntax cannot judge

<!-- new_lines: 3 -->

```bash +exec_replace
echo "ast-grep + classif" | figlet -f small -w 90
```

<!-- end_slide -->

## Repeated Fixes

> Which review comments do you keep writing?

```bash +exec_replace
./journey.sh 1
```

<!-- end_slide -->

## Review Loop

> The same error-handling comments come back on every pull request.

```bash +exec_replace
paint 'bold cyan' '  write code' gray ' ──▶ ' 'bold cyan' 'open a PR' gray ' ──▶ ' 'bold yellow' 'same review comment' gray ' ──▶ ' 'bold cyan' 'fix by hand'
paint gray '    ▲                                                       │'
paint gray '    └───────────────────────────────────────────────────────┘'
paint
paint yellow '  A rule could leave that comment, and offer the fix with it.'
```

<!-- end_slide -->

## Building Blocks

> Find the mistake, offer the fix, and ask a model only what syntax cannot tell.

```bash +exec_replace
just digraph building-blocks | awk '
{
  gsub(/syntax tree/, "\033[1;33m&\033[0m")
  gsub(/ast-grep rule/, "\033[1;36m&\033[0m")
  gsub(/gra/, "\033[1;35m&\033[0m")
  gsub(/classif/, "\033[1;32m&\033[0m")
  gsub(/fix:|ask:| no /, "\033[38;2;128;128;128m&\033[0m")
  print "  " $0
}'
paint
paint yellow '  A plain rule goes straight to gra; a rule with a question asks classif first.'
```

<!-- end_slide -->

## First Look

> One scan flags every error-handling problem in the file.

```bash +exec_replace
paint gray '  Each line names a rule and where it matched; the next chapters show how.'
```

```bash +exec +expect:failure
time ast-grep scan --report-style short example_bad.go
```

<!-- end_slide -->

## Syntax Trees

> What do these tools see that grep does not?

```bash +exec_replace
./journey.sh 2
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
paint yellow '  One grammar per language: the same rules work on Go, Python, and Bash.'
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
./journey.sh 3
```

<!-- end_slide -->

## Text and Tree

> grep compares characters; ast-grep compares trees.

```bash +exec_replace
paint cyan '  pattern    ' plain 'if err != nil { return nil, err }'
paint cyan '  code       ' plain 'if err != nil {'
paint plain '                 return nil, err'
paint plain '             }'
paint
paint red '  ✗  ' cyan 'grep       ' plain '0 matches in example_bad.go: the line breaks differ'
paint green '  ✓  ' cyan 'ast-grep   ' plain '6 matches in example_bad.go: the trees agree'
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

## Debug Query

> --debug-query prints the tree ast-grep builds from a pattern.

```bash +exec
ast-grep run -l go --debug-query=pattern -p 'fmt.Errorf($MSG, $$$ARGS)' example_bad.go
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

## Pattern Search

> Search by the shape of the code, straight from the shell.

```bash +exec
ast-grep run -p 'fmt.Errorf($MSG, $$$ARGS)' example_bad.go
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
./journey.sh 4
```

<!-- end_slide -->

## Rule File

> A review comment, written once.

```file
path: rules/panic-on-error.yml
language: yaml
```

```bash +exec +expect:failure
ast-grep scan -r rules/panic-on-error.yml --report-style short example_bad.go
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

## Relational Rules

> follows: the match must come right after this statement.

```file
path: rules/direct-http-error-return.yml
language: yaml
```

```bash +exec
ast-grep scan -r rules/direct-http-error-return.yml \
  --report-style short example_bad.go
```

<!-- end_slide -->

## Autofix

> fix: turns a finding into an edit, and scan -U applies it.

```bash +exec
ast-grep scan -r rules/fmt-errorf-without-wrap.yml example_bad.go
```

<!-- end_slide -->

## Rule Tests

> Valid and invalid cases pin down what a rule may flag.

```bash +exec
ast-grep test
```

<!-- end_slide -->

## Fix in the Editor

> The rule's message becomes a diagnostic; its fix becomes a code action.

```bash +exec_replace
just digraph editor-lsp | awk '
{
  gsub(/message:|fix:/, "\033[36m&\033[0m")
  gsub(/ast-grep lsp/, "\033[1;33m&\033[0m")
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

## Python and Bash

> The same rule format, two more syntax trees.

```bash +exec_replace
paint yellow '  shellcheck passes example_bad.sh; these rules encode team conventions.'
```

```bash +exec +expect:failure
ast-grep scan --report-style short example_bad.py example_bad.sh
```

<!-- end_slide -->

## Rules with Questions

> What can a rule ask that syntax cannot answer?

```bash +exec_replace
./journey.sh 5
```

<!-- end_slide -->

## Syntax Limits

> Same shape to ast-grep; only one tells you what failed.

```bash +exec_replace
paint cyan '  pattern   ' plain 'fmt.Errorf(' 'bold magenta' '$MSG' plain ', ' 'bold magenta' '$$$ARGS' plain ')'
paint
paint green '  ✓  ' plain 'fmt.Errorf("' 'bold green' 'fetch user' plain ': %w", err)'
paint red '  ✗  ' plain 'fmt.Errorf("' 'bold red' 'bad status' plain ': %d", resp.StatusCode)'
paint
paint yellow '  A pattern can match the message; judging it means reading it.'
```

<!-- end_slide -->

## Questions in Rules

> ast-grep picks the code; classif answers a question about it.

```bash +exec_replace
just digraph triage | awk '
{
  gsub(/metadata\.ask|fmt\.Errorf\(\.\.\.\)/, "\033[36m&\033[0m")
  gsub(/classif/, "\033[1;33m&\033[0m")
  gsub(/no: warning/, "\033[31m&\033[0m")
  gsub(/yes: cleared/, "\033[32m&\033[0m")
  print "  " $0
}'
paint
paint yellow '  Syntax finds every error message; the model judges what each one says.'
```

<!-- end_slide -->

## Rule with a Question

> metadata.ask carries the question; keep says which answer keeps the finding.

```file
path: rules/vague-error-message.yml
language: yaml
start_line: 1
end_line: 9
```

```bash +exec_replace
paint yellow '  The model reads the whole match; the bare string "fetch user: %w" scored no.'
```

<!-- end_slide -->

## Fix from the Tree

> The fix reads the function name from the tree, so the message says what failed.

```file
path: rules/vague-error-message.yml
language: yaml
start_line: 8
end_line: 26
```

```bash +exec_replace
paint yellow '  inside finds the enclosing function; has captures its name as $FN.'
```

<!-- end_slide -->

## Triage

> triage.sh asks classif about every match whose rule carries a question.

```bash +exec
ast-grep scan --json=stream --include-metadata --filter '^vague-' \
  example_bad.go example_bad.py | ./triage.sh
```

<!-- end_slide -->

## Confidence

> classif returns a probability, so messages rank from clear to vague.

```bash +exec
classif each "Does this error message tell a reader which operation failed?" \
  'fmt.Errorf("fetch user: %w", err)' \
  'fmt.Errorf("failed to marshal user: %v", err)' \
  'RuntimeError("fetch failed")' \
  'fmt.Errorf("bad status: %d", resp.StatusCode)' \
  'errors.New("something went wrong")'
```

<!-- end_slide -->

## Bridge

> A deterministic rule, a judgment of meaning, and a deterministic fix again.

```bash +exec_replace
just digraph bridge | awk '
{
  gsub(/ast-grep rule/, "\033[1;36m&\033[0m")
  gsub(/classif/, "\033[1;32m&\033[0m")
  gsub(/gra/, "\033[1;35m&\033[0m")
  gsub(/hint| no |fixed text/, "\033[38;2;128;128;128m&\033[0m")
  print "  " $0
}'
paint cyan '     syntax tree                 ' green 'local model                      ' magenta 'syntax tree'
paint
paint yellow '  The model adds meaning between two deterministic steps and replaces neither.'
```

<!-- end_slide -->

## Triage in Neovim

> Watch a hint become a verdict, then a fix on gra, then a verdict again.

```bash +exec_replace
paint cyan '  hint        ' plain 'ast-grep: every error message, judged or not'
paint cyan '  :Classif    ' plain 'asks the model; a confirmed message becomes a warning'
paint cyan '  gra         ' plain 'applies the rule'"'"'s fix; :Classif judges the result'
```

```bash +exec
./demo.sh triage
```

<!-- end_slide -->

## Triage Demo Result

```bash +exec_replace
paint green '  ✓  ' plain 'ast-grep marked both error messages as hints, unjudged'
paint green '  ✓  ' plain 'classif cleared line 23 and turned line 53 into a warning'
paint green '  ✓  ' plain 'gra applied the rule'"'"'s fix: fetchUser: bad status'
paint green '  ✓  ' plain 'the second :Classif cleared the fixed message'
paint
paint yellow '  The rule found and fixed the message; the model judged it both times.'
```

<!-- end_slide -->

## First Draft

> An AI drafted these rules. Running them checked the draft.

```bash +exec_replace
paint red '  ✗  ' cyan 'rules: list             ' plain 'ast-grep reads one rule per YAML document'
paint red '  ✗  ' cyan 'top-level pattern       ' plain 'patterns belong under rule:'
paint red '  ✗  ' cyan 'two-statement pattern   ' plain 'one node per pattern; follows relates two'
paint red '  ✗  ' cyan 'ignored-error           ' plain 'most hits were calls whose result was used'
paint green '  ✓  ' cyan 'intent and structure    ' plain 'right from the start, and still in use'
paint
paint yellow '  Each problem showed up the first time the tools ran.'
```

<!-- end_slide -->

## Division of Labor

> Each step goes to the tool that does it best.

```bash +exec_replace
paint cyan '  ast-grep    ' plain 'finds every candidate in milliseconds, the same way every run'
paint cyan '  classif     ' plain 'judges what a candidate means, on a local model'
paint cyan '  gra         ' plain 'applies the rule'"'"'s fix where the model confirmed a problem'
paint cyan '  AI          ' plain 'drafts rules from patterns in your code'
paint cyan '  you         ' plain 'choose which review comments become rules and questions'
paint
paint yellow '  Each tool adds to the next; none of them replaces another.'
```

<!-- end_slide -->

## Getting Started

> What do you need to try it?

```bash +exec_replace
./journey.sh 6
```

<!-- end_slide -->

## Install

> ast-grep 0.51 was used here.

```bash +exec_replace
paint cyan '  ast-grep   ' plain 'cargo install ast-grep --locked'
paint gray '             or npm i -g @ast-grep/cli, or brew install ast-grep'
paint cyan '  Neovim     ' plain '0.12 or newer for v an; nvim-lspconfig for the LSP'
paint cyan '  grug-far   ' plain 'optional, ast-grep search and replace in a buffer'
paint cyan '  classif    ' plain 'optional, needs Ollama and a local model; triage.sh uses jq'
paint
paint yellow '  On Linux, sg can be the group switch command: type ast-grep.'
```

<!-- end_slide -->

## Takeaways

```bash +exec_replace
paint green '  ✓  ' cyan 'syntax trees      ' plain 'one tree in Neovim and ast-grep; findings update as you type'
paint green '  ✓  ' cyan 'rule + question   ' plain 'syntax finds the code, a local model judges, gra fixes'
paint 'bold yellow' '  ▶  ' cyan 'next              ' plain 'turn a review comment into a rule, a question, and a fix'
```

<!-- end_slide -->

## Resources

```markdown
ast-grep rules:   https://ast-grep.github.io/guide/rule-config.html
Rule tests:       https://ast-grep.github.io/guide/test-rule.html
Playground:       https://ast-grep.github.io/playground.html
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
