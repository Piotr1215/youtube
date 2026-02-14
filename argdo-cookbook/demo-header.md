# Add Header Demo

## Before: script.sh
```bash
echo "Hello World"
```

## After running:
:args testfiles/*.sh
:argdo 0put ='#!/usr/bin/env bash' | update

## Result: script.sh
```bash
#!/usr/bin/env bash
echo "Hello World"
```

## Variations:
- 0r file.txt     → read file at line 0
- 0put ='text'    → put text at line 0
- $r file.txt     → read file at end
- $put ='text'    → put text at end
