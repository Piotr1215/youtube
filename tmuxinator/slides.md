---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Tmuxinator 🚀

```bash
~~~just intro_toilet Manage Tmux

~~~
```

---

## Introduction

- 🎯 Define complex tmux sessions with simple YAML configs
- 🔧 Automate repetitive terminal setup and window arrangements
- 📝 Create consistent development environments across machines
- 🔄 Share configurations with your team

---

## What is Tmuxinator? 🤔

> Tmuxinator is a Ruby gem that allows you to effortlessly manage complex tmux sessions

---

## Installation 📦

```bash
# Via RubyGems (recommended)
gem install tmuxinator

# Via Homebrew
brew install tmuxinator

# Shell completion for zsh
wget https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh \
  -O /usr/local/share/zsh/site-functions/_tmuxinator
```

---

## Basic Commands 🛠️

```bash
tmuxinator new project-name

tmuxinator start project-name

tmuxinator list

tmuxinator edit project-name

tmuxinator copy old-project new-project

tmuxinator delete project-name
```

---

## Config File ⚙️

```yaml
name: myproject
root: ~/projects/myproject

windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - git status
  - server: npm start
  - logs: tail -f logs/development.log
```

---

## Layout Options 📐


- even-vertical:   *Panes are spread evenly from top to bottom*
- main-horizontal: *Large pane at top, smaller panes below*
- main-vertical:   *Large pane at left, smaller panes to the right*
- tiled:           *Panes arranged in grid pattern*
- custom:          *Custom splits*

---

## Advanced Configuration 🧠

```yaml
# Pre-window commands (environment setup)
pre_window: nvm use 18

# Project hooks
on_project_start: npm install
on_project_exit: docker-compose down

# Window-specific root directories
windows:
  - frontend:
      root: ~/projects/myproject/frontend
      panes:
        - npm start
  - backend:
      root: ~/projects/myproject/backend
      panes:
        - npm start
```

---

## The Power of ERB 💎

> ERB embeds Ruby code in text documents for dynamic content generation.

```yaml
# Use environment variables
root: <%= ENV["PROJECT_PATH"] %>

# Access command line arguments
# tmuxinator start myproject api
root: ~/projects/<%= @args[0] %>

# Named parameters
# tmuxinator start myproject env=staging
environment: <%= @settings["env"] || "development" %>
```

---

## Project Workflow 🌊

```bash
~~~just plantuml tmuxinator-flow

~~~
```

---

## Real World Example: Development 💻

```bash
tmux switchc -t demo
```


---

## Tips & Best Practices 💡

- Use aliases for faster access (`alias tx="tmuxinator"`)
- Create project templates for similar setups
- Use local configs (`.tmuxinator.yml`) for project-specific setups
- Place common commands in shell scripts to avoid command corruption

---

## Resources 📚

- Official Repository: [github.com/tmuxinator/tmuxinator](https://github.com/tmuxinator/tmuxinator)
- Documentation: [github.com/tmuxinator/tmuxinator#readme](https://github.com/tmuxinator/tmuxinator#readme)
- Tmux Manual: [man.openbsd.org/tmux](https://man.openbsd.org/tmux)
- Tmux Cheat Sheet: [tmuxcheatsheet.com](https://tmuxcheatsheet.com)

---

# That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```
