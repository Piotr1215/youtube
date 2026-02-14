# Understanding :args

Try these commands:

## Check current argument list
:args

## Set argument list (REPLACES existing)
:args testfiles/*.md      " replaces args with testfiles .md files
:args testfiles/*.js      " replaces args with all JS files

## Add to argument list (NON-DESTRUCTIVE)
:argadd testfiles/*.md    " adds testfiles .md to existing args
:argadd %           " adds current file to args

## Navigate the list
:next
:prev
:first
:last

## Clear/remove from argument list
:argdelete %        " remove current file
:argdelete *.md     " remove matching files
:%argdelete         " clear entire list
:argdelete *        " also clears entire list

## The argument list is SEPARATE from buffers!
## bufdo = all buffers
## argdo = only files in :args
