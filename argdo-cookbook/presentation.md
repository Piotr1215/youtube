# Neovim Batch Commands Cookbook

<!-- new_lines: 3 -->

```bash +exec_replace
echo "Batch Commands" | figlet -f small -w 90
```

<!-- end_slide -->

# The "Do" Family

```bash +exec_replace
cat << 'EOF' | ccze -A
Commands that execute operations across MULTIPLE targets

• argdo  → each file in argument list
• bufdo  → each loaded buffer
• windo  → each visible window
• tabdo  → each tab page
• cdo    → each quickfix ENTRY
• cfdo   → each quickfix FILE
EOF
```

<!-- end_slide -->

# Why Use These?

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Execute any Ex command across multiple targets

WHY: Batch operations without external tools

• Rename function across 50 files? argdo
• Fix all linter errors? cfdo
• Set options in all windows? windo
• No sed, no find -exec, no scripts
EOF
```

<!-- end_slide -->

# Foundation: The Argument List

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Files passed to vim or set with :args

WHY: argdo operates on THIS list, not buffers
EOF
```

| Command | Effect |
|---------|--------|
| `:args` | Show current argument list |
| `:args **/*.js` | Set args to all JS files |
| `:args `find . -name "*.py"`` | Set args from shell |
| `:argadd %` | Add current file to args |
| `:next` / `:prev` | Navigate argument list |

```bash +acquire_terminal
nvim demo-args.md
```

<!-- end_slide -->

# Recipe 1: Project-Wide Search/Replace

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Replace text across all project files

WHY: Rename variables, functions, imports in one command
EOF
```

```vim
:args **/*.js
:argdo %s/oldFunction/newFunction/ge | update
```

| Flag | Meaning |
|------|---------|
| `g` | All occurrences per line |
| `e` | No error if pattern not found |
| `update` | Save only if modified |

```bash +acquire_terminal
nvim demo-replace.md
```

<!-- end_slide -->

# Recipe 2: Add Header to All Files

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Insert content at top of every file

WHY: Add license, copyright, or boilerplate
EOF
```

```vim
:args **/*.sh
:argdo 0r ~/templates/license.txt | update
```

| Variant | Command |
|---------|---------|
| Add shebang | `:argdo 0put ='#!/usr/bin/env bash' \| update` |
| Add 'use strict' | `:argdo 0put =\"'use strict';\" \| update` |
| Append footer | `:argdo $r ~/footer.txt \| update` |

```bash +acquire_terminal
nvim demo-header.md
```

<!-- end_slide -->

# Recipe 3: Run Macro on All Files

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Apply recorded macro to every file

WHY: Complex edits that substitution can't handle
EOF
```

```vim
" Record macro in register q first
:args **/*.md
:argdo normal @q | update
```

```bash +exec_replace
cat << 'EOF' | ccze -A
Example: Wrap first heading in brackets
1. Record: qq 0i[ $a ] q
2. Apply:  :argdo normal @q | update
EOF
```

```bash +acquire_terminal
nvim demo-macro.md
```

<!-- end_slide -->

# The Quickfix Workflow

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: cdo/cfdo operate on grep/make results

WHY: Review matches BEFORE changing them
EOF
```

```bash +exec_replace
cd /home/decoder/dev/youtube/argdo-cookbook && just digraph workflow
```

| Command | Operates on |
|---------|-------------|
| `cdo` | Each quickfix ENTRY (same file multiple times) |
| `cfdo` | Each quickfix FILE (deduplicated) |

<!-- end_slide -->

# Recipe 4: grep → replace

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Find all matches, review, then replace

WHY: Safer than blind argdo - you see matches first
EOF
```

```vim
:grep 'deprecated_api' **/*.py
:copen                          " review the matches
:cfdo %s/deprecated_api/new_api/gc | update
```

```bash +exec_replace
cat << 'EOF' | ccze -A
The 'c' flag = confirm each replacement
Skip with n, accept with y, all with a
EOF
```

```bash +acquire_terminal
nvim demo-grep.md
```

<!-- end_slide -->

# Recipe 5: Fix Linter Errors

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Process each error from :make or linter

WHY: Systematic fix of all reported issues
EOF
```

```vim
:make                           " or :lmake for location list
:copen                          " see all errors
:cdo s/errro/error/g | update   " fix typo in all locations
```

| Quickfix navigation | Effect |
|---------------------|--------|
| `:cnext` / `:cprev` | Jump to next/prev error |
| `:cfirst` / `:clast` | Jump to first/last |
| `:cc 5` | Jump to error #5 |

```bash +acquire_terminal
nvim demo-linter.md
```

<!-- end_slide -->

# Recipe 6: bufdo Quick Wins

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Execute command in all loaded buffers

WHY: Affect everything currently open
EOF
```

| Recipe | Command |
|--------|---------|
| Save all | `:bufdo update` |
| Reload all | `:bufdo e!` |
| Set option | `:bufdo set expandtab` |
| Close matching | `:bufdo if match(bufname('%'), 'test') >= 0 \| bd \| endif` |

```bash +exec_replace
cat << 'EOF' | ccze -A
Tip: 'update' saves only if modified
     'write' saves unconditionally
EOF
```

<!-- end_slide -->

# Recipe 7: windo for Windows

```bash +exec_replace
cat << 'EOF' | ccze -A
WHAT: Execute command in all visible windows

WHY: Sync settings across your current layout
EOF
```

| Recipe | Command |
|--------|---------|
| Sync to top | `:windo normal gg` |
| Toggle numbers | `:windo set nu!` |
| Set width | `:windo vertical resize 80` |
| Disable wrap | `:windo set nowrap` |
| Same cursor | `:windo normal 10G` |

```bash +acquire_terminal
nvim demo-windo.md
```

<!-- end_slide -->

# Pro Tips

```bash +exec_replace
cat << 'EOF' | ccze -A
1. Set 'hidden' option first
   → :set hidden (allows unsaved buffer switching)

2. Always use | update (not | w)
   → Only saves if buffer was modified

3. Use 'e' flag in substitutions
   → No error when pattern not found

4. Preview with :argdo without | update
   → See changes before committing

5. Combine with :silent for clean output
   → :silent argdo %s/a/b/ge | update
EOF
```

<!-- end_slide -->

# Recap

| Command | Target | Best For |
|---------|--------|----------|
| `argdo` | Argument list | Project-wide refactoring |
| `bufdo` | All buffers | Currently open files |
| `windo` | All windows | Layout-wide settings |
| `tabdo` | All tabs | Tab-specific operations |
| `cdo` | QF entries | Per-match operations |
| `cfdo` | QF files | Per-file from grep |

<!-- end_slide -->

# That's All Folks!

<!-- new_lines: 3 -->

```bash +exec_replace
echo "Thanks!" | figlet -f small -w 90
```
