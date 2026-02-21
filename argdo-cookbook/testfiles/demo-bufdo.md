# [bufdo]

## [Load buffers]
:badd testfiles/utils.js
:badd testfiles/index.js
:badd testfiles/app.js

## [Check loaded buffers]
:ls

## [Record macro: add "use strict"; at top]
qq gg O"use strict"; Esc q

## [Replay macro across all buffers]
:bufdo normal @q | update

## [Verify]
:bufdo %p
