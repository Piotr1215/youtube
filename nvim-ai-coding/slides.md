---
theme: ./theme.json
author: Cloud-Native Corner
date: September 21, 2024
paging: Slide %d / %d
---

# A Practical Guide to AI-Assisted Coding in Neovim

```bash
~~~./intro.sh

~~~
```

---

## Introduction

- 🧠 Understanding AI-assisted coding in Neovim
- 🔧 Setting up AI coding assistants
- 💻 Practical usage and best practices
- 🚀 Answer questions if Neovim is still relevant in the age of AI
---

## What is AI-Assisted Coding?

- AI-assisted coding is like having a smart coding buddy.
- Suggests code completions, learns from vast codebases, and adapts to your style.
- Helps generate functions, write docs, and create algorithms.
- The goal ---> reduce repetitive tasks NOT to replace thinking!

---

## Popular AI Coding Assistants for Neovim

- `github/copilot.vim`: GitHub's AI pair programmer
- `jackMort/ChatGPT.nvim`: Integrate OpenAI's ChatGPT
- `robitx/gp.nvim`: GPT integration for Neovim
- `David-Kunz/gen.nvim`: AI code generation and editing
- `joshuavial/aider.nvim`: OOS coding assistant wrapper (no need for plugin)

---

## Practical Use Cases

### Code Completion (Copilot)
- Real-time suggestions as you type
- Completes functions, loops, and complex structures

```bash
tmux switchc -t copilot
```
---

### Code Rewriting and Chat (gp.nvim)
- Interactive chat for code explanations
- Rewrite and refactor code blocks

```bash
tmux switchc -t gp
```
---

### Local Models with Ollama (gen.nvim)
- Simple formatting and code suggestions
- Slower response times, works offline

```bash
tmux switchc -t ollama
```
---

### Advanced Coding Assistant (aider.nvim)
- Open terminal window inside Neovim to run Aider
- Comprehensive AI-powered coding assistance

```bash
tmux switchc -t aider
```
---

## Bonus

- chat from command line

```bash
gpt () {
        local input
        if [ -t 0 ]
        then
                input="$1"
        else
                input=$(cat | sed -r "s/\x1b\[[0-9;]*m//g")
        fi
        local tmpfile=$(mktemp /tmp/nvim_buffer_cleaned.XXXXXX)
        echo "$input" > $tmpfile
        nvim -c "GpChatNew" -c "call append(line('$')-1, readfile('$tmpfile'))" -c "normal! Gdd" -c "startinsert"
        rm -v $tmpfile
}
```

```bash
tmux switchc -t gpt-chat
```

---

## Best Practices and Conclusion

- 🔍 Review all AI suggestions carefully
- 🧠 Use AI after you understand the problem
- 🔄 Leverage AI for repetitive tasks and boilerplate code
- 📖 Use AI to explain complex code blocks

---

```bash
../thats_all_folks
```
