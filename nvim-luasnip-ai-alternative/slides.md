---
theme: ../theme.json
author: Cloud Native Corner
date: May, 2025
paging: Slide %d / %d
---

# Code Intelligence with LuaSnip and ast-grep

```bash
~~~just intro_toilet Developer Tools

~~~
```

> Building efficient workflows with semantic understanding

---

## The Problem

- Repetitive code patterns:         *Same boilerplate daily*
- Context switching:                *Leave editor for searches*
- Manual refactoring:               *Error-prone transformations*
- Generic tooling:                  *Not adapted to your codebase*

---

## LuaSnip: Beyond Simple Snippets

Core node types:
- TextNode:                    *Static text insertion*
- InsertNode:                  *Tab-stop navigation*
- FunctionNode:                *Dynamic content generation*
- ChoiceNode:                  *Multiple expansion options*
- DynamicNode:                 *Context-aware generation*

> Programmable text expansion engine

---

## LuaSnip Advanced Features

- Regex triggers:              *Pattern-based expansion*
- Nested snippets:             *Compose complex structures*
- Transformations:             *Modify captured text*
- Environment variables:       *Access buffer context*
- Callback events:             *Hook into expansion lifecycle*

---

## ast-grep: Semantic Code Search

Pattern matching types:
- Atomic rules:                *Basic node matching*
- Relational rules:            *Check node surroundings*
- Composite rules:             *Logical rule combination*
- Meta variables:              *Capture and transform*

> CSS selectors for your AST

---

## ast-grep Rule Configuration

```yaml
id: error-handling-pattern
language: go
rule:
  pattern: |
    if $ERR != nil {
      return $$$ARGS
    }
  inside:
    kind: function_declaration
```

---

## LSP Integration

ast-grep as Language Server:
- Custom diagnostics:          *Project-specific rules*
- Code actions:                *Automated fixes*
- Real-time feedback:          *Instant validation*
- Multi-language:              *Unified tooling*

```bash
ast-grep lsp
```

---

## The Workflow

```
~~~just plantuml code-intelligence-flow

~~~
```

---

## Demo: Error Handling Patterns

```bash
tmux switchc -t demo
```

What we'll demonstrate:
- LuaSnip dynamic error wrapping
- ast-grep pattern detection
- LSP diagnostics in action

---

## Installation

```bash
# ast-grep
brew install ast-grep
cargo install ast-grep --locked

# LuaSnip
use {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp"
}
```

---

## Performance Benefits

- Zero network latency:        *Everything runs locally*
- Instant feedback:            *No round trips*
- Pattern consistency:         *Team conventions enforced*
- Privacy by default:          *Code never leaves machine*

Bonus: AI can help generate initial patterns

---

## Resources

- [LuaSnip Documentation](https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md)
- [ast-grep Guide](https://ast-grep.github.io)
- [LSP Specification](https://microsoft.github.io/language-server-protocol/)
- [Tree-sitter Playground](https://tree-sitter.github.io/tree-sitter/playground)

---

# That's All Folks!

```bash
~~~just intro_toilet Happy Coding!

~~~
```

> Master your tools, master your code
