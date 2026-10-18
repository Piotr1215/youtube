grep, ast-grep and a local LLM each read code at a different level: text, structure and meaning. Which one fits which code change?

The example is a change many Go teams face: moving a service from log.Printf to structured logging with log/slog. Each tool takes the part of the job it can see, and the video shows where each one stops.

This video covers:
- Text search (grep): finds every log.Printf, but misses a call split over two lines and matches one inside a comment
- Syntax trees (:InspectTree): see code the way your editor parses it
- ast-grep patterns: search the tree by writing code with placeholders
- Rules: a search and its rewrite in one YAML file you can commit
- Where rules stop: lines with the same shape that need different fixes
- classif: a local model answers one question about each match, from a fixed list of answers
- Probabilities and thresholds: when to apply a fix, and when to leave the line for a person
- A second question that holds back the fix when a value may be a secret or personal data
- A decision matrix: when a change needs a rule, and when it needs a model's judgment
- LLMs as building blocks between deterministic steps

The rules need only ast-grep. The classif part runs Ollama with a local model, so your code stays on your machine.

Presentation: https://github.com/Piotr1215/youtube/blob/main/nvim-luasnip-ai-alternative/presentation.md
Rules: https://github.com/Piotr1215/youtube/tree/main/nvim-luasnip-ai-alternative/rules
classif: https://github.com/Piotr1215/classif
ast-grep rules: https://ast-grep.github.io/guide/rule-config.html
ast-grep playground: https://ast-grep.github.io/playground.html
log/slog: https://pkg.go.dev/log/slog
Dotfiles: https://github.com/Piotr1215/dotfiles

00:00 - Introduction: Why Abstract Syntax Trees (AST)?
00:25 - Motivating Example: Go Logging Syntax
02:00 - Text-Based Search: grep & ripgrep Limitations
04:38 - Visualizing Syntax Trees in Neovim
06:38 - AST as Code Patterns
07:33 - Structural Search with ast-grep
08:44 - Search & Replace: Codifying ast-grep Rules
11:10 - Limitations of Deterministic Rules
11:59 - Adding Semantic Meaning with Local LLM (classif)
13:31 - Triaging Logs: Debug Noise vs. Useful Info
15:40 - Classification Probabilities & Thresholds
16:44 - Integrating ast-grep Rules with Local LLM
18:42 - CLI Demo: Classifying Logs & Detecting Sensitive Data
22:12 - Decision Matrix: When to Use Rules vs. LLMs
24:07 - Key Takeaways: LLMs as Foundational Building Blocks
26:43 - Tool Setup & Resources
27:14 - Final Thoughts & Wrap-up
