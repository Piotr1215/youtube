# Project-Wide Replace Demo

These files have oldFunction that needs renaming:

## file1.js
```javascript
function oldFunction() {
  return "hello";
}
oldFunction();
```

## file2.js
```javascript
import { oldFunction } from './utils';
const result = oldFunction();
```

## The command:
:args testfiles/*.js
:argdo %s/oldFunction/newFunction/ge | update

## Flags explained:
- g = global (all occurrences)
- e = no error if not found
- | update = save if changed
