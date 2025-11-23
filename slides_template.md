---
title: Replace Me
author: Cloud Native Corner
date: 2025-01-31
---

<!--
  Recording Options:
  - Live demo: Use demo.sh with tmux sessions for interactive presentations
  - VHS recording: Use 'just record tape_name' for polished GIFs/videos
  - See vhs/ directory for templates (kubectl-demo, nvim-demo, demo-template)
  - Tip: VHS recordings are great for consistent, repeatable demos and thumbnails

  Formatting Best Practices:
  - Use `> Quote` for SINGLE LINE emphasis only
  - Multi-line content → use code blocks (```markdown)
  - Use tables for sequences, steps, or comparisons
  - figlet: Always use `-c -w 90` for centered ASCII art
  - Images: Add with ![alt](./path.png) for visual appeal
  - End every slide with `<!-- end_slide -->`

  Centering Text (BEST → WORST):

  1. **BEST - Heredoc with ccze** (most elegant, colorized):
     ```bash +exec_replace
     cat << 'EOF' | ccze -A
     Your centered text here
     Multiple lines supported
     EOF
     ```

  2. **GOOD - Markdown code block** (simple, clean):
     ```markdown
     Your centered text
     ```

  3. **AVOID - Blockquotes for multi-line** (inconsistent):
     > Don't use blockquotes for multiple lines
     > Use them only for single-line emphasis

  Rules:
  - AVOID sandwich pattern: blockquote → code block → blockquote
  - Blockquotes (>) are for single-line emphasis ONLY
-->

# Replace Me

> Replace with your subtitle

```bash +exec_replace
echo "Your Title Here" | figlet -f small -c -w 90
```

<!-- end_slide -->

## Problem: Describe the Challenge

> Use blockquote to emphasize the key pain point

```bash +exec_replace
cat << 'EOF' | ccze -A
Explain the problem. This is the most elegant way.

Multiple lines supported with beautiful colorization.

Heredoc with ccze is the recommended approach.
EOF
```

<!-- end_slide -->

## Solution: Describe the Fix

> **Key concept** = Brief definition

```markdown
Main content explaining the solution.
Use code blocks for centered text.
```

> **Result**: What this achieves

<!-- end_slide -->

## Sequences or Steps

> When showing sequential steps, use tables instead of numbered lists

| Step | Action |
|------|--------|
| **First** | What happens first |
| **Second** | What happens next |
| **Third** | What happens last |

> **Takeaway**: Why this matters

<!-- end_slide -->

## Comparison or Options

> Tables work great for comparisons

| Feature | Option A | Option B |
|---------|----------|----------|
| Speed | Fast | Slow |
| Cost | Low | High |
| Complexity | Simple | Complex |

<!-- end_slide -->

## Architecture Diagram

> Modern D2 diagrams for clear visualization

```bash +exec_replace
just d2-ascii diagram-name
```

Alternatively, render to SVG for presentations:
- `just d2 diagram-name` - Clean SVG output
- `just d2-sketch diagram-name` - Hand-drawn sketch style

**D2 Examples:**
- `d2-examples/kubernetes-architecture.d2` - Complex system architecture
- `d2-examples/workflow.d2` - CI/CD pipeline flowchart
- `d2-examples/comparison.d2` - Before/after comparison

**Migration Helper:**
```bash
just migrate-to-d2 .
```

<!-- end_slide -->

## Code Example

> Show real implementation

```bash
# Your code example here
echo "Hello World"
```

> **Note**: Explain what this code does and why it matters

<!-- end_slide -->

## Key Takeaways

1. First takeaway
2. Second takeaway
3. Third takeaway

> **Remember**: Main lesson learned

<!-- end_slide -->

## Resources

| Resource |
|----------|
| Resource 1: URL or description |
| Resource 2: URL or description |
| Resource 3: URL or description |

> **Tip**: Start with one concept, expand from there

<!-- end_slide -->

# That's All Folks! 👋

```bash +exec_replace
just intro_toilet That\'s all folks!
```

<!-- end_slide -->
