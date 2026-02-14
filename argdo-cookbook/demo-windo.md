# windo Demo

## Setup: Open multiple windows
:vsp testfiles/file2.md
:sp testfiles/file3.md

## Now you have 3 windows visible

## Sync all to top of file
:windo normal gg

## Toggle line numbers everywhere
:windo set nu!

## Set same width
:windo vertical resize 40

## Jump to line 10 in all
:windo normal 10G

## Disable wrap in all
:windo set nowrap

## Enable relative numbers
:windo set relativenumber

## Sync scrolling across all windows
:windo set scrollbind
" Now scrolling in any window scrolls all of them

## Disable scroll sync
:windo set noscrollbind
