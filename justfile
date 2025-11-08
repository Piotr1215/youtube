#!/usr/bin/env -S just --justfile

# Variables will be overriden by the prepare recipe
replace                          := if os() == "linux" { "sed -i"} else { "sed -i '' -e" }
diagrams                         := invocation_directory() + "/diagrams"


# show all the justfile recipes
default:
  @just --list

# install git hooks for auto-rendering and checks
install-hooks:
  #!/usr/bin/env bash
  set -e
  echo "Installing git hooks..."
  git config core.hooksPath .githooks
  chmod +x .githooks/pre-commit .githooks/pre-push
  echo "✅ Git hooks installed successfully!"
  echo "Hooks configured:"
  echo "  • pre-commit: Auto-render diagrams + spell check"
  echo "  • pre-push: Validate all diagrams rendered"
  echo ""
  echo "Run 'just test-hooks' to test the pre-commit hook"

# uninstall git hooks (restore to default .git/hooks)
uninstall-hooks:
  #!/usr/bin/env bash
  set -e
  echo "Uninstalling git hooks..."
  git config --unset core.hooksPath || true
  echo "✅ Git hooks uninstalled successfully!"
  echo "Git now uses default .git/hooks directory"

# test pre-commit hook without actually committing
test-hooks:
  #!/usr/bin/env bash
  set -e
  echo "Testing pre-commit hook..."
  echo ""
  if [ -f .githooks/pre-commit ]; then
    .githooks/pre-commit
  else
    echo "❌ pre-commit hook not found at .githooks/pre-commit"
    exit 1
  fi

# list all youtbube videos
list_videos:
  /home/decoder/dev/dotfiles/scripts/__get_youtube_videos.py --date

# crate tmux demo sesison
tmux_demo:
  tmux new-session -d -s demo

# start a new folder with template structure
start folder_name title="":
  #!/usr/bin/env bash
  mkdir -p "{{folder_name}}/diagrams"
  
  cp slides_template.md "{{folder_name}}/presentation.md"
  chmod +x "{{folder_name}}/presentation.md"
  
  # Replace title if provided
  if [ -n "{{title}}" ]; then
    sed -i 's/Replace Me/{{title}}/g' "{{folder_name}}/presentation.md"
  fi
  
  echo "Created new folder structure in: {{folder_name}}"
  cd "{{folder_name}}"

# run plantuml diagram
plantuml diagram:
  #!/usr/bin/env bash  
  export diagram="{{diagram}}"
  if command -v plantuml &>/dev/null; then
          java -jar /usr/local/bin/plantuml.jar {{diagrams}}/"$diagram".puml -utxt
          mv {{diagrams}}/"$diagram".utxt /tmp/"$diagram".utxt
          cat /tmp/"$diagram".utxt
  else
          echo " "
  fi

# run graphasy diagram
digraph diagram:
  #!/usr/bin/env bash
  export diagram="{{diagram}}"
  if command -v graph-easy &>/dev/null; then
          graph-easy {{diagrams}}/"$diagram".dot --as=boxart > {{diagrams}}/"$diagram".txt
          cat {{diagrams}}/"$diagram".txt
  else
          echo " "
  fi

# render D2 diagram to SVG
d2 diagram:
  #!/usr/bin/env bash
  export diagram="{{diagram}}"
  if command -v d2 &>/dev/null; then
          d2 {{diagrams}}/"$diagram".d2 {{diagrams}}/"$diagram".svg
          echo "Rendered {{diagrams}}/$diagram.svg"
  else
          echo "D2 not installed. Install with: curl -fsSL https://d2lang.com/install.sh | sh -s --"
  fi

# render D2 diagram with hand-drawn sketch style
d2-sketch diagram:
  #!/usr/bin/env bash
  export diagram="{{diagram}}"
  if command -v d2 &>/dev/null; then
          d2 --sketch {{diagrams}}/"$diagram".d2 {{diagrams}}/"$diagram"-sketch.svg
          echo "Rendered {{diagrams}}/$diagram-sketch.svg with sketch style"
  else
          echo "D2 not installed. Install with: curl -fsSL https://d2lang.com/install.sh | sh -s --"
  fi

# render D2 diagram to ASCII art
d2-ascii diagram:
  #!/usr/bin/env bash
  export diagram="{{diagram}}"
  if command -v d2 &>/dev/null; then
          d2 --ascii {{diagrams}}/"$diagram".d2
  else
          echo "D2 not installed. Install with: curl -fsSL https://d2lang.com/install.sh | sh -s --"
  fi

