<!--
  Recording Options:
  - Live demo: Use demo.sh with tmux sessions for interactive presentations
  - VHS recording: Use 'just record tape_name' for polished GIFs/videos
  - See vhs/ directory for templates (kubectl-demo, nvim-demo, demo-template)
  - Tip: VHS recordings are great for consistent, repeatable demos and thumbnails
-->


```bash +exec_replace
echo "Agentic Coding Bag of Tricks" | figlet -f small -c -w 90
```

<!-- end_slide -->

## Vibe Coding with Claude: The Reality

> **Agentic tools** = AI that acts on your behalf, not just answers questions

```bash +exec_replace
cat << 'EOF' | ccze -m ansi
Personal Projects:
  ✓ Rapid prototyping
  ✓ Quick iterations
  ✓ Learning playground

Complex Projects:
  ✗ More hassle than help
  ✗ Coordination overhead
  ✗ Context management nightmare

The Truth:
  • Requires strict discipline
  • Needs constant tweaks and tricks
  • This presentation = how to make it work
EOF
```

<!-- end_slide -->

## The LLM Challenge

```bash +exec_replace
cat << 'EOF' | ccze -A -c keyword=yellow -c piped=red
LLMs are non-deterministic:
  • Same input → unpredictable outputs
  • Babysitting Claude = new kind of stressor
  • Managing behavior, not just writing code

Mitigation:
  You can't solve non-determinism
  But you can reduce it
EOF
```

<!-- end_slide -->

## Isolation: One Repo, One Session

```bash +exec_replace
cat << 'EOF' | ccze -A
TMUX Workflow:

backend-api/     → tmux session "api"    → Claude instance 1
docs/            → tmux session "docs"   → Claude instance 2
homelab/         → tmux session "lab"    → Claude instance 3

Each repo gets:
• Dedicated TMUX session
• Own Claude instance (no reuse)
• Clean context (no drift)
EOF
```

> **Rule**: Never reuse Claude across different repos in same session

<!-- end_slide -->

## Problem 1: One Size Doesn't Fit All

```bash +exec_replace
cat << 'EOF' | ccze -A
Writing tests ≠ writing docs ≠ backend API ≠ frontend React

Claude gives generic advice regardless of context

Same AI, different domains → mismatch
EOF
```

<!-- end_slide -->

## Solution 1: System Prompts

> **System prompts** = Custom instructions that shape Claude's behavior

```bash +exec_replace
cat << 'EOF' | ccze -A -c keyword=green -c dir=cyan
Project-specific prompts in ~/.claude/system-prompts/:

  backend-api-system-prompt.md
  technical-writing-system-prompt.md
  test-automation-system-prompt.md
  frontend-system-prompt.md

direnv auto-loads the right prompt per directory
EOF
```

<!-- end_slide -->

## System Prompt Example

```markdown
# Backend API Development

## Core Principles (Ranked)

1. **Read Source Code First** - Understand before suggesting changes
2. **Edit > Write** - Modify existing files, don't create new ones
3. **Test First** - Write tests before implementation
4. **Simple > Clever** - Obvious code over elegant abstractions
5. **No Features** - Only solve the stated problem
```

> **Result**: Claude follows project-specific rules automatically

<!-- end_slide -->

## direnv Configuration

```bash
# .envrc in your project directory
export CLAUDE_SYSTEM_PROMPT=~/.claude/system-prompts/backend-api.md

# Auto-load on cd
direnv allow
```

```markdown
When you cd into project directory:
  → direnv activates
  → CLAUDE_SYSTEM_PROMPT sets
  → Claude loads project behavior
```

<!-- end_slide -->

## System Prompt Switching

```bash +exec_replace
cat << 'EOF' | ccze -m ansi -c piped=yellow
Home Directory
│
├── backend-api/
│   ├── .envrc → backend-api.md
│   └── Claude: "Read source first, Edit > Write"
│
├── docs/
│   ├── .envrc → technical-writing.md
│   └── Claude: "Clear, concise, user-focused"
│
└── tests/
    ├── .envrc → test-automation.md
    └── Claude: "Test first, FIRST principles"
EOF
```

> **Magic**: Same Claude, different expertise per directory

<!-- end_slide -->

## Problem 2: Same Mistakes, Different Day

```bash +exec_replace
cat << 'EOF' | ccze -A -c keyword=red -c error=yellow
Session 1: "Don't add features I didn't ask for"

Session 2: Claude adds features you didn't ask for

Session 3: Same thing again

No memory = no improvement
EOF
```

<!-- end_slide -->

## Solution 2: Strike/Praise System

