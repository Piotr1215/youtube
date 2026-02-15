# Macro

## Record: wrap heading in brackets

## Apply to all markdown files
:args testfiles/*.md
:argdo %s/\v^#+ \zs.*/[&]/ | update
