# YouTube Content Repository

![Videos](https://img.shields.io/badge/videos-86-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Last Updated](https://img.shields.io/badge/updated-2025--01-orange)
![Tools](https://img.shields.io/badge/tools-presenterm%20%7C%20tmux%20%7C%20just-purple)

A comprehensive repository for long and short form technical content production. Each video lives in its own directory with presentation slides, demo scripts, and diagrams.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Repository Structure](#repository-structure)
- [Tool Installation](#tool-installation)
- [Justfile Recipes](#justfile-recipes)
- [Workflow Examples](#workflow-examples)
- [Documentation](#documentation)

## Overview

This repository contains scripts, presentations, and diagrams for technical video content. Each video directory follows a consistent structure:

- **Presentation files**: `slides.md` or `presentation.md` (rendered with [presenterm](https://github.com/mfontanini/presenterm))
- **Demo scripts**: Optional `demo.sh` with executable commands
- **Diagrams**: PlantUML (`.puml`) or graph-easy (`.dot`) files in `diagrams/` subdirectory
- **Theme files**: Custom `theme.json` for presenterm styling

### Key Features

- Terminal-based presentations with live code execution
- Automated diagram rendering in slides
- Demo scripts with typed command simulation
- Reusable templates and partials
- Just-based automation for common workflows

## Quick Start

### Creating a New Video

```bash
# Clone the repository
git clone <repo-url>
cd youtube

# Create a new video folder from template
just start my-new-video "My Awesome Title"

# Edit the presentation
cd my-new-video
nvim presentation.md

# Run the presentation
just present
```

### Running an Existing Presentation

```bash
# Navigate to any video directory
cd bash-scripting

# Run the presentation
just present

# Or execute the demo script
./demo.sh
```

## Repository Structure

```
youtube/
├── README.md                    # This file
├── WORKFLOWS.md                 # Detailed workflow documentation
├── TOOLS.md                     # Tool installation and configuration
├── justfile                     # Automation recipes
├── slides_template.md           # Template for new presentations
├── theme.json                   # Default presenterm theme
├── __demo_magic.sh              # Demo script utilities
├── __questions.sh               # Interactive quiz utilities
├── __tmux_timer.sh              # Timer utilities for demos
├── _partials/                   # Reusable slide components
│   └── *.md
├── templates/                   # Additional templates
├── [video-name]/                # Individual video directories
│   ├── presentation.md          # Presentation slides
│   ├── demo.sh                  # Optional demo script
│   ├── theme.json               # Optional custom theme
│   └── diagrams/                # Diagram source files
│       ├── *.puml               # PlantUML diagrams
│       └── *.dot                # graph-easy diagrams
└── test-*/                      # Interactive quiz videos
```

### Video Categories

The repository contains 86 video directories covering:

- **Vim/Neovim**: Editor configurations, plugins, keybindings
- **tmux**: Session management, notifications, layouts
- **Bash/Shell**: Scripting, exercises, automation
- **Kubernetes**: Deployments, debugging, schedulers
- **DevOps**: Docker, CI/CD, infrastructure
- **Terminal Tools**: CLI utilities, productivity tools
- **Taskwarrior**: Task management and automation
- **Interactive Tests**: Quiz-based learning videos

## Tool Installation

### Core Tools

```bash
# Presenterm - Terminal presentation tool
cargo install presenterm

# Just - Command runner
cargo install just

# tmux - Terminal multiplexer
sudo apt-get install tmux  # Debian/Ubuntu
brew install tmux          # macOS

# pv - Pipe viewer for demo scripts
sudo apt-get install pv    # Debian/Ubuntu
brew install pv            # macOS
```

### Diagram Tools

```bash
# PlantUML - UML diagram generation
sudo apt-get install plantuml  # Debian/Ubuntu
brew install plantuml          # macOS

# graph-easy - ASCII diagram tool
sudo apt-get install libgraph-easy-perl  # Debian/Ubuntu
cpan Graph::Easy                         # From CPAN
```

### Text Formatting Tools

```bash
# figlet - ASCII art text
sudo apt-get install figlet  # Debian/Ubuntu
brew install figlet          # macOS

# toilet - Advanced ASCII art
sudo apt-get install toilet  # Debian/Ubuntu
brew install toilet          # macOS

# boxes - Text box drawing
sudo apt-get install boxes   # Debian/Ubuntu
brew install boxes           # macOS
```

### Optional Tools

```bash
# glow - Markdown renderer
go install github.com/charmbracelet/glow@latest

# typos - Spell checker
cargo install typos-cli

# VHS - Terminal recorder (for GIF creation)
go install github.com/charmbracelet/vhs@latest

# D2 - Modern diagram scripting
curl -fsSL https://d2lang.com/install.sh | sh -s --
```

For detailed installation instructions, see [TOOLS.md](TOOLS.md).

## Justfile Recipes

The `justfile` provides automation for common tasks:

### Core Commands

```bash
just                    # List all available recipes
just list_videos        # List all video directories with dates
```

### Presentation Management

```bash
just start <folder> [title]     # Create new video folder with template
just present                    # Run presentation in current directory
just intro <text>               # Generate ASCII art intro (figlet)
just intro_toilet <text>        # Generate ASCII art intro (toilet)
just freetext <text>            # Display formatted free text
```

### Diagram Rendering

```bash
just plantuml <diagram>         # Render PlantUML diagram to ASCII
just digraph <diagram>          # Render graph-easy diagram to ASCII
```

### Development

```bash
just tmux_demo                  # Create tmux demo session
```

### Examples

```bash
# Create a new video about Docker
just start docker-fundamentals "Docker Fundamentals"

# Render a PlantUML diagram
cd kubernetes-deployments
just plantuml architecture

# Render a graph-easy diagram
cd mcp-agentic-framework
just digraph mcp-overview

# Generate title slide
just intro_toilet "Welcome to Vim!"
```

## Workflow Examples

### Creating a New Video

1. **Initialize the video directory:**
   ```bash
   just start my-topic "My Topic Title"
   cd my-topic
   ```

2. **Edit the presentation:**
   ```bash
   nvim presentation.md
   ```

3. **Add diagrams (if needed):**
   ```bash
   mkdir -p diagrams
   # Create .puml or .dot files in diagrams/
   ```

4. **Test the presentation:**
   ```bash
   just present
   ```

5. **Create demo script (optional):**
   ```bash
   cat > demo.sh << 'EOF'
   #!/usr/bin/env bash
   source ../__demo_magic.sh
   # Add demo commands
   EOF
   chmod +x demo.sh
   ```

### Rendering Diagrams in Slides

Use code blocks with `+exec_replace` to render diagrams dynamically:

**PlantUML:**
```markdown
```bash +exec_replace
just plantuml my-diagram
```​
```

**graph-easy:**
```markdown
```bash +exec_replace
just digraph my-diagram
```​
```

### Creating Demo Scripts

Demo scripts use the `__demo_magic.sh` utility for typed command simulation:

```bash
#!/usr/bin/env bash
source ../__demo_magic.sh

clear_screen
pe "echo 'Hello World'"
pe "ls -la"
wait
```

For detailed workflows, see [WORKFLOWS.md](WORKFLOWS.md).

## Documentation

- **[WORKFLOWS.md](WORKFLOWS.md)** - Step-by-step guides for common workflows
- **[TOOLS.md](TOOLS.md)** - Comprehensive tool documentation and configuration
- **[demo-magic](https://github.com/paxtonhare/demo-magic)** - Inspiration for `__demo_magic.sh`

## Building on Open Source

The script runner `__demo_magic.sh` is inspired by the excellent [demo-magic](https://github.com/paxtonhare/demo-magic) repository, which allows for simulating command typing and output in a terminal.

## Prerequisites

Minimum requirements to use this repository:

- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [pv](https://manned.org/pv) - Pipe viewer for animations
- [presenterm](https://github.com/mfontanini/presenterm) - Terminal presentation tool
- [just](https://github.com/casey/just) - Command runner

See [TOOLS.md](TOOLS.md) for complete installation instructions.

## Contributing

Video content structure:
1. Each video in its own directory
2. Use `slides_template.md` as starting point
3. Follow naming conventions (lowercase with hyphens)
4. Include diagrams in `diagrams/` subdirectory
5. Document any special prerequisites in video directory

## License

MIT License - Feel free to use these scripts and presentations for your own content creation.

