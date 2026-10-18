grep, ast-grep and a local LLM each read code at a different level: text, structure and meaning. Which one fits which code change?

The example is a change many Go teams face: moving a service from log.Printf to structured logging with log/slog. Each tool takes the part of the job it can see, and the video shows where each one stops.

This video covers:
- Text search (grep): finds every log.Printf, but misses a call split over two lines and matches one inside a comment
- Syntax trees (:InspectTree): see code the way your editor parses it
- ast-grep patterns: search the tree by writing code with placeholders
- Rules: a search, its rewrite and its tests in one YAML file you can commit
- ast-grep in Neovim: the language server flags each match as you type, with the fix one code action away
- A rule an AI drafts from one sentence, checked by running its tests
- classif: a local model answers one question about each match, from a fixed list of answers
- A second question that holds back the fix when a value may be a secret or personal data
- Limits: ask the model about what the code shows, never about what its author meant
- When a change needs a rule, and when it needs a model's judgment

The rules need only ast-grep, from the shell or in Neovim. The classif part runs Ollama with a local model, so your code stays on your machine.

Presentation: https://github.com/Piotr1215/youtube/blob/main/nvim-luasnip-ai-alternative/presentation.md
Rules: https://github.com/Piotr1215/youtube/tree/main/nvim-luasnip-ai-alternative/rules
classif: https://github.com/Piotr1215/classif
ast-grep rules: https://ast-grep.github.io/guide/rule-config.html
ast-grep playground: https://ast-grep.github.io/playground.html
log/slog: https://pkg.go.dev/log/slog
Dotfiles: https://github.com/Piotr1215/dotfiles
