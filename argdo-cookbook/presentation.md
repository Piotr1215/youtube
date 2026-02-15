# Neovim Batch Commands Cookbook

<!-- new_lines: 3 -->

```bash +exec_replace
echo "Batch Commands" | figlet -f small -w 90
```

```bash +exec_replace
cp testfiles-origin/* testfiles/
```

<!-- end_slide -->

# The "Do" Family

```bash +exec_replace
printf '\e[33m%s\e[0m\n\n' "Commands that execute operations across MULTIPLE targets"
printf '  \e[35m•\e[0m \e[32m%-8s\e[0m → %s\n' "argdo" "each file in argument list"
printf '  \e[35m•\e[0m \e[32m%-8s\e[0m → %s\n' "bufdo" "each loaded buffer"
printf '  \e[35m•\e[0m \e[32m%-8s\e[0m → %s\n' "windo" "each visible window"
printf '  \e[35m•\e[0m \e[32m%-8s\e[0m → %s\n' "tabdo" "each tab page"
printf '  \e[35m•\e[0m \e[32m%-8s\e[0m → %s\n' "cdo" "each quickfix ENTRY"
printf '  \e[35m•\e[0m \e[32m%-8s\e[0m → %s\n' "cfdo" "each quickfix FILE"
```

<!-- end_slide -->

# Why Use These?

```bash +exec_replace
printf '\e[33m%s\e[0m %s\n\n' "WHAT:" "Execute any Ex command across multiple targets"
printf '\e[33m%s\e[0m %s\n\n' "WHY:" "Batch operations without external tools"
printf '  \e[35m•\e[0m %s \e[36m%s\e[0m\n' "Rename function across 50 files?" "argdo"
printf '  \e[35m•\e[0m %s \e[36m%s\e[0m\n' "Fix all linter errors?" "cfdo"
printf '  \e[35m•\e[0m %s \e[36m%s\e[0m\n' "Set options in all windows?" "windo"
printf '  \e[35m•\e[0m %s\n' "Pure Vim — replace sed, find -exec, and shell scripts"
```

<!-- end_slide -->

# Foundation: The Argument List

```bash +exec_replace
printf '\e[33m%s\e[0m %s\n\n' "WHAT:" "Files passed to vim or set with :args"
printf '\e[33m%s\e[0m %s\n' "WHY:" "argdo operates on THIS list, not buffers"
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
printf '\e[33m%s\e[0m %s\n\n' "WHAT:" "Replace text across all project files"
printf '\e[33m%s\e[0m %s\n' "WHY:" "Rename variables, functions, imports in one command"
```

```vim
:argdo[!] {cmd}    Execute {cmd} for each file in the argument list
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
printf '\e[33m%s\e[0m %s\n\n' "WHAT:" "Insert content at top of every file"
printf '\e[33m%s\e[0m %s\n' "WHY:" "Add license, copyright, or boilerplate"
```

```vim
:0put ='text'    Put expression result before first line
:0r {file}       Read file contents before first line
:$r {file}       Read file contents after last line
```

```bash +acquire_terminal
nvim demo-header.md
```

<!-- end_slide -->

# Recipe 3: Run Macro on All Files

```bash +exec_replace
printf '\e[33m%s\e[0m %s\n\n' "WHAT:" "Apply recorded macro to every file"
printf '\e[33m%s\e[0m %s\n' "WHY:" "Complex edits that substitution can't handle"
```

```vim
:argdo normal @{reg}    Execute macro {reg} in each argument file
```

```bash +acquire_terminal
nvim demo-macro.md
```

<!-- end_slide -->

# The Quickfix Workflow

```bash +exec_replace
printf '\e[33m%s\e[0m %s\n\n' "WHAT:" "cdo/cfdo operate on vimgrep/make results"
printf '\e[33m%s\e[0m %s\n' "WHY:" "Review matches BEFORE changing them"
```

```vim
:vimgrep[!] /{pattern}/ {file}    Search for pattern, populate quickfix
:cdo[!] {cmd}                     Execute {cmd} on each quickfix entry
:cfdo[!] {cmd}                    Execute {cmd} on each quickfix file
```

```bash +exec_replace
cd /home/decoder/dev/youtube/argdo-cookbook && just digraph workflow
```

