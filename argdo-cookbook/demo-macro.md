# Macro

## Record: wrap heading in brackets
qq 0 f# a [ $a ] q

## Apply to all markdown files
:args testfiles/*.md
:argdo normal @q | update
