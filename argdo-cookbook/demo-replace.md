# Project-Wide Replace

## Modernize var → const across all JS files
:args testfiles/*.js
:argdo %s/var/const/ge | update
