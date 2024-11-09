---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM, YYYY
paging: Slide %d / %d
---

# Automate Commands Expansion in Zsh with Abbreviations and Widgets 

```bash
~~~just intro_toilet ZLE Superpowers

~~~
```

---

## Introduction 👋

- ZLE (Zsh Line Editor) *Core text editing engine*
- Custom Widgets        *Extend functionality*
- Pattern Expansion     *Auto-expand text patterns*
- Buffer Manipulation   *Direct text control*

---

## Understanding ZLE Buffers 🧊

```bash
~~~just digraph buffer-vars

~~~
```

---

## ZLE Widget System 🧩

> ZLE widgets are customizable functions that enhance Zsh's command-line editing.

- Built-in Widgets:       
> `zle -la` to list all available widgets.
                                          
- User-Defined Widgets:  

```zsh
function open_file_git_staged() {
   __open-file-git-staged.sh 
}
bindkey "^[^O" open_file_git_staged  
zle -N open_file_git_staged
```

---

## Widget Flow 🌊
```bash
~~~just plantuml widget-flow

~~~
```

---

## Script Demo 🎬

```bash
tmux switchc -t zle-abbreviations
```

---

### Patterns to Functions 

```zsh
typeset -A abbrevs
abbrevs=(
    "_spo" '__sponge_expand'
    "_bak" '__backup_expand'
    "_ind" '__into_new_dir'
)
```

> Associative array maps patterns to functions

---

### Sponge Abbreviation 🧽

```bash                               
__sponge_expand() {                   
    local cmd="$LBUFFER"              # Capture left hand side
    local words=("${(z)cmd}")         # Split command into words
    local last_arg="${words[-1]}"     # Get last argument
    LBUFFER="$cmd | sponge $last_arg" # Expand command with the original command and sponge
}                                     
```                                   

---

### The Magic Behind Expansion 🪄

```bash
expand-abbrev() {
    local MATCH                           # variable to store the matched pattern
    LBUFFER=${LBUFFER%%(#m)[_a-zA-Z0-9]#} # Remove the pattern from the left
    if [[ -n "${abbrevs[$MATCH]}" ]]; then
        ${abbrevs[$MATCH]}                # Call the expansion function
    fi                                    
}
```

---

### Create Widget and Bind 󰏠

```bash
zle -N expand-abbrev                # Create widget
bindkey " " expand-abbrev           # Bind to space
bindkey -M isearch " " self-insert  # Remove binding in search mode
```

---

## Pattern Matching Explained ⬲

- `%%(#m)`             *removes the longest match of a pattern from the end of a string and `(#m)` match group* 
- `[_a-zA-Z0-9]#`      *character class capture alphanumeric characters and underscores.*
- `${abbrevs[$MATCH]}` *dictionary style matching by key* 


---

## Tips and Best Practices 💁

- Keep patterns memorable
- Use consistent naming
- Document expansions
- Test edge cases
- Consider context

---

## Resources 🧰

- Zsh Line Editor:    *`man zshzle`*
- Moreutils (sponge): *"The Power of Moreutils: 8 Advanced Linux Command Line Tools"*
- Pattern Matching:   *`man zshexpn`*
- Widget System:      *`man zshcontrib`*


---

```bash
../thats_all_folks
```

