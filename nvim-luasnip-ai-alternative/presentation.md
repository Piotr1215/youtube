# Code Intelligence

> Flag repeat mistakes and type the fix, locally, in milliseconds

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

## Text and Tree

> ast-grep matches the syntax tree, not the characters.

```bash +exec
code='if err != nil { return nil, err }'
echo "$code" | ast-grep run --stdin -l go --debug-query=ast -p "$code"
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
paint 'bold cyan' '  sgconfig.yml' gray ' ──▶ ' 'bold cyan' 'ast-grep lsp' gray ' ──▶ ' 'bold yellow' 'Neovim'
paint
paint cyan '  diagnostics    ' plain 'every rule, inline in the buffer'
paint cyan '  code actions   ' plain 'each fix: on gra'
paint cyan '  setup          ' plain 'vim.lsp.enable("ast_grep"), config from nvim-lspconfig'
```

```bash +exec +acquire_terminal
nvim -u demo-init.lua example_bad.go
```

<!-- end_slide -->

## LuaSnip Snippets

> How do you type the fix the rule asks for?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## Snippet Nodes

> iferr expands, then Tab jumps between the parts you fill in.

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

## Snippet Source

> fmt() keeps the snippet readable as the Go it produces.

```file
path: luasnip-go-errors.lua
language: lua
start_line: 15
end_line: 29
```

<!-- end_slide -->

## Snippet Demo

> Replace a bare return with iferr and watch its warning go.

```bash +exec_replace
paint cyan '  iferr Tab   ' plain 'expand the snippet'
paint cyan '  Tab         ' plain 'next field, Shift-Tab goes back'
paint cyan '  Ctrl-J      ' plain 'cycle the choice node'
```

```bash +exec +acquire_terminal
nvim -u demo-init.lua example_bad.go
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

## AI in the Loop

> Where does a model earn its place?

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

## Semantic Checks

> ast-grep reads syntax; a local model can answer what syntax cannot.

```bash +exec_replace
paint cyan '  ast-grep  ' gray 'line 27  ' plain 'logActivity(...): check whether this call returns an error'
```

```bash +exec
rg -A3 'func logActivity' example_bad.go |
  classif "does this Go function declare error as a return type?"
```

<!-- end_slide -->

## Division of Labor

> Each step goes to the tool that does it best.

```bash +exec_replace
paint cyan '  AI          ' plain 'drafts rules and snippets from patterns in your code'
paint cyan '  ast-grep    ' plain 'checks a file in milliseconds, the same way every run'
paint cyan '  LuaSnip     ' plain 'types the fix in the shape the rules expect'
paint cyan '  classif     ' plain 'answers yes or no questions on a local model'
paint cyan '  you         ' plain 'write the context each error message needs'
paint
paint yellow '  Rules and snippets need no model; a local one adds judgment.'
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
paint cyan '  Neovim     ' plain '0.11 or newer, with nvim-lspconfig'
paint cyan '  classif    ' plain 'optional, needs Ollama and a local model'
paint
paint yellow '  On Linux, sg can be the group switch command: type ast-grep.'
```

<!-- end_slide -->

## Project Layout

> sgconfig.yml marks the root for scan, test, and the LSP.

```bash +exec_replace
tree --noreport -I '__snapshots__' -P '*.yml' --prune . | sed 's/^/  /'
paint
paint green '  ✓ ast-grep new project scaffolds the same layout'
```

<!-- end_slide -->

## Takeaways

```bash +exec_replace
paint green '  ✓  ' cyan 'repeat checks   ' plain 'a rule flags them in milliseconds, no model call'
paint green '  ✓  ' cyan 'repeat fixes    ' plain 'a snippet types them the same way every time'
paint 'bold yellow' '  ▶  ' cyan 'next            ' plain 'turn your most repeated review comment into a rule'
```

<!-- end_slide -->

## Resources

```markdown
ast-grep rules:   https://ast-grep.github.io/guide/rule-config.html
Rule tests:       https://ast-grep.github.io/guide/test-rule.html
Playground:       https://ast-grep.github.io/playground.html
LuaSnip:          https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
classif:          https://github.com/Piotr1215/classif
Channel:          youtube.com/@cloud-native-corner
```

<!-- end_slide -->

# That's All Folks! 👋

```bash +exec_replace
just intro_toilet That\'s all folks!
```