# identify .dot/.puml files in folder that could be converted to D2
migrate-to-d2 folder:
  #!/usr/bin/env bash
  echo "Scanning {{folder}} for diagram files that could be migrated to D2..."
  echo ""

  # Find .dot files
  dot_files=$(find {{folder}} -name "*.dot" 2>/dev/null)
  if [ -n "$dot_files" ]; then
    echo "GraphViz (.dot) files found:"
    echo "$dot_files" | while read -r file; do
      echo "  - $file"
    done
    echo ""
  fi

  # Find .puml files
  puml_files=$(find {{folder}} -name "*.puml" 2>/dev/null)
  if [ -n "$puml_files" ]; then
    echo "PlantUML (.puml) files found:"
    echo "$puml_files" | while read -r file; do
      echo "  - $file"
    done
    echo ""
  fi

  # Count totals
  total_dots=$(echo "$dot_files" | grep -c . 2>/dev/null || echo 0)
  total_pumls=$(echo "$puml_files" | grep -c . 2>/dev/null || echo 0)
  total=$((total_dots + total_pumls))

  if [ "$total" -eq 0 ]; then
    echo "No .dot or .puml files found in {{folder}}"
  else
    echo "Total: $total diagram(s) could be migrated to D2"
    echo ""
    echo "Migration tips:"
    echo "  1. D2 uses simpler syntax: 'A -> B: label'"
    echo "  2. Check d2-examples/ for style references"
    echo "  3. Use 'just d2 diagram' to render"
    echo "  4. Use 'just d2-sketch diagram' for hand-drawn style"
  fi


# run the presentation
present:
  @cd {{invocation_directory()}}; KUBECONFIG=/home/decoder/dev/homelab/kubeconfig presenterm -Xx presentation.md

# show freetext
freetext *free_text:
  #!/usr/bin/env bash
  export title="{{free_text}}"
  if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
      echo "$title" | figlet -f pagga -w 200 | boxes -d peek
  else
      echo "$title"
  fi

# show intro ascii using figlet
intro *pres_title:
  #!/usr/bin/env bash
  export title="{{pres_title}}"

  if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
    echo "$title" | figlet -f future -w 200 | boxes -d peek
  else
    echo "$title"
  fi

# show intro ascii using toilet
intro_toilet *pres_title:
  #!/usr/bin/env bash
  export title="{{pres_title}}"
  if command -v toilet &>/dev/null && command -v boxes &>/dev/null; then
    echo "$title" | toilet -f mono9 -w 200 --filter border
  else
    echo "$title"
  fi

