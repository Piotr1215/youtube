---
theme: ../theme.json
author: Cloud Native Corner
date: April, 2025
paging: Slide %d / %d
---

# Building a Personal Scripts Library 🚀

```bash
~~~just intro_toilet Scripts Library

~~~
```

---

## Introduction

In this video, you'll learn how to:

- 🎯 Create and organize a personal scripts library
- 🔧 Establish consistent naming conventions for your scripts
- 📝 Integrate your scripts into your shell environment
- 🔄 Build a collection of reusable code snippets
- 💡 Apply best practices for script development and maintenance

---

## Why Have a Scripts Library? 🤔

> A well-organized scripts library makes you more efficient and productive

- Automate repetitive tasks: *save time*
- Standardize operations:    *reduce errors*
- Document processes:        *knowledge preservation*
- Share with colleagues:     *collaboration*
- Build a personal toolkit:  *professional growth*

---

## Script Organization 📂

```bash
~~~ls -la /home/decoder/dev/dotfiles/scripts

~~~
```

---

## Naming Conventions 📝

- Use a consistent prefix to group scripts (`__`)
  - Example: `__detect_os.sh`, `__create_task.sh`

- Name scripts clearly based on function
  - Use verbs for action scripts (`__create_`, `__check_`)
  - Use nouns for information scripts (`__system_info.sh`)
  
- Use underscores to separate words
  - Improves readability
  - Easy to type
  - Avoids issues with spaces in filenames

---

## Adding Scripts to Your PATH 🛣️

In your `.zshrc` or `.bashrc`:

```bash
# Add scripts directory to PATH
export SCRIPTS_DIR="$HOME/dev/dotfiles/scripts"
export PATH="$PATH:$SCRIPTS_DIR"

# Make all scripts executable
if [ -d "$SCRIPTS_DIR" ]; then
  find "$SCRIPTS_DIR" -type f -name "*.sh" -exec chmod +x {} \;
fi

# Optional: Create aliases for frequently used scripts
alias detect-os="__detect_os.sh"
alias create-task="__create_task.sh"
```

---

## Code Snippets for Scripts 🧩

Store reusable code patterns as snippets:

- Bash header:        *script setup with strict mode*
- File reader:        *process files line by line*
- Parameter parser:   *handle command-line arguments*

---

## Best Practice: Script Headers

```bash
#!/usr/bin/env bash
set -euo pipefail  # Exit on error, undefined vars, pipe fails

# Script description
# Usage: script_name.sh [options] <arguments>
# Author: Your Name
# Date: April 2025
```

---

## Best Practice: Help Function

```bash
show_help() {
    echo "Usage: $(basename "$0") [options] <argument>"
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "  -v, --verbose Enable verbose output"
    echo "  -f, --file    Specify input file"
}
```

---

## Best Practice: Parameter Validation

```bash
if [[ $# -eq 0 ]]; then
    echo "Error: Missing required arguments"
    show_help
    exit 1
fi

# Validate file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: File not found: $input_file"
    exit 1
fi
```

---

## Best Practice: OS Detection

```bash
detect_os() {
    case "$(uname -s),$(uname -m)" in
        "Linux,x86_64")     echo "linux_amd64" ;;
        "Linux,aarch64")    echo "linux_arm64" ;;
        "Darwin,x86_64")    echo "mac_intel" ;;
        "Darwin,arm64")     echo "mac_m1" ;;
        *)                  echo "unsupported" ;;
    esac
}

# Use as a standalone command or source in other scripts
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_os
fi
```

---

## Best Practice: Reusable Functions

```bash
# Choose a function pattern that allows both direct use and sourcing
# Functions should be focused, documented, and handle errors

# Main function pattern for scripts that can be sourced
main() {
    # Script logic here
    echo "Running main functionality"
}

# Execute main only when script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

---

## Using AI Responsibly for Scripts 🤖

```bash
~~~just plantuml scripts-workflow

~~~
```

---

## Script Library Best Practices 💡

- Adopt consistent style:         *cohesive code organization*
- Include documentation:          *clear usage instructions*
- Use proper error handling:      *informative error messages*
- Make scripts modular:           *composable, focused functions*
- Test in isolation:              *verify before integration*
- Version control everything:     *track changes and history*
- Create fundamentals first:      *then let AI help with scripts*

---

## Resources 📚

- [Advanced Bash Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck](https://www.shellcheck.net/) - Script linter
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)
- [Awesome Shell](https://github.com/alebcay/awesome-shell) - Curated list of shell resources
- [explainshell.com](https://explainshell.com/) - Explain shell commands

---

## Demo Session

```bash
tmux switchc -t demo
```

---

# That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```
