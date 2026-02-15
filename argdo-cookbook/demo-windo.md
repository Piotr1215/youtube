# windo

## Setup: open multiple windows
:vsp testfiles/file2.md
:sp testfiles/file3.md

## Sync all to top
:windo normal gg

## Toggle line numbers
:windo set nu!

## Set same width
:windo vertical resize 40

## Jump to line 10 in all
:windo normal 10G

## Disable wrap
:windo set nowrap

## Sync scrolling
:windo set scrollbind
:windo set noscrollbind
