---
theme: theme.json
author: Cloud-Native Corner 
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Direnv: Environment Variable Manager for Your Shell

```bash
~~~./intro.sh

~~~
```

> direnv is an environment variable manager for your shell. It knows how to hook
> into bash, zsh and fish shell to load or un‐ load environment variables
> depending on your current directory. This allows you to have project-specific
> environment variables and not clutter the " /.profile" file.

- 🔧 Manages environment variables per directory
- 🚀 Supports bash, zsh, and fish shells
- 🔒 Keeps your global profile clean
- 🔗 Enables project-specific configurations

---

# How Direnv Works


> Before each prompt it checks for the existence of an .envrc file in the
> current and parent directories. If the file exists, it is loaded into a bash
> sub-shell and all exported variables are then captured by direnv and then made
> available to your current shell, while unset variables are removed.

- 📂 Checks for `.envrc` files in current and parent directories
- 🔄 Loads `.envrc` into a bash sub-shell
- ⬆️ Exports variables to your current shell
- ⬇️ Removes unset variables

```bash
../npane ./test_direnv/.envrc
```

---

# Setting Up Direnv

1. Install direnv (e.g., `brew install direnv` on macOS)

2. Add to your shell configuration (e.g., .zshrc):
   ```bash
   eval "$(direnv hook zsh)"
   ```

3. Reload your shell configuration:
   ```bash
   source ~/.zshrc
   ```

---

## Demo: Security

🔒 `direnv allow` security feature prevents automatic execution of untrusted scripts.

> Let's see how it works in practice

```bash
../spane ./demo_direnv_setup.sh
```

---


## Direnv Stdlib Functions

Direnv provides a set of utility functions to use in your `.envrc` files:

- `PATH_add <path>`: Prepend the given path to the PATH environment variable
- `layout <type>`: Set up language-specific environments (e.g., python, node, ruby)
- `dotenv`: Load environment variables from a .env file
- `use <program> [version]`: Load external dependencies or language versions
- `watch_file <path>`: Trigger a reload when the specified file changes

---

## Practical Use Cases

1. 🐍 Python Virtual Environments - Automatically activate/deactivate venv
2. 🔑 API Keys and Secrets - Securely manage sensitive information
3. 🛠️ Project-Specific Tool Versions - Switch between Node.js, Ruby, or Go versions
4. 🌐 Multiple AWS Profiles - Easily switch between different AWS accounts
5. 📁 Custom PATH Additions - Add project-specific binaries to PATH
---

## Real-World Example: Kubernetes Config Management

This script demonstrates how to use direnv for managing Kubernetes configurations:

```bash
../npane ./separate-kubeconfig.sh
```

Key points:
- Creates a new directory with a `config` file for Kubernetes
- Generates an `.envrc` file that sets `KUBECONFIG` to the local config
- Uses `source_up` to inherit environment variables from parent directories
- Automatically allows the `.envrc` file for immediate use

---

## Create a Kubernetes Config

To use:
```bash
../spane ./demo_kubeconfig.sh
```

This setup allows for easy switching between different Kubernetes contexts by simply changing directories.

---

# Summary

Throughout this presentation, we've explored direnv and its powerful features:

1. 🔧 **Concept**: Direnv manages environment variables per directory, keeping your global profile clean.

2. 🚀 **Functionality**: It automatically loads/unloads variables as you navigate directories.

3. 🔒 **Security**: The `direnv allow` feature prevents automatic execution of untrusted scripts.

4. 🛠️ **Stdlib Functions**: We learned about useful functions like `PATH_add`, `layout`, and `use`.

5. 💼 **Practical Use Cases**: From managing Python environments to handling Kubernetes configs.

6. 🔬 **Real-World Example**: We saw how to use direnv for Kubernetes config management.

> Key Takeaway: Direnv simplifies environment management, enhances security, and boosts productivity across various development scenarios.