> Track what works in practice, create feedback loop for continuous improvement

```bash
# ~/.claude/scripts/__claude_score.sh
# During session - mark successes/failures
praise "read source code first - system prompt worked"
strike "added features despite CLAUDE.md saying don't"

# End of session - log to CSV
scoreboard

# Logs to: ~/.claude_performance_log.csv
# Format: timestamp,repo,action,reason,system_prompt,implemented
2025-01-20,backend-api,strike,"Created new file",backend-api.md,false
2025-01-21,backend-api,praise,"Used Edit tool",backend-api.md,true

# Later - Claude reads CSV and self-modifies prompts
```

<!-- end_slide -->

## Scoreboard Output

> Review strikes/praises, then update system prompts with learnings

```text
📁 Repository: backend-api
   Score: +3 (Strikes: 2, Praises: 5)
   System Prompts: backend-api-system-prompt.md
   ─────────────────────────────────────────
   ❌ 2025-01-20 [NOT IMPLEMENTED]
      Created new file instead of editing existing
   ✅ 2025-01-21 [NOT IMPLEMENTED]
      Used Edit tool correctly, read code first
```

<!-- end_slide -->

## The Feedback Loop

```bash +exec_replace
cat << 'EOF' | ccze -A
   ┌─────────────┐
   │ Claude Acts │
   └──────┬──────┘
          │
      Good/Bad?
          │
    ┌─────┴─────┐
    │           │
 Praise      Strike
    │           │
    └─────┬─────┘
          │
   Review Report
          │
  Update Prompts
          │
   Claude Learns
          │
          └──────> Loop back
EOF
```

> **Continuous improvement**: Real behavior drives prompt evolution

<!-- end_slide -->

## Problem 3: Expert Knowledge Gathering Dust

```bash +exec_replace
cat << 'EOF' | ccze -A -c keyword=magenta -c error=red
You built skills:
  • Testing patterns
  • API design guidelines
  • Docs style guides

Claude ignores them. Doesn't remember to check.

Expertise exists but goes unused
EOF
```

<!-- end_slide -->

## Solution 3: Skill Activation Sequence

> **Skills** = Reusable expertise; **Hooks** = Auto-activation before Claude acts

| Step | Action |
|------|--------|
| **Evaluate** | All skills: task relevant? YES/NO |
| **Activate** | Matching skills load immediately |
| **Act** | Only after loading expertise |

<!-- end_slide -->

## Hooks Configuration

> ~/.claude/settings.json defines when scripts run

```json
{
  "hooks": {
    "SessionStart": [{
      "type": "command",
      "command": "$HOME/.claude/scripts/__claude_session_start_hook.sh"
    }],
    "UserPromptSubmit": [{
      "type": "command",
      "command": "$HOME/.claude/scripts/__claude_skills_loader.sh"
    }],
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{"command": "mcp-write-lock-guard.sh"}]
    }]
  }
}
```

<!-- end_slide -->

## Problem 4: Repetitive Context Sharing

```bash +exec_replace
cat << 'EOF' | ccze -A
Every session starts from scratch:

Manual Context Loading:
  • Copy-paste git log
  • Explain current work
  • Share test failures
  • Describe cluster state
  • Repeat TODOs and open issues

Time sink:
  5-10 minutes per session just to get Claude up to speed

You become Claude's external memory, manually loaded every time
EOF
```

<!-- end_slide -->

## Solution 4: Session Hooks

> **Session hook** = Script that runs when Claude Code starts

```bash +exec_replace
cat << 'EOF' | ccze -A
__claude_session_start_hook.sh auto-injects:

  • Recent commits + changed files
  • Test results or CI/CD status
  • Open issues and TODO items
  • Cluster state (kubectl output)
  • Project-specific state

Result: Claude has full context. Zero manual work.
EOF
```

<!-- end_slide -->

## CLAUDE.md: Marker-Based Blocks

> Session hooks update dynamic sections, preserve manual insights

```bash +exec_replace
cat << 'EOF' | ccze -m ansi -c keyword=cyan -c numbers=yellow
CLAUDE.md structure:

<!-- BEGIN DYNAMIC: GIT_HISTORY -->
85d9b49 12 minutes ago: feat: add auth
  src/auth/middleware.ts
  src/auth/jwt.ts
<!-- END DYNAMIC: GIT_HISTORY -->

<!-- BEGIN DYNAMIC: CLUSTER_STATE -->
Nodes: 3 (all Ready)
Storage: Longhorn (24 volumes, 22 healthy)
GitOps: ArgoCD (18 apps, 16 synced)
<!-- END DYNAMIC: CLUSTER_STATE -->

Manual insights go outside markers
→ Hooks update ONLY inside markers
→ Hybrid: auto-refresh + human context
EOF
```

