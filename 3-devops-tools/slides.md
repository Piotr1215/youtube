---
theme: theme.json
author: Cloud-Native Corner 
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# 🛠️ The Swiss Army Knife of DevOps CLI Tools

```bash
~~~./intro.sh

~~~
```

---

## 🚀 Introduction

- DevOps involves juggling various command line tools
- Strong command of Linux tools is indispensable
- Right set of tools can be a game-changer
- We'll explore 3 essential Linux commands for DevOps

---

## 1. 📊 yq — Parsing and Modifying YAML

- Lightweight and portable command-line YAML processor
- Perfect for handling configuration files
- Two versions exist:
  1. Go-based yq (https://github.com/mikefarah/yq)  use this one
  2. Python-based yq (https://github.com/kislyuk/yq)

Check which version you're using:

```bash
yq --version
```

---

## 1.1 yq demo

```bash
tmux select-window -t 3-devops-tools:2
```

---

## 2. 🔍 sed and grep — Updating Configuration

- sed: Edit text in a scriptable manner
- grep or rg: Find patterns in files using regular expressions
- Powerful combination for text manipulation

Example:
```bash
tmux select-window -t 3-devops-tools:3
```

---

## 3. 🌐 curl — manipulating URLs

- Transfers data from or to a server
- Supports most protocols (HTTP, FTP, POP3)
- Essential for API testing and monitoring

Example:
```bash
tmux select-window -t 3-devops-tools:4
```

---

## 📚 Further Learning Resources

- Man pages, tldr, and cheat sheets
- Online tutorials and courses
- Practice regularly with real-world scenarios

---

## 📝 Summary

- Simplify day-to-day tasks and handle complex scenarios
- Enhance productivity and efficiency
- Continuous learning and practice are 🔑
