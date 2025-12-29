# Neovim Terminal

Open terminals with the `term://` URI scheme.

## Usage

```vim
:edit term://bash          " shell in current buffer
:vsplit term://htop        " htop in vertical split
:tabnew term://python3     " python REPL in new tab
:split term://zsh          " zsh in horizontal split
```

## With Arguments

```vim
:terminal ls -la           " command with arguments
:terminal htop -d 10       " easier than escaping in URI
```

## Why term:// vs :terminal

- `term://` works with `:edit`, `:split`, `:vsplit`, `:tabnew`
- `:terminal` handles arguments naturally (no escaping needed)
