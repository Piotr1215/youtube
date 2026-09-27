# Pattern vs Position

<!-- new_lines: 3 -->

```bash +exec_replace
echo "nvim > Multicursor" | figlet -f small -w 90
```

<!-- end_slide -->

# Two Ways to Think

```bash +exec_replace
cat << 'EOF' | ccze -A
MULTICURSOR: "Place cursor HERE and HERE, same keystrokes"
             → Position-based, breaks on irregular data

VIM NATIVE:  "Describe PATTERN, describe TRANSFORM"
             → Pattern-based, handles any structure
EOF
```

<!-- end_slide -->


# 1. Visual Block (Ctrl-V)

```bash +exec_replace
cat << 'EOF' | ccze -A
Ctrl-V → select rectangle → I or A → type → Esc

Perfect for:
- Adding same prefix to multiple lines
- Deleting columns of text
- Inserting at exact positions

Example: Add "- " prefix to 10 lines
  Ctrl-V → 10j → I → "- " → Esc
EOF
```

<!-- end_slide -->

# 2. Normal Command (:norm)

```bash +exec_replace
cat << 'EOF' | ccze -A
:%norm xf]D
       ↑ ↑ ↑
       │ │ └─ D  = delete to end
       │ └─── f] = find ]
       └───── x  = delete [

Just motions. No escaping. No magic syntax.
Works on any range: :'<,'>norm xf]D
EOF
```

<!-- end_slide -->

# 3. Macros on Range

```bash +exec_replace
cat << 'EOF' | ccze -A
Record once: qq → {edits} → q
Apply to range: :'<,'>norm @q

Perfect for:
- Complex multi-step edits
- Edits requiring insert mode
- Repeatable transformations

Example: Wrap each line in quotes
  qq → I" → Esc → A" → Esc → q
  :%norm @q
EOF
```

<!-- end_slide -->

# 4. Substitution (:s)

```bash +exec_replace
cat << 'EOF' | ccze -A
:%s/\v\[([^\]]*)\]/"\1"/g
      ↑    ↑      ↑
      │    │      └─ Replace with quoted
      │    └──────── Capture contents
      └───────────── Very magic mode

Wins when you need:
- Case transforms (\u, \l, \U, \L)
- Arithmetic (\=submatch(0)+1)
- Multiple replacements per line (/g)
EOF
```

<!-- end_slide -->

# When to Use Which

| Technique | Best for |
|-----------|----------|
| Visual block | Column ops (prepend, delete column) |
| :norm | Daily driver - motion-based edits |
| :s | Specialist - case, math, multi-match |
| macro | Complex multi-step with insert mode |

```bash +exec_replace
cat << 'EOF' | ccze -A
:norm covers 80% of cases with simpler mental model
:s shines for computational transforms (case, math)
EOF
```

<!-- end_slide -->

# Key Commands

| Technique | Command |
|-----------|---------|
| Visual block | `Ctrl-V` → select → `I`/`A` → type → `Esc` |
| Normal on range | `:'<,'>norm {keys}` |
| Macro on range | `:'<,'>norm @q` |
| Substitution | `:%s/pattern/replace/g` |

<!-- end_slide -->

# Demo

<!-- new_lines: 3 -->

```bash +exec_replace
echo "DEMO" | figlet -f small -w 90
```

<!-- end_slide -->

# That's All Folks!

<!-- new_lines: 3 -->

```bash +exec_replace
echo "Think patterns" | figlet -f small -w 90
```
