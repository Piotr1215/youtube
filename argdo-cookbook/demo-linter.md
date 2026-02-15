# Linter Errors

## Setup eslint as compiler
:compiler eslint

## Run linter
:make testfiles/*.js
:copen

## Fix == to === across quickfix entries
:cdo s/==/===/ge | update

## Fix var to const per-file
:cfdo %s/\<var\>/const/ge | update

## Re-run to verify
:make testfiles/*.js
