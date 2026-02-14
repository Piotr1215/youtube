# grep → replace Workflow

## Step 1: Find all matches
:vimgrep /TODO/ testfiles/*.py

## Step 2: Review in quickfix
:copen

## Step 3: Replace per-file
:cfdo %s/TODO/DONE/g | update

The 'c' flag prompts for each:
- y = yes, replace
- n = no, skip
- a = all remaining
- q = quit

## Why cfdo not cdo?
- cdo = runs on EACH match (file2.py twice)
- cfdo = runs on EACH FILE (file2.py once)
