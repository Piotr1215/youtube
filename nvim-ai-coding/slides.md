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
- 🚀 Enhancing productivity while maintaining code quality

---

## What is AI-Assisted Coding?

- Uses machine learning models to suggest code completions
- Learns from vast codebases and your own coding style
- Can generate entire functions, documentation, or complex algorithms
- Aims to speed up development and reduce repetitive tasks

---


## Popular AI Coding Assistants for Neovim

- `github/copilot.vim`: GitHub's AI pair programmer
- `jackMort/ChatGPT.nvim`: Integrate OpenAI's ChatGPT
- `robitx/gp.nvim`: GPT integration for Neovim
- `David-Kunz/gen.nvim`: AI code generation and editing
- `joshuavial/aider.nvim`: OOS coding assistant wrapper

---

## Practical Use Cases

1. Code Completion (Copilot)
   - Real-time suggestions as you type
   - Completes functions, loops, and complex structures

2. Code Rewriting and Chat (gp.nvim)
   - Interactive chat for code explanations
   - Rewrite and refactor code blocks

3. Local Models with Ollama (gen.nvim)
   - Simple formatting and code suggestions
   - Slower response times, works offline

4. Advanced Coding Assistant (aider.nvim)
   - Open terminal window inside Neovim to run Aider
   - Comprehensive AI-powered coding assistance

---

## Best Practices

1. Review all AI suggestions carefully
2. Use AI for inspiration, not blind acceptance
3. Maintain consistent coding style and standards
4. Leverage AI for repetitive tasks and boilerplate code
5. Combine AI suggestions with your domain knowledge
6. Use AI to explore alternative implementations

---

## Customizing AI Behavior

```lua
-- Example: Customizing Copilot behavior
vim.g.copilot_node_command = "/usr/local/n/versions/node/14.18.2/bin/node"

-- Disable Copilot for specific filetypes
vim.g.copilot_filetypes = {
    ["markdown"] = false,
    ["yaml"] = false,
}

-- Change suggestion accept key
vim.api.nvim_set_keymap("i", "<C-L>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
```

---

## Troubleshooting Common Issues

1. Ensure Neovim is updated to the latest version
2. Check plugin compatibility with your Neovim version
3. Verify API keys and authentication for AI services
4. Monitor system resources (AI can be computationally intensive)
5. Adjust suggestion frequency if overwhelmed
6. Regularly update AI plugins for best performance

---

## Conclusion

- AI-assisted coding can significantly boost productivity
- Proper setup and usage in Neovim is key to success
- Balance AI suggestions with human oversight
- Continuously refine your AI-assisted workflow

---

```bash
../embrace_ai_coding
```
</markdown_slides>
