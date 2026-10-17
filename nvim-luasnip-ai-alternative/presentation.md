# Code Intelligence

> Syntax trees and snippets first, then AI on top

<!-- new_lines: 3 -->

```bash +exec_replace
echo "ast-grep + LuaSnip" | figlet -f small -w 90
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
paint yellow '  A rule could leave that comment, and a snippet could type the fix.'
```

<!-- end_slide -->

## Building Blocks

> Find the mistake, type the fix, and ask a model only what syntax cannot tell.

```bash +exec_replace
just digraph building-blocks | awk '
{
  gsub(/syntax tree/, "\033[1;33m&\033[0m")
  gsub(/ast-grep rule/, "\033[1;36m&\033[0m")
  gsub(/LuaSnip snippet/, "\033[1;35m&\033[0m")
  gsub(/classif/, "\033[1;32m&\033[0m")
  gsub(/fix$|unsure/, "\033[90m&\033[0m")
  print "  " $0
}'
```

<!-- end_slide -->

## First Look

> One scan flags every error-handling problem in the file.

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

## Parsing

> A parser reads code into nested parts, like clauses in a sentence.

```bash +exec_replace
just digraph parsing | awk '
{
  gsub(/tree-sitter|syntax tree/, "\033[1;33m&\033[0m")
  gsub(/Neovim|ast-grep/, "\033[1;36m&\033[0m")
  gsub(/:InspectTree|patterns/, "\033[35m&\033[0m")
  print "  " $0
}'
paint
paint yellow '  Neovim and ast-grep both parse with tree-sitter, one grammar per language.'
```

<!-- end_slide -->

## Syntax Tree

> Kinds name each node; fields name its parts.

```bash +exec_replace
just digraph syntax-tree | awk '
{
  gsub(/if_statement|binary_expression|block|return_statement|identifier/, "\033[1;36m&\033[0m")
  gsub(/consequence|condition|left|right/, "\033[1;33m&\033[0m")
  if ($0 ~ /^│ +nil +│$/) gsub(/nil/, "\033[1;36m&\033[0m")
  print "  " $0
}'
paint
paint yellow '  Rules name both: kind: if_statement, field: condition.'
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

## Tree in Neovim

> Neovim shows the tree it parsed and selects code by it.

```bash +exec_replace
paint cyan '  :InspectTree   ' plain 'the buffer'"'"'s syntax tree, beside the code'
paint cyan '  j / k          ' plain 'walk the nodes; the code under each one lights up'
paint cyan '  v an           ' plain 'select the node at the cursor, then each parent'
```

```bash +exec
./demo.sh tree
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

> grug-far runs ast-grep as you type and lists the matches in a buffer.

```bash +exec
./demo.sh search
```

<!-- end_slide -->

## ast-grep Rules

> How does a review comment become a rule?

```bash +exec_replace
./journey.sh 3
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
  gsub(/an ancestor|the statement before|a descendant/, "\033[90m&\033[0m")
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

## Editor Diagnostics

> The same rules, inside the editor.

```bash +exec_replace
just digraph editor-lsp | awk '
{
  gsub(/rules\/\*\.yml|sgconfig\.yml/, "\033[36m&\033[0m")
  gsub(/ast-grep lsp/, "\033[1;33m&\033[0m")
  gsub(/Neovim/, "\033[1;36m&\033[0m")
  gsub(/diagnostics|code actions|gra/, "\033[35m&\033[0m")
  print "  " $0
}'
paint
paint yellow '  vim.lsp.enable("ast_grep"), with the config from nvim-lspconfig.'
```

```bash +exec
./demo.sh diagnostics
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

## LuaSnip Snippets

> How do you type the fix the rule asks for?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## Snippet Expansion

> M-l looks up the word before the cursor and expands the snippet it names.

```bash +exec_replace
just digraph snippet-expansion | awk '
{
  gsub(/iferr/, "\033[1;33m&\033[0m")
  gsub(/M-[lj]/, "\033[1;35m&\033[0m")
  gsub(/go snippets|top priority|fields|next|choice|done/, "\033[36m&\033[0m")
  print "  " $0
}'
paint
paint yellow '  Typing over a selected field replaces it; M-l keeps its default.'
```

<!-- end_slide -->

## Snippet Nodes

> iferr expands into three fields, and rep(1) copies the first.

```bash +exec_replace
paint plain '  if ' 'bold yellow' 'err' plain ' != nil {'
paint plain '      return ' 'bold magenta' 'nil, ' plain 'fmt.Errorf("' 'bold cyan' 'failed to process' plain ': %w", ' yellow 'err' plain ')'
paint plain '  }'
paint
paint 'bold yellow' '  1  ' cyan 'insert node   ' plain 'the error name'
paint 'bold magenta' '  2  ' cyan 'choice node   ' plain '"nil, " or nothing, for single-value returns'
paint 'bold cyan' '  3  ' cyan 'insert node   ' plain 'the context the error message needs'
paint yellow '     ' cyan 'rep(1)        ' plain 'repeats node 1 as you type it'
```

<!-- end_slide -->

## Snippet Demo

> Replace a bare return with iferr and watch its warning go.

