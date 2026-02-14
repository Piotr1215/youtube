# Macro Demo

## Task: Wrap all headings in brackets

### Before:
# Title One
# Title Two
# Title Three

### Record macro:
1. Position on first heading
2. qq         (start recording to q)
3. 0          (go to start)
4. f#         (find #)
5. a [        (append bracket)
6. $a ]       (append at end)
7. q          (stop recording)

### Apply to all files:
:args testfiles/*.md
:argdo normal @q | update

### After:
# [ Title One ]
# [ Title Two ]
# [ Title Three ]