# Browse all presentations interactively with FZF and glow preview
browse:
  #!/usr/bin/env bash
  set -euo pipefail

  base_dir="{{invocation_directory()}}"

  # Find all video directories (depth 1, exclude hidden and current dir)
  selected=$(fd -t d -d 1 . "$base_dir" | \
    sed 's|^./||' | \
    grep -v '^\.$' | \
    sort | \
    fzf --ansi \
      --preview "bash -c '
        folder=\"$base_dir/{}\"
        if [ -f \"\$folder/presentation.md\" ]; then
          glow \"\$folder/presentation.md\" --style dark
        elif [ -f \"\$folder/slides.md\" ]; then
          glow \"\$folder/slides.md\" --style dark
        else
          echo \"No presentation file found\"
        fi
      '" \
      --preview-window='right:70%:wrap' \
      --bind "ctrl-e:execute(\$EDITOR $base_dir/{}/presentation.md $base_dir/{}/slides.md 2>/dev/null || \$EDITOR $base_dir/{})" \
      --bind "ctrl-p:execute(cd $base_dir/{} && just present)+abort" \
      --header 'Browse Presentations | Enter: view | Ctrl-E: edit | Ctrl-P: present' \
      --border rounded \
      --prompt 'Select video: ')

  if [ -n "$selected" ]; then
    folder="$base_dir/$selected"
    if [ -f "$folder/presentation.md" ]; then
      glow -p "$folder/presentation.md" --style dark
    elif [ -f "$folder/slides.md" ]; then
      glow -p "$folder/slides.md" --style dark
    fi
  fi

# Preview a specific video's presentation with glow
preview folder:
  #!/usr/bin/env bash
  set -euo pipefail

  folder="{{invocation_directory()}}/{{folder}}"

  if [ -f "$folder/presentation.md" ]; then
    glow -p "$folder/presentation.md" --style dark
  elif [ -f "$folder/slides.md" ]; then
    glow -p "$folder/slides.md" --style dark
  else
    echo "❌ Error: No presentation.md or slides.md found in {{folder}}"
    exit 1
  fi

# Search across all presentations and preview results with glow
search term:
  #!/usr/bin/env bash
  set -euo pipefail

  term="{{term}}"

  # Search in all presentation files and show in fzf
  selected=$(rg --line-number --no-heading --color=always \
    --smart-case "$term" \
    --glob "presentation.md" --glob "slides.md" \
    {{invocation_directory()}} | \
    fzf --ansi \
      --delimiter ':' \
      --preview 'bash -c '\''
        file=$(echo {} | cut -d: -f1)
        line=$(echo {} | cut -d: -f2)
        glow "$file" --style dark
      '\'' ' \
      --preview-window='right:70%:wrap' \
      --bind 'ctrl-e:execute($EDITOR +{2} {1})' \
      --header "🔎 Search: \"$term\" | Enter: view full file | Ctrl-E: edit at line" \
      --border rounded \
      --prompt '📄 Select result: ' || true)

  if [ -n "$selected" ]; then
    file=$(echo "$selected" | cut -d: -f1)
    glow -p "$file" --style dark
  fi

# Check for spelling errors across all presentations
check-spelling:
  #!/usr/bin/env bash
  set -euo pipefail

  if ! command -v typos &>/dev/null; then
    echo "❌ Error: typos is not installed"
    echo "Install with: cargo install typos-cli"
    exit 1
  fi

  echo "🔍 Checking spelling across all presentations..."
  cd {{invocation_directory()}}
  typos --color always

# Auto-fix spelling errors across all presentations
fix-spelling:
  #!/usr/bin/env bash
  set -euo pipefail

  if ! command -v typos &>/dev/null; then
    echo "❌ Error: typos is not installed"
    echo "Install with: cargo install typos-cli"
    exit 1
  fi

  echo "✏️  Auto-fixing spelling errors..."
  cd {{invocation_directory()}}
  typos --write-changes --color always
  echo "✅ Spelling fixes applied!"

# Check spelling in a specific video/folder
check-video folder:
  #!/usr/bin/env bash
  set -euo pipefail

  if ! command -v typos &>/dev/null; then
    echo "❌ Error: typos is not installed"
    echo "Install with: cargo install typos-cli"
    exit 1
  fi

  folder_path="{{invocation_directory()}}/{{folder}}"

  if [ ! -d "$folder_path" ]; then
    echo "❌ Error: Folder '{{folder}}' not found"
    exit 1
  fi

  echo "🔍 Checking spelling in {{folder}}..."
  cd "$folder_path"
  typos --color always

# Pre-flight check before presenting (spelling + render diagrams)
preflight folder:
  #!/usr/bin/env bash
  set -euo pipefail

  folder_path="{{invocation_directory()}}/{{folder}}"

  if [ ! -d "$folder_path" ]; then
    echo "❌ Error: Folder '{{folder}}' not found"
    exit 1
  fi

  echo "🚀 Running pre-flight checks for {{folder}}..."
  echo ""

  # Check spelling
  echo "📝 Step 1/2: Checking spelling..."
  if command -v typos &>/dev/null; then
    cd "$folder_path"
    if typos --color always; then
      echo "✅ No spelling errors found"
    else
      echo "⚠️  Spelling errors detected - review above"
    fi
  else
    echo "⚠️  typos not installed - skipping spelling check"
  fi

  echo ""
  echo "📊 Step 2/2: Rendering diagrams..."

  # Render diagrams if they exist
  diagrams_dir="$folder_path/diagrams"
  if [ -d "$diagrams_dir" ]; then
    # Check for .d2 files
    d2_files=$(find "$diagrams_dir" -maxdepth 1 -name "*.d2" 2>/dev/null || true)
    if [ -n "$d2_files" ]; then
      echo "$d2_files" | while read -r file; do
        if [ -f "$file" ]; then
          diagram=$(basename "$file" .d2)
          echo "  Rendering D2: $diagram"
          cd "$folder_path"
          just d2 "$diagram" 2>&1 | grep -v "^$" || true
        fi
      done
    fi

    # Check for .dot files
    dot_files=$(find "$diagrams_dir" -maxdepth 1 -name "*.dot" 2>/dev/null || true)
    if [ -n "$dot_files" ]; then
      echo "$dot_files" | while read -r file; do
        if [ -f "$file" ]; then
          diagram=$(basename "$file" .dot)
          echo "  Rendering GraphViz: $diagram"
          cd "$folder_path"
          just digraph "$diagram" 2>&1 | grep -v "^$" || true
        fi
      done
    fi

    # Check for .puml files
    puml_files=$(find "$diagrams_dir" -maxdepth 1 -name "*.puml" 2>/dev/null || true)
    if [ -n "$puml_files" ]; then
      echo "$puml_files" | while read -r file; do
        if [ -f "$file" ]; then
          diagram=$(basename "$file" .puml)
          echo "  Rendering PlantUML: $diagram"
          cd "$folder_path"
          just plantuml "$diagram" 2>&1 | grep -v "^$" || true
        fi
      done
    fi

    if [ -z "$d2_files" ] && [ -z "$dot_files" ] && [ -z "$puml_files" ]; then
      echo "  ℹ️  No diagram files found in diagrams/"
    else
      echo "✅ Diagrams rendered"
    fi
  else
    echo "  ℹ️  No diagrams directory found"
  fi

  echo ""
  echo "✅ Pre-flight checks complete for {{folder}}!"
  echo "🎬 Ready to present! Run: cd {{folder}} && just present"

# check which format a folder uses (slides.md vs presentation.md)
check-format folder:
  @{{justfile_directory()}}/migrate_presentation.sh check-format "{{folder}}"

# migrate a single folder from slides.md to presentation.md format
migrate-presentation folder:
  @{{justfile_directory()}}/migrate_presentation.sh migrate "{{folder}}"

# migrate all videos from old format to new format
migrate-all:
  @{{justfile_directory()}}/migrate_presentation.sh migrate-all {{justfile_directory()}}

# show migration status report
migration-status:
  @{{justfile_directory()}}/migrate_presentation.sh status {{justfile_directory()}}

# generate YouTube metadata for a specific video folder
generate-metadata folder:
  #!/usr/bin/env bash
  if [ ! -d "{{folder}}" ]; then
    echo "Error: Folder '{{folder}}' does not exist"
    exit 1
  fi

  if [ ! -f "{{folder}}/presentation.md" ]; then
    echo "Error: No presentation.md found in '{{folder}}'"
    exit 1
  fi

  echo "Generating YouTube metadata for: {{folder}}"
  python3 {{justfile_directory()}}/generate_youtube_metadata.py "{{folder}}"

  if [ -f "{{folder}}/youtube_metadata.txt" ]; then
    echo ""
    echo "Preview:"
    echo "========================================"
    head -30 "{{folder}}/youtube_metadata.txt"
    echo "..."
    echo "========================================"
    echo ""
    echo "Full metadata saved to: {{folder}}/youtube_metadata.txt"
  fi

# generate YouTube metadata for all video folders
metadata-all:
  #!/usr/bin/env bash
  echo "Generating YouTube metadata for all videos..."
  echo ""

  # Find all folders with presentation.md files
  found=0
  generated=0
  failed=0

  for folder in */; do
    folder="${folder%/}"  # Remove trailing slash

    if [ -f "$folder/presentation.md" ]; then
      found=$((found + 1))
      echo "[$found] Processing: $folder"

      if python3 {{justfile_directory()}}/generate_youtube_metadata.py "$folder" 2>/dev/null; then
        generated=$((generated + 1))
        echo "    ✓ Generated: $folder/youtube_metadata.txt"
      else
        failed=$((failed + 1))
        echo "    ✗ Failed: $folder"
      fi
      echo ""
    fi
  done

  echo "========================================"
  echo "Summary:"
  echo "  Total found: $found"
  echo "  Generated: $generated"
  echo "  Failed: $failed"
  echo "========================================"

  if [ $generated -gt 0 ]; then
    echo ""
    echo "YouTube metadata files created!"
    echo "Use 'cat <folder>/youtube_metadata.txt' to view individual files"
  fi

# record a VHS tape file
record tape_name:
  #!/usr/bin/env bash
  if ! command -v vhs &>/dev/null; then
    echo "❌ Error: VHS is not installed"
    echo "Install with: go install github.com/charmbracelet/vhs@latest"
    echo "Or on macOS: brew install vhs"
    exit 1
  fi

  tape_file="{{tape_name}}"

  # If no extension, assume .tape
  if [[ ! "$tape_file" =~ \.tape$ ]]; then
    tape_file="${tape_file}.tape"
  fi

  # Check if file exists in vhs/ directory or current directory
  if [ -f "vhs/$tape_file" ]; then
    echo "🎬 Recording vhs/$tape_file..."
    vhs "vhs/$tape_file"
    echo "✅ Recording complete!"
  elif [ -f "$tape_file" ]; then
    echo "🎬 Recording $tape_file..."
    vhs "$tape_file"
    echo "✅ Recording complete!"
  else
    echo "❌ Error: Tape file not found: $tape_file"
    echo "Searched in: vhs/$tape_file and $tape_file"
    echo ""
    echo "Available templates in vhs/:"
    ls -1 vhs/*.tape 2>/dev/null | sed 's|vhs/||' || echo "  (no templates found)"
    exit 1
  fi

# record demo.sh from a specific video folder using VHS
record-demo folder:
  #!/usr/bin/env bash
  if ! command -v vhs &>/dev/null; then
    echo "Error: VHS is not installed"
    echo "Install with: go install github.com/charmbracelet/vhs@latest"
    exit 1
  fi
  demo_script="{{folder}}/demo.sh"
  if [ ! -f "$demo_script" ]; then
    echo "Error: Demo script not found at $demo_script"
    exit 1
  fi
  temp_tape=$(mktemp --suffix=.tape)
  output_file="{{folder}}/demo.gif"
  folder_name="{{folder}}"
  cat > "$temp_tape" << 'VHSEOF'
  Output demo.gif
  Set Width 1200
  Set Height 675
  Hide
  Type "clear"
  Enter
  Show
  Sleep 500ms
  Type "./demo.sh"
  Enter
  Sleep 30s
  VHSEOF
  sed -i "1s|demo.gif|$output_file|" "$temp_tape"
  echo "Recording demo from {{folder}}..."
  cd "{{folder}}" && vhs "$temp_tape"
  echo "Complete! Output: $output_file"
  rm "$temp_tape"
# render all diagrams in the entire repository
render-all:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "🎨 Rendering all diagrams in repository..."
  echo ""

  # Track statistics
  dot_count=0
  puml_count=0
  d2_count=0
  skipped=0

  # Check available tools
  has_grapheasy=$(command -v graph-easy &>/dev/null && echo "yes" || echo "no")
  has_plantuml=$([ -f /usr/local/bin/plantuml.jar ] && command -v java &>/dev/null && echo "yes" || echo "no")
  has_d2=$(command -v d2 &>/dev/null && echo "yes" || echo "no")

  echo "Tool availability:"
  echo "  graph-easy (for .dot): $has_grapheasy"
  echo "  plantuml (for .puml): $has_plantuml"
  echo "  d2 (for .d2): $has_d2"
  echo ""

  # Render .dot files with graph-easy
  if [ "$has_grapheasy" = "yes" ]; then
    echo "📊 Rendering .dot files..."
    while IFS= read -r file; do
      if [ -n "$file" ]; then
        dir=$(dirname "$file")
        base=$(basename "$file" .dot)
        output="$dir/$base.txt"

        echo "  → $file"
        graph-easy "$file" --as=boxart > "$output" 2>/dev/null || echo "    ⚠ Failed to render"
        ((dot_count++))
      fi
    done < <(find {{invocation_directory()}} -type f -name "*.dot" 2>/dev/null)
    echo ""
  else
    skipped=$(find {{invocation_directory()}} -type f -name "*.dot" 2>/dev/null | wc -l)
    [ $skipped -gt 0 ] && echo "⏭  Skipping $skipped .dot files (graph-easy not installed)"
  fi

  # Render .puml files with plantuml
  if [ "$has_plantuml" = "yes" ]; then
    echo "📊 Rendering .puml files..."
    while IFS= read -r file; do
      if [ -n "$file" ]; then
        dir=$(dirname "$file")
        mkdir -p "$dir/rendered"

        echo "  → $file"
        java -jar /usr/local/bin/plantuml.jar "$file" -o rendered -tsvg -quiet 2>/dev/null || echo "    ⚠ Failed to render"
        ((puml_count++))
      fi
    done < <(find {{invocation_directory()}} -type f -name "*.puml" 2>/dev/null)
    echo ""
  else
    skipped=$(find {{invocation_directory()}} -type f -name "*.puml" 2>/dev/null | wc -l)
    [ $skipped -gt 0 ] && echo "⏭  Skipping $skipped .puml files (plantuml not installed)"
  fi

  # Render .d2 files with d2
  if [ "$has_d2" = "yes" ]; then
    echo "📊 Rendering .d2 files..."
    while IFS= read -r file; do
      if [ -n "$file" ]; then
        dir=$(dirname "$file")
        base=$(basename "$file" .d2)
        mkdir -p "$dir/rendered"
        output="$dir/rendered/$base.svg"

        echo "  → $file"
        d2 "$file" "$output" 2>/dev/null || echo "    ⚠ Failed to render"
        ((d2_count++))
      fi
    done < <(find {{invocation_directory()}} -type f -name "*.d2" 2>/dev/null)
    echo ""
  else
    skipped=$(find {{invocation_directory()}} -type f -name "*.d2" 2>/dev/null | wc -l)
    [ $skipped -gt 0 ] && echo "⏭  Skipping $skipped .d2 files (d2 not installed)"
  fi

  echo "✅ Rendering complete!"
  echo "   .dot files: $dot_count"
  echo "   .puml files: $puml_count"
  echo "   .d2 files: $d2_count"

# render all diagrams in a specific video folder
render-video folder:
  #!/usr/bin/env bash
  set -euo pipefail

  folder_path="{{invocation_directory()}}/{{folder}}"

  if [ ! -d "$folder_path" ]; then
    echo "❌ Error: Folder '$folder_path' does not exist"
    exit 1
  fi

  echo "🎨 Rendering diagrams in: {{folder}}"
  echo ""

  # Track statistics
  dot_count=0
  puml_count=0
  d2_count=0

  # Check available tools
  has_grapheasy=$(command -v graph-easy &>/dev/null && echo "yes" || echo "no")
  has_plantuml=$([ -f /usr/local/bin/plantuml.jar ] && command -v java &>/dev/null && echo "yes" || echo "no")
  has_d2=$(command -v d2 &>/dev/null && echo "yes" || echo "no")

  # Render .dot files
  if [ "$has_grapheasy" = "yes" ]; then
    while IFS= read -r file; do
      if [ -n "$file" ]; then
        dir=$(dirname "$file")
        base=$(basename "$file" .dot)
        output="$dir/$base.txt"

        echo "📊 .dot → $base.txt"
        graph-easy "$file" --as=boxart > "$output" 2>/dev/null || echo "  ⚠ Failed"
        ((dot_count++))
      fi
    done < <(find "$folder_path" -type f -name "*.dot" 2>/dev/null)
  fi

  # Render .puml files
  if [ "$has_plantuml" = "yes" ]; then
    while IFS= read -r file; do
      if [ -n "$file" ]; then
        dir=$(dirname "$file")
        base=$(basename "$file" .puml)
        mkdir -p "$dir/rendered"

        echo "📊 .puml → rendered/$base.svg"
        java -jar /usr/local/bin/plantuml.jar "$file" -o rendered -tsvg -quiet 2>/dev/null || echo "  ⚠ Failed"
        ((puml_count++))
      fi
    done < <(find "$folder_path" -type f -name "*.puml" 2>/dev/null)
  fi

  # Render .d2 files
  if [ "$has_d2" = "yes" ]; then
    while IFS= read -r file; do
      if [ -n "$file" ]; then
        dir=$(dirname "$file")
        base=$(basename "$file" .d2)
        mkdir -p "$dir/rendered"
        output="$dir/rendered/$base.svg"

        echo "📊 .d2 → rendered/$base.svg"
        d2 "$file" "$output" 2>/dev/null || echo "  ⚠ Failed"
        ((d2_count++))
      fi
    done < <(find "$folder_path" -type f -name "*.d2" 2>/dev/null)
  fi

  total=$((dot_count + puml_count + d2_count))

  if [ $total -eq 0 ]; then
    echo "ℹ️  No diagram files found in {{folder}}"
  else
    echo ""
    echo "✅ Rendered $total diagram(s)"
  fi

# remove all generated diagram files
clean-rendered:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "🧹 Cleaning rendered diagram files..."
  echo ""

  # Track what we're removing
  txt_count=0
  rendered_dirs=0

  # Remove .txt files from diagrams/ directories
  while IFS= read -r file; do
    if [ -n "$file" ]; then
      echo "  🗑  $file"
      rm -f "$file"
      ((txt_count++))
    fi
  done < <(find {{invocation_directory()}} -type f -name "*.txt" -path "*/diagrams/*" 2>/dev/null)

  # Remove rendered/ directories
  while IFS= read -r dir; do
    if [ -n "$dir" ]; then
      echo "  🗑  $dir/"
      rm -rf "$dir"
      ((rendered_dirs++))
    fi
  done < <(find {{invocation_directory()}} -type d -name "rendered" 2>/dev/null)

  echo ""
  echo "✅ Cleanup complete!"
  echo "   .txt files removed: $txt_count"
  echo "   rendered/ directories removed: $rendered_dirs"

# watch diagrams in a folder and auto-render on changes
watch-diagrams folder:
  #!/usr/bin/env bash
  set -euo pipefail

  folder_path="{{invocation_directory()}}/{{folder}}"

  if [ ! -d "$folder_path" ]; then
    echo "❌ Error: Folder '$folder_path' does not exist"
    exit 1
  fi

  if ! command -v entr &>/dev/null; then
    echo "⚠️  'entr' is not installed. Using polling mode (5 second interval)..."
    echo "   For better performance, install entr: apt-get install entr"
    echo ""
    echo "👀 Watching diagrams in: {{folder}}"
    echo "   Press Ctrl+C to stop"
    echo ""

    # Simple polling mode
    declare -A last_modified

    while true; do
      changed=0

      # Check all diagram files
      for ext in dot puml d2; do
        while IFS= read -r file; do
          if [ -n "$file" ]; then
            current_time=$(stat -c %Y "$file" 2>/dev/null || echo "0")

            if [ "${last_modified[$file]:-0}" != "$current_time" ]; then
              last_modified[$file]=$current_time

              # Only render if file was previously seen (not first run)
              if [ $changed -eq 0 ]; then
                echo "🔄 Change detected, rendering..."
                changed=1
              fi
            fi
          fi
        done < <(find "$folder_path" -type f -name "*.$ext" 2>/dev/null)
      done

      if [ $changed -eq 1 ]; then
        just render-video {{folder}}
        echo ""
        echo "👀 Watching for changes..."
      fi

      sleep 5
    done
  else
    # Use entr for efficient watching
    echo "👀 Watching diagrams in: {{folder}}"
    echo "   Press Ctrl+C to stop"
    echo ""

    find "$folder_path" -type f \( -name "*.dot" -o -name "*.puml" -o -name "*.d2" \) 2>/dev/null | \
      entr -c just render-video {{folder}}
  fi

# generate comprehensive VIDEO_INDEX.md
index:
  #!/usr/bin/env bash
  set -euo pipefail

  OUTPUT_FILE="VIDEO_INDEX.md"
  REPO_ROOT="{{justfile_directory()}}"
  cd "$REPO_ROOT"

  echo "# YouTube Content Index" > "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "> 🎥 Comprehensive index of all video content" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Generate statistics
  total_videos=0
  declare -A categories

  # First pass: collect data
  temp_data=$(mktemp)

  for dir in */; do
    # Skip hidden and special folders
    [[ "$dir" == ".*" || "$dir" == "_"* ]] && continue
    dir="${dir%/}"

    # Find presentation file
    pres_file=""
    if [[ -f "$dir/presentation.md" ]]; then
      pres_file="$dir/presentation.md"
    elif [[ -f "$dir/slides.md" ]]; then
      pres_file="$dir/slides.md"
    else
      continue
    fi

    # Extract title
    title=""
    # Try frontmatter title first
    if grep -q "^title:" "$pres_file" 2>/dev/null; then
      title=$(grep "^title:" "$pres_file" | head -1 | sed 's/title: *//' | sed 's/^["'\'']//' | sed 's/["'\'']$//')
    fi
    # If no frontmatter title or it's "Replace Me", use first heading
    if [[ -z "$title" || "$title" == "Replace Me" ]]; then
      title=$(grep -m1 "^# " "$pres_file" | sed 's/^# *//' | sed 's/ 🎬$//' | sed 's/ [🎥🚀🔧🛠️⚡💡📊🌟✨].*$//')
    fi
    # Fallback to directory name
    [[ -z "$title" ]] && title=$(echo "$dir" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

    # Get date from git log
    date=$(git log --diff-filter=A --format='%ai' -- "$pres_file" 2>/dev/null | tail -1 | cut -d' ' -f1)
    [[ -z "$date" ]] && date=$(git log --format='%ai' -- "$pres_file" 2>/dev/null | tail -1 | cut -d' ' -f1)
    [[ -z "$date" ]] && date="Unknown"

    # Extract brief description (first few words after introduction)
    description=$(grep -A5 "## Introduction" "$pres_file" 2>/dev/null | grep -v "^#" | grep -v "^-" | grep -v "^\`" | grep -v "^>" | grep -v "^$" | head -1 | sed 's/^[- ]*//' | cut -c1-100)
    [[ -z "$description" ]] && description="YouTube tutorial content"

    # Detect category from folder name
    category=$(echo "$dir" | sed 's/-.*$//' | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

    # Group common categories
    case "$dir" in
      vim-*|nvim-*|*-vim-*) category="Vim/Neovim" ;;
      kubernetes-*|k8s-*|vcluster-*|kai-*) category="Kubernetes" ;;
      docker-*|dockerfile*) category="Docker" ;;
      bash-*|terminal-*|commandline-*) category="Terminal/Shell" ;;
      *-automation|fabric-*) category="Automation" ;;
      *-tools|*-cli-*) category="Tools" ;;
      direnv|dotfiles|backups) category="Development Environment" ;;
      computing-*|cv-*) category="Computer Science" ;;
    esac

    echo "$category|$date|$title|$dir|$description" >> "$temp_data"
    ((total_videos++))
    categories["$category"]=1
  done

  # Add statistics section
  echo "## 📊 Statistics" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "- **Total Videos**: $total_videos" >> "$OUTPUT_FILE"
  echo "- **Categories**: ${#categories[@]}" >> "$OUTPUT_FILE"
  echo "- **Last Updated**: $(date '+%Y-%m-%d %H:%M:%S')" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Generate table of contents
  echo "## 📑 Table of Contents" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  sort -u "$temp_data" | cut -d'|' -f1 | sort -u | while read -r cat; do
    anchor=$(echo "$cat" | tr '[:upper:]' '[:lower:]' | tr ' /' '-')
    echo "- [$cat](#$anchor)" >> "$OUTPUT_FILE"
  done
  echo "" >> "$OUTPUT_FILE"

  # Generate content by category
  echo "---" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  sort -t'|' -k1,1 -k2,2r "$temp_data" | awk -F'|' '
    BEGIN {current_cat = ""}
    {
      if ($1 != current_cat) {
        if (current_cat != "") print ""
        current_cat = $1
        count = 0
        print "## " current_cat
        print ""
      }
      count++
      printf "### %d. %s\n", count, $3
      printf "\n"
      printf "- 📁 **Folder**: [`%s`](./%s)\n", $4, $4
      printf "- 📅 **Date**: %s\n", $2
      printf "- 📝 **Description**: %s\n", $5
      printf "\n"
    }
  ' >> "$OUTPUT_FILE"

  rm -f "$temp_data"

  echo "✅ Generated $OUTPUT_FILE with $total_videos videos across ${#categories[@]} categories"

  # Display with glow if available
  if command -v glow &>/dev/null; then
    glow "$OUTPUT_FILE"
  fi

