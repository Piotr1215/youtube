# Diagram Rendering Recipes

Comprehensive diagram rendering system for the YouTube video repository.

## Available Recipes

### 1. `render-all`
Renders ALL diagrams (.dot, .puml, .d2) across the entire repository.

```bash
just render-all
```

**Features:**
- Finds all diagram source files recursively
- Renders .dot files to .txt (using graph-easy)
- Renders .puml files to SVG in rendered/ subdirectories (using plantuml)
- Renders .d2 files to SVG in rendered/ subdirectories (using d2)
- Shows tool availability status
- Displays progress and statistics
- Gracefully handles missing tools (skips instead of failing)
- Creates rendered/ directories as needed

**Output:**
```
🎨 Rendering all diagrams in repository...

Tool availability:
  graph-easy (for .dot): yes
  plantuml (for .puml): yes
  d2 (for .d2): no

📊 Rendering .dot files...
  → /home/user/youtube/kai-scheduler/diagrams/gpu-allocation.dot
  → /home/user/youtube/terminal-ai-integration/diagrams/interaction-pattern.dot
  ...

✅ Rendering complete!
   .dot files: 15
   .puml files: 8
   .d2 files: 0
```

---

### 2. `render-video folder`
Renders all diagrams in a specific video folder.

```bash
just render-video kai-scheduler
just render-video terminal-ai-integration
```

**Features:**
- Validates folder exists
- Renders only diagrams within that folder
- More targeted than render-all
- Shows concise progress output
- Reports total diagrams rendered

**Output:**
```
🎨 Rendering diagrams in: kai-scheduler

📊 .dot → gpu-allocation.txt
📊 .dot → multi-tenant.txt
📊 .puml → rendered/gpu-allocation.svg

✅ Rendered 3 diagram(s)
```

---

### 3. `clean-rendered`
Removes all generated diagram files from the repository.

```bash
just clean-rendered
```

**Features:**
- Removes all .txt files from diagrams/ directories
- Removes all rendered/ directories
- Shows what's being deleted
- Provides cleanup statistics

**Output:**
```
🧹 Cleaning rendered diagram files...

  🗑  /home/user/youtube/kai-scheduler/diagrams/gpu-allocation.txt
  🗑  /home/user/youtube/kai-scheduler/diagrams/multi-tenant.txt
  🗑  /home/user/youtube/dotfiles/diagrams/rendered/

✅ Cleanup complete!
   .txt files removed: 25
   rendered/ directories removed: 12
```

---

### 4. `watch-diagrams folder`
Auto-renders diagrams when source files change.

```bash
just watch-diagrams kai-scheduler
```

**Features:**
- Watches all .dot, .puml, and .d2 files in folder
- Auto-renders on file changes
- Uses `entr` for efficient watching (if available)
- Falls back to polling mode (5 second interval) if entr not installed
- Press Ctrl+C to stop

**With entr (recommended):**
```
👀 Watching diagrams in: kai-scheduler
   Press Ctrl+C to stop

🔄 Change detected, rendering...
📊 .dot → gpu-allocation.txt
✅ Rendered 1 diagram(s)

👀 Watching for changes...
```

**Without entr (polling mode):**
```
⚠️  'entr' is not installed. Using polling mode (5 second interval)...
   For better performance, install entr: apt-get install entr

👀 Watching diagrams in: kai-scheduler
   Press Ctrl+C to stop
```

---

## Tool Requirements

The recipes gracefully handle missing tools:

| Tool | Purpose | Install Command | Status |
|------|---------|----------------|--------|
| graph-easy | Render .dot to ASCII | `cpanm Graph::Easy` | Optional |
| plantuml | Render .puml to SVG | Download plantuml.jar | Optional |
| java | Run plantuml | `apt-get install default-jre` | Optional |
| d2 | Render .d2 to SVG | `curl -fsSL https://d2lang.com/install.sh \| sh` | Optional |
| entr | File watching | `apt-get install entr` | Optional |

**Note:** Missing tools are detected and reported. The recipes skip rendering for file types whose tools aren't available.

---

## Output Locations

### .dot files (GraphViz)
- **Source:** `*/diagrams/*.dot`
- **Output:** `*/diagrams/*.txt` (ASCII boxart)
- **Format:** Plain text, embedded in presentations

### .puml files (PlantUML)
- **Source:** `*/diagrams/*.puml`
- **Output:** `*/diagrams/rendered/*.svg`
- **Format:** SVG vector graphics

### .d2 files (D2)
- **Source:** `*/diagrams/*.d2`
- **Output:** `*/diagrams/rendered/*.svg`
- **Format:** SVG vector graphics

---

## .gitignore Configuration

Generated diagram files are automatically excluded from git:

```gitignore
# Rendered diagram outputs
**/diagrams/*.txt
**/diagrams/rendered/
**/rendered/
```

**Note:** Files already tracked by git before adding these patterns will remain tracked. Use `just clean-rendered` to remove them, then re-render as needed.

---

## Workflow Examples

### Before presenting a video
```bash
# Render all diagrams in a specific video
just render-video terminal-ai-integration

# Or use the preflight check (includes spelling + diagrams)
just preflight terminal-ai-integration
```

### Developing diagrams with live preview
```bash
# Watch and auto-render while editing
just watch-diagrams kai-scheduler

# Edit your .dot/.puml/.d2 files
# Diagrams auto-render on save
```

### Bulk operations
```bash
# Render everything in the repo
just render-all

# Clean up all rendered outputs
just clean-rendered

# Re-render from scratch
just clean-rendered && just render-all
```

### Migration to D2
```bash
# Find diagrams that could be migrated
just migrate-to-d2 kai-scheduler

# Convert manually, then render
just d2 diagram-name
# or
just render-video kai-scheduler
```

---

## Integration with Existing Recipes

These new recipes complement existing single-diagram recipes:

| Old Recipe | New Recipe | Difference |
|------------|------------|------------|
| `just digraph diagram` | `just render-video folder` | Batch vs single |
| `just plantuml diagram` | `just render-video folder` | Batch vs single |
| `just d2 diagram` | `just render-video folder` | Batch vs single |
| N/A | `just render-all` | Repository-wide |
| N/A | `just clean-rendered` | Cleanup utility |
| N/A | `just watch-diagrams folder` | Auto-render |

---

## Statistics

Current repository diagram files:
- **~20 .dot files** across multiple videos
- **~15 .puml files** across multiple videos
- **0 .d2 files** (migration opportunity)

---

## Troubleshooting

### "Tool not available" warnings
- Install the required tool (see Tool Requirements table)
- Or use `render-all` which skips unavailable formats

### "Folder not found" errors
- Ensure you're using the folder name relative to repository root
- Example: `kai-scheduler` not `/home/user/youtube/kai-scheduler`

### Diagrams not updating
- Check file permissions
- Verify source file syntax (use tool-specific validators)
- Check output directories are writable

### Watch mode not triggering
- Install `entr` for better performance
- Or accept 5-second polling delay
- Ensure files are being saved (not just modified)

---

## Future Enhancements

Possible improvements:
- [ ] Parallel rendering for faster `render-all`
- [ ] Support for custom output formats per diagram type
- [ ] Integration with presentation preview
- [ ] Diagram validation before rendering
- [ ] Diff-based rendering (only changed diagrams)
