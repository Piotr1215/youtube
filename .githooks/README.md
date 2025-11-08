# Git Hooks

This directory contains custom git hooks for the YouTube content repository.

## Overview

These hooks automate diagram rendering and run quality checks to ensure consistency and completeness of the repository.

## Hooks

### pre-commit

**Purpose**: Automatically render diagrams and run spell checks before each commit.

**What it does**:
1. **Auto-renders modified diagrams**:
   - `.dot` files → `.txt` files (using `graph-easy`)
   - `.puml` files → `.utxt` files (using `plantuml`)
   - `.d2` files → `.svg` files (using `d2`)

2. **Automatically stages rendered outputs**: You don't need to manually `git add` the generated files.

3. **Runs spell check** (using `typos`): Shows warnings for typos but doesn't block commits.

**Example output**:
```
🔍 Running pre-commit checks...

📊 Checking for diagram files to render...
  → Rendering: mcp-agentic-framework/diagrams/architecture.dot
    ✓ Generated and staged: mcp-agentic-framework/diagrams/architecture.txt

✨ Auto-generated 1 diagram file(s):
   • mcp-agentic-framework/diagrams/architecture.txt

📝 Running spell check...
  ✓ No typos detected

✅ Pre-commit checks complete!
```

**Performance**: Fast - only processes staged files, typically completes in < 1 second.

### pre-push

**Purpose**: Validate repository state before pushing to remote.

**What it does**:
1. **Ensures all diagrams are rendered**: Checks that every `.dot`, `.puml`, and `.d2` file has a corresponding rendered output.

2. **Warns if VIDEO_INDEX.md is out of date**: Compares modification times to detect if the index needs updating.

3. **Runs optional preflight checks**: Executes `just test` if available (warning only, doesn't block push).

**Example output**:
```
🚀 Running pre-push checks...

📊 Verifying all diagrams are rendered...
  ✓ All diagrams are up to date

📹 Checking VIDEO_INDEX.md freshness...
  ⚠️  VIDEO_INDEX.md might be out of date
  💡 Consider regenerating it if you added new content

🔧 Running optional preflight checks...
  ✓ No test recipe defined

✅ Pre-push checks complete!
⚠️  Found 1 issue(s) but allowing push to proceed
```

**Performance**: Moderate - scans all diagram files, typically completes in < 2 seconds.

## Installation

Use the justfile recipes to manage hooks:

```bash
# Install hooks (sets git config core.hooksPath to .githooks)
just install-hooks

# Uninstall hooks (resets to default .git/hooks)
just uninstall-hooks

# Test hooks without committing
just test-hooks
```

## Manual Installation

If you prefer to install manually:

```bash
# Install
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit .githooks/pre-push

# Uninstall
git config --unset core.hooksPath
```

## Dependencies

### Required Tools

The hooks work best when these tools are installed:

- **graph-easy**: For rendering `.dot` files to ASCII art
  ```bash
  # Ubuntu/Debian
  sudo apt install libgraph-easy-perl

  # macOS
  cpan Graph::Easy
  ```

- **plantuml**: For rendering `.puml` files to ASCII diagrams
  ```bash
  # Download JAR to /usr/local/bin/plantuml.jar
  # Or install via package manager
  sudo apt install plantuml  # Ubuntu/Debian
  brew install plantuml      # macOS
  ```

- **d2**: For rendering `.d2` files to SVG
  ```bash
  # Install from https://github.com/terrastruct/d2
  curl -fsSL https://d2lang.com/install.sh | sh -s --
  ```

- **typos**: For spell checking (optional but recommended)
  ```bash
  cargo install typos-cli
  ```

### Graceful Degradation

If tools are not installed, the hooks will:
- Show a warning message
- Skip that specific check
- Continue with other checks
- Never block your commit/push

## Testing Hooks

To test the hooks without making an actual commit:

```bash
# Test pre-commit hook
just test-hooks

# Or manually:
.githooks/pre-commit
```

## Customization

### Disable Specific Checks

You can temporarily disable checks by setting environment variables:

```bash
# Skip diagram rendering
SKIP_DIAGRAM_RENDER=1 git commit -m "Quick fix"

# Skip all pre-commit checks
git commit --no-verify -m "Emergency commit"
```

### Modify Hook Behavior

The hooks are bash scripts in this directory. You can edit them to:
- Add new diagram formats
- Include additional checks
- Change warning/error behavior
- Customize output colors and messages

## Troubleshooting

### Hook not running

```bash
# Check if hooks are installed
git config core.hooksPath
# Should output: .githooks

# Ensure hooks are executable
chmod +x .githooks/pre-commit .githooks/pre-push
```

### Diagram rendering fails

```bash
# Test tools manually
graph-easy test.dot --as=boxart
plantuml test.puml -utxt
d2 test.d2 test.svg

# Check tool installation
which graph-easy plantuml d2 typos
```

### Hook is too slow

The hooks are designed to be fast:
- pre-commit only processes staged files
- pre-push uses `find` with minimal depth
- No network calls or heavy operations

If you experience slowness, check:
- Number of diagram files (100+ might slow things down)
- Large binary files in staged changes
- Slow disk I/O

## Philosophy

These hooks follow the principle: **"Helpful, not annoying"**

- ✅ Fast execution (< 2 seconds typical)
- ✅ Clear, colorful output
- ✅ Warnings instead of errors when possible
- ✅ Graceful degradation if tools missing
- ✅ Easy to bypass with `--no-verify` if needed
- ✅ Auto-fix what we can (diagram rendering)
- ✅ Inform about what we can't (typos, out-of-date files)

## Contributing

When modifying hooks:
1. Test thoroughly with and without tools installed
2. Keep execution time under 2 seconds
3. Use clear, friendly error messages
4. Don't block commits unless absolutely necessary
5. Update this README with any changes
