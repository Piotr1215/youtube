# grep → replace

## Find matches
:vimgrep /TODO/ testfiles/*.py

## Review
:copen

## Replace per-file
:cfdo %s/TODO/DONE/g | update