# generate index organized by topic/category
index-by-topic:
  #!/usr/bin/env bash
  set -euo pipefail

  OUTPUT_FILE="VIDEO_INDEX_BY_TOPIC.md"
  REPO_ROOT="{{justfile_directory()}}"
  cd "$REPO_ROOT"

  echo "# YouTube Content Index (By Topic)" > "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "> 🗂️ Videos organized by topic and category" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Collect all topics/tags
  declare -A topic_map
  temp_topics=$(mktemp)

  for dir in */; do
    [[ "$dir" == ".*" || "$dir" == "_"* ]] && continue
    dir="${dir%/}"

    pres_file=""
    if [[ -f "$dir/presentation.md" ]]; then
      pres_file="$dir/presentation.md"
    elif [[ -f "$dir/slides.md" ]]; then
      pres_file="$dir/slides.md"
    else
      continue
    fi

    # Extract topics from folder name parts
    topics=$(echo "$dir" | tr '-' '\n' | grep -v "^$")

    while read -r topic; do
      [[ -z "$topic" ]] && continue
      topic_clean=$(echo "$topic" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
      echo "$topic_clean|$dir" >> "$temp_topics"
    done <<< "$topics"
  done

  # Sort and group by topic
  sort -t'|' -k1,1 -k2,2 "$temp_topics" | awk -F'|' '
    BEGIN {current_topic = ""}
    {
      if ($1 != current_topic) {
        if (current_topic != "") print ""
        current_topic = $1
        print "## " current_topic
        print ""
      }
      printf "- [`%s`](./%s)\n", $2, $2
    }
  ' >> "$OUTPUT_FILE"

  rm -f "$temp_topics"

  echo "✅ Generated $OUTPUT_FILE"

  if command -v glow &>/dev/null; then
    glow "$OUTPUT_FILE"
  fi

# show repository statistics
stats:
  #!/usr/bin/env bash
  set -euo pipefail

  REPO_ROOT="{{justfile_directory()}}"
  cd "$REPO_ROOT"

  echo "📊 YouTube Repository Statistics"
  echo "================================="
  echo ""

  # Count videos
  video_count=$(find . -maxdepth 2 -type f \( -name "slides.md" -o -name "presentation.md" \) | wc -l)
  echo "📹 Total Videos: $video_count"

  # Count by category
  echo ""
  echo "📂 Videos by Category:"

  declare -A categories
  for dir in */; do
    [[ "$dir" == ".*" || "$dir" == "_"* ]] && continue
    dir="${dir%/}"

    [[ ! -f "$dir/presentation.md" && ! -f "$dir/slides.md" ]] && continue

    category=$(echo "$dir" | sed 's/-.*$//' | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

    case "$dir" in
      vim-*|nvim-*|*-vim-*) category="Vim/Neovim" ;;
      kubernetes-*|k8s-*|vcluster-*|kai-*) category="Kubernetes" ;;
      docker-*|dockerfile*) category="Docker" ;;
      bash-*|terminal-*|commandline-*) category="Terminal/Shell" ;;
      *-automation|fabric-*) category="Automation" ;;
      *-tools|*-cli-*) category="Tools" ;;
      direnv|dotfiles|backups) category="Development Environment" ;;
      computing-*|cv-*) category="Computer Science" ;;
    esac

    if [[ -n "${categories[$category]+x}" ]]; then
      ((categories["$category"]++))
    else
      categories["$category"]=1
    fi
  done

  if [[ ${#categories[@]} -gt 0 ]]; then
    for cat in "${!categories[@]}"; do
      printf "  %-25s %3d videos\n" "$cat:" "${categories[$cat]}"
    done | sort
  fi

  # Recent activity
  echo ""
  echo "📅 Recent Activity (Last 10 commits):"
  git log --oneline --decorate -10 --pretty=format:"  %ar - %s" 2>/dev/null || echo "  No git history available"

  echo ""
  echo ""
  echo "💾 Repository Size:"
  du -sh . | awk '{print "  Total: " $1}'

  echo ""
  echo "🔍 Most Common Topics:"
  find . -maxdepth 1 -type d ! -name "." ! -name ".*" ! -name "_*" -exec basename {} \; | \
    tr '-' '\n' | sort | uniq -c | sort -rn | head -10 | \
    awk '{printf "  %-20s %3d occurrences\n", $2":", $1}'

# list videos matching a topic
find-topic topic:
  #!/usr/bin/env bash
  set -euo pipefail

  TOPIC="{{topic}}"
  REPO_ROOT="{{justfile_directory()}}"
  cd "$REPO_ROOT"

  echo "🔍 Videos matching topic: $TOPIC"
  echo "=================================="
  echo ""

  found=0
  for dir in */; do
    [[ "$dir" == ".*" || "$dir" == "_"* ]] && continue
    dir="${dir%/}"

    # Check if topic matches folder name
    if echo "$dir" | grep -qi "$TOPIC"; then
      pres_file=""
      if [[ -f "$dir/presentation.md" ]]; then
        pres_file="$dir/presentation.md"
      elif [[ -f "$dir/slides.md" ]]; then
        pres_file="$dir/slides.md"
      else
        continue
      fi

      title=""
      if grep -q "^title:" "$pres_file" 2>/dev/null; then
        title=$(grep "^title:" "$pres_file" | head -1 | sed 's/title: *//' | sed 's/^["'\'']//' | sed 's/["'\'']$//')
      fi
      if [[ -z "$title" || "$title" == "Replace Me" ]]; then
        title=$(grep -m1 "^# " "$pres_file" | sed 's/^# *//')
      fi
      [[ -z "$title" ]] && title="$dir"

      date=$(git log --format='%ai' -- "$pres_file" 2>/dev/null | tail -1 | cut -d' ' -f1)
      [[ -z "$date" ]] && date="Unknown"

      echo "📁 $dir"
      echo "   Title: $title"
      echo "   Date:  $date"
      echo ""
      ((found++))
    fi
  done

  if [[ $found -eq 0 ]]; then
    echo "❌ No videos found matching topic: $TOPIC"
    echo ""
    echo "💡 Try one of these topics:"
    find . -maxdepth 1 -type d ! -name "." ! -name ".*" ! -name "_*" -exec basename {} \; | \
      tr '-' '\n' | sort -u | grep -v "^$" | head -20 | column
  else
    echo "✅ Found $found video(s)"
  fi

# show N most recently modified videos
recent n="10":
  #!/usr/bin/env bash
  set -euo pipefail

  N="{{n}}"
  REPO_ROOT="{{justfile_directory()}}"
  cd "$REPO_ROOT"

  echo "🕒 $N Most Recently Modified Videos"
  echo "===================================="
  echo ""

  temp_file=$(mktemp)

  for dir in */; do
    [[ "$dir" == ".*" || "$dir" == "_"* ]] && continue
    dir="${dir%/}"

    pres_file=""
    if [[ -f "$dir/presentation.md" ]]; then
      pres_file="$dir/presentation.md"
    elif [[ -f "$dir/slides.md" ]]; then
      pres_file="$dir/slides.md"
    else
      continue
    fi

    # Get last modification date from git
    date=$(git log -1 --format='%ai' -- "$dir" 2>/dev/null | cut -d' ' -f1)
    timestamp=$(git log -1 --format='%at' -- "$dir" 2>/dev/null)

    if [[ -z "$date" ]]; then
      date=$(stat -c '%y' "$pres_file" 2>/dev/null | cut -d' ' -f1)
      timestamp=$(stat -c '%Y' "$pres_file" 2>/dev/null)
    fi

    [[ -z "$timestamp" ]] && timestamp=0

    title=""
    if grep -q "^title:" "$pres_file" 2>/dev/null; then
      title=$(grep "^title:" "$pres_file" | head -1 | sed 's/title: *//' | sed 's/^["'\'']//' | sed 's/["'\'']$//')
    fi
    if [[ -z "$title" || "$title" == "Replace Me" ]]; then
      title=$(grep -m1 "^# " "$pres_file" | sed 's/^# *//')
    fi
    [[ -z "$title" ]] && title="$dir"

    echo "$timestamp|$date|$dir|$title" >> "$temp_file"
  done

  sort -t'|' -k1,1rn "$temp_file" | head -n "$N" | awk -F'|' '{
    printf "%s  📁 %s\n", $2, $3
    printf "             %s\n\n", $4
  }'

  rm -f "$temp_file"
