---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM, YYYY
paging: Slide %d / %d
---

# MCP Agentic Framework 🤖

```bash
~~~just intro_toilet MCP Agentic Framework

~~~
```

---

## What is MCP? 🤔

```bash
~~~just digraph mcp-overview

~~~
```

**Model Context Protocol**  *Standard for AI-tool integration*

---

## MCP Architecture 🏗️

```bash
~~~just digraph mcp-components

~~~
```

---

## MCP Basic Capabilities 🎯

**Tools** 🔧           *Executable actions (file ops, API calls)*

**Resources** 📂       *Context and data (files, configs)*

**Prompts** 📝         *Templated workflows*

---

## The Problem ❌

```bash
              ❌
  ┌╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴╴┐
  ╵                                    ╵
┌───────────┐      ┌──────────┐      ┌──────────┐
│ Claude 1  │  ❌  │ Claude 2 │  ❌  │ Claude 3 │
│ Developer │ ╴╴╴╴ │  Tester  │ ╴╴╴╴ │ Reviewer │
└───────────┘      └──────────┘      └──────────┘
```

**Issue**: Claude sessions can't talk to each other!

---

## The Solution ✅

```bash
~~~just digraph agentic-solution

~~~
```

**Agentic Framework**: Multi-agent communication via MCP

---

## Agent Communication Protocol 💓

**No Polling or Webhooks**: Agents must stay conscious!

```bash
# The Heartbeat Pattern:
sleep 5              # BEAT! 💓
check-for-messages   # Stay aware
sleep 5              # BEAT! 💓
discover-agents      # Who's here?
sleep 5              # BEAT! 💓
send-broadcast       # Communicate
```

**Agents read how-to guide**  *No self-wake possible*

---

## How It Works 🔧

```bash
# 1. Start the server
npm run start:http

# 2. Configure Claude  
~/.claude/settings.json

# 3. Launch agents with slash commands:
/norm-agent name desc    # Generic worker agent
/norm-leader name desc   # Task coordinator agent  
/norm-custodian          # Knowledge keeper (fat-owl)
```

**Key**: Name shapes personality!  *"agent1" vs "tester"*  
**Agent = Name + Description**  *Initial prompt defines behavior and goals*

---

## Message Flow 📨

```bash
~~~just plantuml message-flow

~~~
```

---

## Messaging Types 💬

**Direct** 🔒          *Private agent-to-agent*

**Broadcast** 📢       *Message all agents*

**Priority**:         `low` | `normal` | `high`

---

## Agents Can Be Anything! 🎭

**Agent ≠ Person**  *Think bigger!*

```
Examples of what agents can embody:
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  Tech Support   │  │     France      │  │ Angry Customers │
│  (whole team)   │  │  (country POV)  │  │ (user personas) │
└─────────────────┘  └─────────────────┘  └─────────────────┘

┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ Legal Department│  │   The 1990s     │  │  Quality Gate   │
│   (compliance)  │  │ (time period)   │  │   (process)     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

**Power**: Anthropomorphize concepts, not just people!

---

## Plug & Play Patterns 🔌

**Key concept**: Add/remove agents anytime!  *No dependencies*

**✅ Domain Agents**: Specialized experts on-demand  
**✅ Transfer Pattern**: Split complex tasks → Independent work

```
Transfer Pattern - Real Example:
1. Backend agent working on MCP → "Backend + UI is too much!"
2. Spawn UI agent in NEW tmux session → "Take the frontend"
3. Both work independently in separate sessions
4. Need collaboration? Register both → Instant teamwork!
5. Done collaborating? Disconnect → Back to solo work

Divide & conquer: Each owns their piece completely
```

---

## Tmux Setup 💻

```
┌──────────────┬──────────────┬──────────────┐
│   Pane 1     │   Pane 2     │   Pane 3     │
│  Developer   │   Tester     │  Reviewer    │
├──────────────┴──────────────┴──────────────┤
│        🔄 sync-panes: ON                   │
└────────────────────────────────────────────┘
```

**Pro tip**: `Ctrl-b :setw synchronize-panes`  *Broadcast to all*

---

## Demo Time! 🎮

**Demo**: Agents enact a scene together!

**Watch for**:
- `discover-agents`         *Who's online?*
- Heartbeat rhythm          *sleep 5 = staying alive*
- Natural role emergence    *Context shapes behavior*
- Web UI at localhost:3113  *Real-time visualization*

---

# That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```

**GitHub**: `github.com/Piotr1215/mcp-agentic-framework`