| Command | Operates on |
|---------|-------------|
| `cdo` | Each quickfix ENTRY (same file multiple times) |
| `cfdo` | Each quickfix FILE (deduplicated) |

<!-- end_slide -->

# Recipe 4: vimgrep → replace

```bash +exec_replace
printf '\e[33m%s\e[0m %s\n\n' "WHAT:" "Populate quickfix with vimgrep, then act on each file"
printf '\e[33m%s\e[0m %s\n' "WHY:" "Targeted changes — only files that matched the pattern"
```

```vim
:cfdo[!] {cmd}    Execute {cmd} in each file in the quickfix list
```

| Confirm flag | Effect |
|--------------|--------|
| `y` | Replace this match |
| `n` | Skip this match |
| `a` | Replace all remaining |

```bash +acquire_terminal
nvim demo-grep.md
```

<!-- end_slide -->

# Recipe 5: Fix Linter Errors

```bash +exec_replace
printf '\e[33m%s\e[0m %s\n\n' "WHAT:" "Process each error from :make or linter"
printf '\e[33m%s\e[0m %s\n' "WHY:" "Systematic fix of all reported issues"
```

```vim
:compiler {name}    Set 'makeprg' and 'errorformat' for {name}
:make [args]        Run makeprg, parse output into quickfix list
:cdo[!] {cmd}       Execute {cmd} in each valid quickfix entry
```

| Step | What happens |
|------|-------------|
| `:compiler eslint` | Sets makeprg=eslint, errorformat to parse eslint output |
| `:make *.js` | Runs eslint, errors populate quickfix list |
| `:cdo {fix}` | Applies fix at each error location |

```bash +acquire_terminal
nvim demo-linter.md
```

<!-- end_slide -->

# Recipe 6: bufdo Quick Wins

```bash +exec_replace
printf '\e[33m%s\e[0m %s\n\n' "WHAT:" "Execute command in all loaded buffers"
printf '\e[33m%s\e[0m %s\n' "WHY:" "Affect everything currently open"
```

```vim
:bufdo[!] {cmd}    Execute {cmd} in each buffer in the buffer list
```

| Recipe | Command |
|--------|---------|
| Save all | `:bufdo update` |
| Reload all | `:bufdo e!` |
| Set option | `:bufdo set expandtab` |

```bash +acquire_terminal
nvim testfiles/demo-bufdo.md
```

<!-- end_slide -->

# Recipe 7: windo for Windows

```bash +exec_replace
printf '\e[33m%s\e[0m %s\n\n' "WHAT:" "Execute command in all visible windows"
printf '\e[33m%s\e[0m %s\n' "WHY:" "Sync settings across the current layout"
```

```vim
:windo[!] {cmd}    Execute {cmd} in each window in the current tab
```

| Recipe | Command |
|--------|---------|
| Sync to top | `:windo normal gg` |
| Toggle numbers | `:windo set nu!` |
| Set width | `:windo vertical resize 80` |
| Disable wrap | `:windo set nowrap` |

```bash +acquire_terminal
nvim demo-windo.md
```

<!-- end_slide -->

# Pro Tips

```bash +exec_replace
printf '  \e[32m%s\e[0m %s\n' "1." "Set 'hidden' option first"
printf '     \e[36m→\e[0m %s\n\n' ":set hidden (allows unsaved buffer switching)"
printf '  \e[32m%s\e[0m %s\n' "2." "Always use | update (not | w)"
printf '     \e[36m→\e[0m %s\n\n' "Only saves if buffer was modified"
printf '  \e[32m%s\e[0m %s\n' "3." "Use 'e' flag in substitutions"
printf '     \e[36m→\e[0m %s\n\n' "No error when pattern not found"
printf '  \e[32m%s\e[0m %s\n' "4." "Preview with :argdo without | update"
printf '     \e[36m→\e[0m %s\n\n' "See changes before committing"
printf '  \e[32m%s\e[0m %s\n' "5." "Combine with :silent for clean output"
printf '     \e[36m→\e[0m %s\n' ":silent argdo %%s/a/b/ge | update"
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
echo "That's All Folks!" | figlet -f small -w 90
```