# Fix Linter Errors Demo

## Setup: tell nvim to use eslint as linter
:compiler eslint

## Run the linter
:make testfiles/*.js

## View errors in quickfix
:copen

## Navigate errors
:cnext      " next error
:cprev      " previous error
:cc 3       " jump to error #3

## Fix all == to === across quickfix entries
:cdo s/==/===/ge | update

## Refresh quickfix with new results
:make testfiles/*.js

## Fix all var to const per-file
:cfdo %s/\<var\>/const/ge | update

## Re-run to verify fewer errors
:make testfiles/*.js
