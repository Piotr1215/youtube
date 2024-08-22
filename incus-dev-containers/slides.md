---
theme: ./theme.json  
author: Cloud-Native Corner  
date: MMMM dd, YYYY  
paging: Slide %d / %d  
---

# Multi-Container Development Environment Using Incus

```bash
~~~./intro.sh

~~~
```

---

## Introduction

- 🔄 Flexible Development Setup
- 🌐 Portability Integration
- 🛠 Multi-Container Workflows

---

## Target Architecture

```bash
~~~just digraph overview
There must be empty line between the ~~~. It will be overriden by command
output. The `plugins` is the name of digraph diagram to render.
~~~
```
---


## Note on Security

> [!IMPORTANT]
> When exposing local docker host to the containers, make sure to add firewall rules
---

## Use Cases for Satellite Containers

- 🛠️ utility containers
- 💻 language specific containers
- 🗄️ databases, infrastructure
- 🧪 testing

---
## Demo time

```bash
tmux switchc -t incus-config-main
```

---

```bash
../thats_all_folks
```
