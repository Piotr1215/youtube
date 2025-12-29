# Code Block Execution Demo

Place cursor in a code block and press `<leader>ev` to evaluate.
Output appears below the block.

## Bash Example

```bash
echo "Hello from bash!"
date +"%Y-%m-%d %H:%M:%S"
pwd
```

## Python Example

```python
import sys
print(f"Python {sys.version_info.major}.{sys.version_info.minor}")
print("2 + 2 =", 2 + 2)
```
