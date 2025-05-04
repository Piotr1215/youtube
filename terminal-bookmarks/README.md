# Terminal and Neovim Bookmark Manager

This project implements a seamless bookmarking system that works from both tmux/terminal and Neovim. It allows you to bookmark files and directories, then quickly access them from either environment.

## Features

- **Unified Storage**: Single bookmarks file for consistency across environments
- **Two-Way Access**: 
  - From terminal: `Ctrl+L` in the sessionizer
  - From Neovim: Various `<leader>b` commands
- **Smart Handling**:
  - Files open directly in Neovim
  - Directories open either as tmux sessions or in a file explorer
- **Rich Management**:
  - Add current file (`<leader>ba`) or folder (`<leader>bA`)
  - Delete bookmarks interactively (`<leader>bd`)
  - List and select bookmarks (`<leader>bl`)
  - Edit bookmarks file directly (`<leader>be`)

## Implementation

### Terminal/tmux Side

The terminal-side implementation enhances the existing sessionizer script with bookmark capabilities:

1. A simple semicolon-delimited bookmarks file: `__bookmarks.conf`
2. FZF integration with the sessionizer via `Ctrl+L`
3. Smart file/directory detection using the `file` command
4. `__add_bookmark.sh` script for adding new bookmarks from terminal

### Neovim Side

The Neovim side has a full bookmark management system:

1. Add the current file or folder to bookmarks
2. List bookmarks with Telescope for interactive selection
3. Delete bookmarks with an interactive UI
4. Open the bookmarks file directly for manual editing

## Why It's Cool

1. **Seamless Context Switching**: Start from terminal or Neovim - your bookmarks follow you
2. **Environment-Appropriate Interfaces**: FZF in terminal, Telescope in Neovim
3. **Zero Configuration**: Bookmarks just work across environments
4. **Unobtrusive**: Integrates with existing workflows without disruption
5. **Path Intelligence**: Proper handling of files vs directories in each context

This system bridges the gap between terminal and editor workflows, creating a unified bookmark experience regardless of where you start. It acknowledges that development workflows cross these boundaries constantly and makes bookmark management natural in either context.

## Keybindings

### Terminal
- `Ctrl+L` in sessionizer - Access bookmarks

### Neovim
- `<leader>ba` - Add current file to bookmarks
- `<leader>bA` - Add current folder to bookmarks
- `<leader>bd` - Delete a bookmark
- `<leader>bl` - List bookmarks (with Telescope)
- `<leader>be` - Edit bookmarks file directly

## Implementation Details

The bookmark system uses a simple file format:
```
description;/path/to/file/or/directory
```

This makes it easy to parse in both Bash and Lua, while remaining human-readable and editable.