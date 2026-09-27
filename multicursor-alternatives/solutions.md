# Keystroke Golf Solutions

Every row was run on Neovim 0.13-dev nightly with `--clean`; the cursor starts on line 1, column 1. Multicursor needs a nightly build until 0.13 ships.

| # | Exercise | Shortest other method | Keys | Multicursor | Keys |
|---|----------|--------------|------|-------------|------|
| 01 | add-prefix | `<C-V>GI- <Esc>` | **6** | `VGQI- <Esc>` | 7 |
| 02 | log-levels | `qqxf]D+q4@q` | 11 | `VGQxf]D` | **7** |
| 03 | brackets-to-quotes | `qqr"f]r"+q4@q` | 13 | `VGQr"f]r"` | **9** |
| 04 | first-field | `:%s/,.*<CR>` | 8 | `VGQf,D` | **6** |
| 05 | add-semicolons | `:%s/$/;<CR>` | 8 | `VGQA;<Esc>` | **6** |
| 06 | wrap-parens | `qqwi(<Esc>A)<Esc>+q4@q` | 14 | `VGQwi(<Esc>A)<Esc>` | **10** |
| 07 | flip-assignment | `qqdt=A=<Esc>p0xjq4@q` | 16 | `VGQdt=A=<Esc>p0x` | **12** |
| 08 | conditional-prefix | `:v/:/s/^/[ok] <CR>` | **15** | `/^\w*$<CR>1QI[ok] <Esc>` | 16 |
| 09 | snake-to-camel | `:%s/\v_(.)/\u\1/g<CR>` | 18 | `/_<CR>1Qx~` | **7** |

Notes:

- A macro that steps to the next line before `q` and replays with `4@q` costs its edit plus 7 keys, so it beats `:norm` and `:s` on 02, 03, 06 and 07. `+` steps to the first word; `j` keeps the column, which breaks 06 but suits 07, whose edit ends in column 1.
- The demo also plays `:%norm I- <CR>` (11) on 01, `:%s/ \zs.*/(&)<CR>` (15) on 06, `:%s/\v(.*)\=(.*)/\2=\1<CR>` (23) on 07, and `:v/:/norm! Q<CR>I[ok] <Esc>` (20) on 08.
- 07 pastes with `p` after `A=<Esc>`; an `x` before the paste would overwrite each cursor's register.
- 09 puts several cursors on one line: `1Q` adds one at every `_` match.