<!-- end_slide -->

## How It All Fits Together

```bash +exec_replace
cat << 'EOF' | ccze -A -c keyword=blue -c piped=green
┌─────────────────────────────────────────┐
│        SESSION LAYER                    │
│  direnv → prompts → hooks → context     │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│        EXECUTION LAYER                  │
│  user prompt → skill eval → activate    │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│        FEEDBACK LAYER                   │
│  observe → praise/strike → improve      │
└─────────────────────────────────────────┘
           ↑
           └──────── continuous loop
EOF
```

> **Integration**: Three layers working in harmony

<!-- end_slide -->

## Real Example: Session Hook

> Auto-inject recent activity on every session start

```bash
# ~/.claude/scripts/__claude_session_start_hook.sh
echo "DATE: $(date '+%Y-%m-%d')"

cat <<'EOF'
CORE PRINCIPLES:
• 80% READING/RESEARCH, 20% WRITING
• Every line of code must FIGHT for its right to exist
• NEVER add features not asked for
• Break tasks into subtasks, use todo lists
EOF

# Git recent changes
if command -v git &> /dev/null; then
  echo "=== RECENT CHANGES ==="
  git log -5 --pretty=format:"%h %ar: %s" --name-only --no-merges
fi

# Pending tasks from CLAUDE.md
if [[ -f CLAUDE.md ]]; then
  echo "=== OPEN TASKS ==="
  grep -E "^- \[ \]" CLAUDE.md || echo "No pending tasks"
fi
```

<!-- end_slide -->

## Session Hook Output

> Session starts with full context automatically injected

```text
=== RECENT CHANGES ===

85d9b49 12 minutes ago: feat: add authentication
  src/auth/middleware.ts
  src/auth/jwt.ts
  tests/auth.test.ts

=== OPEN TASKS ===
- [ ] Add rate limiting to API endpoints
- [ ] Update authentication docs
```

<!-- end_slide -->

## The ~/.claude Directory

> Central location for all customization

| Directory | What Lives There |
|-----------|------------------|
| `scripts/` | Session hooks, scoring system |
| `skills/` | Domain expertise (testing, API design, docs) |
| `system-prompts/` | Project-specific behavior files |
| `commands/` | Custom slash commands |
| `justfile` | Admin automation hub |

> **One place to rule them all**

<!-- end_slide -->

## Critical MCPs & Tools

> Essential tools that enhance Claude's capabilities

```bash +exec_replace
cat << 'EOF' | ccze -A
Essential MCP Servers:

1. Internet Search (CRITICAL)
   → Mitigates outdated commands
   → Latest Kubernetes/Helm info
   → Embedded in CLAUDE.md prompts

2. Obsidian (Knowledge vault)
   → Past solutions, patterns

3. Code Execution
   → Reusable script library

4. Memory
   → Long-term context

Design Kit: Forces testable artifacts (tests must pass)
EOF
```

<!-- end_slide -->

## Key Takeaways

> Four practices that make Claude consistently better over time

| Practice | Benefit |
|----------|---------|
| **System prompts** | Project-specific behavior |
| **Strike/praise** | Continuous improvement |
| **Skill activation** | Automatic domain expertise |
| **Session hooks** | Zero-effort context injection |

<!-- end_slide -->

## Resources & Next Steps

> Start with one practice, expand as you find patterns

| Resource |
|----------|
| Claude Code: claude.ai/code |
| MCP Protocol: modelcontextprotocol.io |
| Source: github.com/anthropics/claude-code |

<!-- end_slide -->

## Summary: The Bag of Tricks

```bash +exec_replace
cat << 'EOF' | ccze -A -c keyword=green -c numbers=cyan -c piped=yellow
The Reality:
  • Vibe coding with Claude = powerful but needs discipline
  • Works best for personal projects
  • Complex projects need systematic approach

Four Core Practices:

1. System Prompts (direnv)
   → Different expertise per directory
   → Auto-loaded, project-specific

2. Strike/Praise Scoring
   → Track what works/fails
   → Continuous improvement loop

3. Skill Activation (hooks)
   → Auto-load domain expertise
   → Mandatory evaluation sequence

4. Session Hooks
   → Zero-effort context injection
   → Dynamic CLAUDE.md updates

Result: Claude learns from experience, gets smarter over time
EOF
```

<!-- end_slide -->

# That's All Folks! 👋

```bash +exec_replace
just intro_toilet That\'s all folks!
```