```bash +exec_replace
paint cyan '  iferr M-l   ' plain 'expand the snippet'
paint cyan '  M-l / M-h   ' plain 'next field, previous field'
paint cyan '  M-j         ' plain 'cycle the choice node'
```

```bash +exec
./demo.sh snippet
```

<!-- end_slide -->

## Rules Meet Snippets

> The snippet writes exactly what the rules ask for.

```bash +exec_replace
just boxart local-loop | sed 's/^/  /'
paint
paint green '  ✓ every snippet expansion passes every rule'
```

<!-- end_slide -->

## Python and Bash Snippets

> Same s(), i() and c() nodes; only the filetype changes.

```bash +exec_replace
paint 'bold yellow' '  tryr     ' plain 'try, except OSError as err, raise ... from err'
paint 'bold yellow' '  strict   ' plain 'bash shebang, then set -euo pipefail'
paint 'bold yellow' '  curlf    ' plain 'curl --fail --silent --show-error --location'
paint
paint green '  ✓ ast-grep scan finds nothing in any of the three expansions'
```

<!-- end_slide -->

## AI on Top

> What does a model add once trees and snippets do the repeat work?

```bash +exec_replace
./journey.sh 5
```

<!-- end_slide -->

## First Draft

> An AI drafted these rules and snippets. Running them checked the draft.

```bash +exec_replace
paint red '  ✗  ' cyan 'rules: list             ' plain 'ast-grep reads one rule per YAML document'
paint red '  ✗  ' cyan 'top-level pattern       ' plain 'patterns belong under rule:'
paint red '  ✗  ' cyan 'two-statement pattern   ' plain 'one node per pattern; follows relates two'
paint red '  ✗  ' cyan 'ignored-error           ' plain 'most hits were calls whose result was used'
paint red '  ✗  ' cyan 'restoreNode(1)          ' plain 'nil in LuaSnip; rep(1) repeats a node'
paint green '  ✓  ' cyan 'intent and structure    ' plain 'right from the start, and still in use'
paint
paint yellow '  Each problem showed up the first time the tools ran.'
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

## Triage

> The question lives in the rule, next to the pattern it asks about.

```file
path: rules/vague-error-message.yml
language: yaml
```

```bash +exec
ast-grep scan --json=stream --include-metadata \
  -r rules/vague-error-message.yml example_bad.go | ./triage.sh
```

<!-- end_slide -->

## Triage in Neovim

> Hints from ast-grep, verdicts from the model, in one buffer.

```bash +exec_replace
paint cyan '  hint        ' plain 'ast-grep: every error message, judged or not'
paint cyan '  :Classif    ' plain 'runs triage.sh; a confirmed message becomes a warning'
```

```bash +exec
./demo.sh triage
```

<!-- end_slide -->

## Division of Labor

> Each step goes to the tool that does it best.

```bash +exec_replace
paint cyan '  AI          ' plain 'drafts rules and snippets from patterns in your code'
paint cyan '  ast-grep    ' plain 'checks a file in milliseconds, the same way every run'
paint cyan '  LuaSnip     ' plain 'types the fix in the shape the rules expect'
paint cyan '  classif     ' plain 'judges each match a rule asks it about'
paint cyan '  you         ' plain 'write the context each error message needs'
paint
paint yellow '  Trees and snippets do the repeat work; the model answers the rest.'
```

<!-- end_slide -->

## Getting Started

> What do you need to try it?

```bash +exec_replace
./journey.sh 6
```

<!-- end_slide -->

## Install

> ast-grep 0.51 and LuaSnip 2.5 were used here.

```bash +exec_replace
paint cyan '  ast-grep   ' plain 'cargo install ast-grep --locked'
paint gray '             or npm i -g @ast-grep/cli, or brew install ast-grep'
paint cyan '  LuaSnip    ' plain '{ "L3MON4D3/LuaSnip", version = "v2.*" }'
paint cyan '  Neovim     ' plain '0.12 or newer for v an; nvim-lspconfig for the LSP'
paint cyan '  grug-far   ' plain 'optional, ast-grep search and replace in a buffer'
paint cyan '  classif    ' plain 'optional, needs Ollama and a local model; triage.sh uses jq'
paint
paint yellow '  On Linux, sg can be the group switch command: type ast-grep.'
```

<!-- end_slide -->

## Takeaways

```bash +exec_replace
paint green '  ✓  ' cyan 'syntax trees    ' plain 'a rule flags a repeat mistake in milliseconds'
paint green '  ✓  ' cyan 'snippets        ' plain 'the fix arrives in the same shape every time'
paint 'bold yellow' '  ▶  ' cyan 'next            ' plain 'put a model on top for what syntax cannot answer'
```

<!-- end_slide -->

## Resources

```markdown
ast-grep rules:   https://ast-grep.github.io/guide/rule-config.html
Rule tests:       https://ast-grep.github.io/guide/test-rule.html
Playground:       https://ast-grep.github.io/playground.html
LuaSnip:          https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
grug-far:         https://github.com/MagicDuck/grug-far.nvim
Tree selection:   :help treesitter-incremental-selection
classif:          https://github.com/Piotr1215/classif
Channel:          youtube.com/@cloud-native-corner
```

<!-- end_slide -->

# That's All Folks! 👋

```bash +exec_replace
just intro_toilet That\'s all folks!
```
