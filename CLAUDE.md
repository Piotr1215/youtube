# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands
- Run slide presentations: `just present` or `slides slides.md`
- Run a demo script: `bash demo.sh` or `./demo.sh`
- Run a single Lua test: `busted path/to/test/file_spec.lua`
- Create diagram: `just plantuml diagram_name` or `just digraph diagram_name`
- Generate ASCII art: `just intro "Your Title"` or `just intro_toilet "Your Title"`

## Code Style Guidelines
- Bash scripts: Use `set -euo pipefail` for strict mode
- Use proper error handling with informative messages and exit codes
- Quote all variables to prevent word splitting: `"${var}"`
- Lua: Module pattern with local M = {} and return M
- Indentation: Use tabs for bash scripts, 2 spaces for Lua
- Naming: Use snake_case for variables and functions
- Comments: Add clear, concise comments for complex logic
- Shell functions: Document params at function beginning
- Prefer absolute paths in shell scripts where possible
- Validate user inputs before processing

## Slides.md Format
- Use `<!-- end_slide -->` to separate slides
- Heading levels for slide structure (h1, h2, etc.)
- Code blocks with language specified (```bash)
- Use `` ```bash +exec_replace`` for running commands that replace their output in slides
- Use `` ```bash +exec`` for running commands that show output inline
- For emphasized text, use `*text*` and align asterisks in lists:
  ```
  - First point:           *emphasized text*
  - Second longer point:   *another emphasis*
  - Third point:           *more emphasis*
  ```
- Emoji usage for visual appeal (🚀, 💡, 📚)
- Start with intro slide and end with "That's All Folks!" slide
- Use blockquotes (>) for important definitions
- Include resources section with links
- For demo sessions, use the tmux switchc command:
  ```
  ## Demo Session
  
  ```bash
  tmux switchc -t session-name
  ```
  ```

## Diagram Format & Tools
- PlantUML (.puml files): Use `@startuml/@enduml` tags for sequence diagrams
  - Run with `just plantuml diagram_name` from the directory containing the diagram
  - Supports participants, actors, arrows, loops, groups for sequence diagrams
  - Example: `` ```bash +exec_replace`` with `just plantuml diagram_name` in slides to render ASCII art diagrams
- Graphviz (.dot files): Use `digraph G {}` for directed graphs 
  - Run with `just digraph diagram_name` to render as ASCII art
  - Supports nodes, edges, subgraphs, clusters, and styling
  - Rendered with graph-easy for ASCII output in terminal
  - SVG versions stored in diagrams/rendered/ directory
- Each diagram should be in its own file in the diagrams/ subdirectory
- Follow diagram naming pattern matching slide content focus
- Keep diagrams simple with clear visual hierarchy and readable labels

  Recording Options:
  - Live demo: Use demo.sh with tmux sessions for interactive presentations
  - VHS recording: Use 'just record tape_name' for polished GIFs/videos
  - See vhs/ directory for templates (kubectl-demo, nvim-demo, demo-template)
  - Tip: VHS recordings are great for consistent, repeatable demos and thumbnails

  Formatting Best Practices:
  - Use `> Quote` for SINGLE LINE emphasis only
  - Multi-line content → use code blocks (```markdown)
  - Use colored printf rows (✓ green, ✗ red, labels cyan) for sequences, steps, or comparisons; markdown tables render plain
  - figlet: Use `-w 90` for width, `-f small` or other fonts as needed
  - Images: Add with ![alt](./path.png) for visual appeal
  - End every slide with `<!-- end_slide -->`

  Colored Text (BEST → WORST):

  1. **BEST - printf with ANSI escape codes** (full color control):
     ```bash +exec_replace
     printf '\e[1;36m%s\e[0m\n' "Title in cyan bold"
     printf '\e[33m%s\e[0m\n'   "Section header in yellow"
     printf '  \e[32m%s\e[0m  %s\n' "Label " "description"
     printf '  \e[35m•\e[0m %s\n' "Bullet point"
     ```
     Color codes: 31=red, 32=green, 33=yellow, 34=blue, 35=magenta, 36=cyan, 37=white
     Bold: `\e[1;NNm`, Reset: `\e[0m`
     For aligned columns, pad with trailing spaces inside the string (not %-Ns)
     to avoid multi-byte UTF-8 characters breaking alignment.

  2. **GOOD - Markdown code block** (simple, no color):
     ```markdown
     Plain centered text
     ```

  3. **AVOID - ccze pipe** (unreliable color, no control over what gets highlighted):
     ```bash +exec_replace
     cat << 'EOF' | ccze -A
     ccze only colorizes log-like patterns
     EOF
     ```

  4. **AVOID - Blockquotes for multi-line** (inconsistent):
     > Use blockquotes only for single-line emphasis

  Rules:
  - NEVER use `<!-- pause -->` in slides
  - AVOID sandwich pattern: blockquote → code block → blockquote
  - Blockquotes (>) are for single-line emphasis ONLY
  - Presentations must NOT end with `<!-- end_slide -->` tag

Avoid sandwitching content between two blockquotes. ONly one blockqute per page.

## Deck Structure

`slides_template.md` holds this structure; `just start <folder>` copies it with `journey.sh`. `tmux-regex-copy/` is the reference deck.

- Tell a story in chapters, from the viewer's problem to their next action: why it matters, basic concepts, built-in or existing ways, the solution, how it works, getting started. Rename and merge to fit the topic.
- Open every chapter with a divider slide: a noun phrase `##` heading, one blockquote question the chapter answers, and `./journey.sh N`. The map shows viewers where they are and cues the presenter to introduce the chapter.
- Edit the `chapters` array in the deck's `journey.sh` to match the divider headings, in order.
- Put the first divider right after the title slide, so the deck never opens cold on a detail slide.
- Show the payoff early: a short demo inside chapter one, before any concept.
- So what, now what, then what shape the whole deck. Answer them once on a Takeaways slide near the end (✓ ✓ ▶ rows), not on every slide.
- A chapter holds only its own slides. After inserting or moving a divider, check that the slides following it belong to it.
- Name chapters neutrally: "Built-in Copying", not "Shortcomings"; "Plugin Internals", not "How the plugin works".

## Slide Content

- The presenter talks over every slide. A slide carries one visual and at most one or two short lines; the explanation is spoken.
- Prefer ASCII diagrams and colored printf rows to prose. Mermaid and images do not render in Alacritty.
- Keep rendered lines within 84 columns; the slide terminal is about 100 columns at recording font size.
- Nerd Font glyphs render zero width in presenterm and shift everything after them. Use plain Unicode: `›` `•` `▶` `✓` `✗` `│` `─`.
- Draw boxes open on the right, with no right border, so uneven line lengths never break the frame.
- Put a colored summary line below a diagram, separated by a blank line.
- Cut number slogans ("Two queries, two pastes") and coordinate counts ("30 x, 29 y"); both read as AI tells.
- Verify every technical claim against the source or by running it, and show real output. Check what a feature can and cannot do before contrasting it with the tool.

## Replayable Demos

`tmux-regex-copy/demo.sh` is the reference.

- A demo replays without the presenter typing: one segment per slide (`./demo.sh teaser`), each step named on a caption card that waits for Space, `q` to quit, `PACE` to scale pauses.
- Show captions in a floating pane (`tmux new-pane -x -y -X -Y -T`), never the status bar, which viewers barely see.
- `tmux send-keys` cannot type into a `display-popup`: the popup drops keys flagged as sent. Run the popup's command in a floating pane and send keys to that pane id.
- Switch the client back to the slides when the demo ends or fails (`trap finish EXIT`).

## Testing and Commits

- Ask before running a test that touches tmux. Use a sandbox socket (`tmux -S "$(mktemp -d)/sock"`), never the default server, and never run `tmux kill-server` without `-S`.
- Check slides headlessly: run `presenterm --validate-overflows -X -x presentation.md` in a sandboxed tmux session and `capture-pane -p` each slide.
- Commit deck files by explicit path (`git commit -- deck/presentation.md`), never `git commit -a`: other decks carry unrelated work in progress.
