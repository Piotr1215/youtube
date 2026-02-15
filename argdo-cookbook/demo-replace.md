# Project-Wide Replace

## Replace multiply → double across all JS files
:args testfiles/*.js
:argdo %s/multiply/double/ge | update
