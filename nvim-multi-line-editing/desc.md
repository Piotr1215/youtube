Neovim nightly now has native multicursor. Where does it fit next to the methods we already had?

This video puts every built-in way to edit many lines at once side by side, then counts keystrokes on the same exercises to see which method wins where.

This video covers:
- Visual block (Ctrl-v, I, A): type into a column of rows
- Normal on a range (:%norm): run normal-mode keys on every line
- Global command (:g and :v): run a command on lines picked by a pattern
- Substitution (:s): rewrite every regex match, with groups and case changes
- External commands (:%!): pass lines through any CLI tool
- Macros (q and @): record an edit once, replay it anywhere
- Multicursor (Q): a cursor on each line or match, every edit lands at once
- A rule of thumb for picking the right method
- Keystroke golf: three exercises played live, nine on the scoreboard

Multicursor needs a Neovim nightly build until 0.13 ships. Everything else works in any Neovim, and in Vim.

00:00 Methods overview
15:40 Keystroke golf demo
23:03 Scoreboard and takeaways

Presentation: https://github.com/Piotr1215/youtube/blob/main/nvim-multi-line-editing/presentation.md
Exercises: https://github.com/Piotr1215/youtube/tree/main/nvim-multi-line-editing/exercises
Multicursor pull request: https://github.com/neovim/neovim/pull/41587
Dotfiles: https://github.com/Piotr1215/dotfiles
