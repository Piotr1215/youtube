# Keystroke Golf Solutions

Every row was run on Neovim 0.13-dev nightly with `--clean`; the cursor starts on line 1, column 1. Multicursor needs a nightly build until 0.13 ships.

| # | Exercise | Other method | Keys | Multicursor | Keys |
|---|----------|--------------|------|-------------|------|
| 01 | add-prefix | `<C-V>GI- <Esc>` | **6** | `VGQI- <Esc>` | 7 |
| 02 | log-levels | `:%norm xf]D<CR>` | 12 | `VGQxf]D` | **7** |
| 03 | brackets-to-quotes | `:%s/\v\[\|\]/"/g<CR>` | 16 | `VGQr"f]r"` | **9** |
| 04 | first-field | `:%s/,.*<CR>` | 8 | `VGQf,D` | **6** |
| 05 | add-semicolons | `:%s/$/;<CR>` | 8 | `VGQA;<Esc>` | **6** |
| 06 | wrap-parens | `:%s/ \zs.*/(&)<CR>` | 15 | `VGQwi(<Esc>A)<Esc>` | **10** |
| 07 | flip-assignment | `:%s/\v(.*)\=(.*)/\2=\1<CR>` | 23 | `VGQdt=A=<Esc>p0x` | **12** |
| 08 | conditional-prefix | `:v/:/norm I[ok] <CR>` | 17 | `/^\w*$<CR>1QI[ok] <Esc>` | **16** |
| 09 | snake-to-camel | `:%s/_\(\w\)/\u\1/g<CR>` | 19 | `/_<CR>1Qx~` | **7** |

Notes:

- 07 pastes with `p` after `A=<Esc>`; an `x` before the paste would overwrite each cursor's register.
- 08 can also mix both: `:v/:/normal! Q<CR>I[ok] <Esc>` places the cursors with a command and types the prefix live.
- 09 puts several cursors on one line: `1Q` adds one at every `_` match.
