# Narrative

The story of the video, written before any slide. Each numbered beat is one moment of the story: what the presenter says, in two or three sentences. The story decides how many slides a beat needs. Each part becomes a chapter. The slides are the presenter's props, not the source of the story: a real file, real command output, a diagram or the chapter map, never what the presenter says aloud. A beat marked live has no slide; the presenter shows it in Neovim. When the slides and this file disagree, this file wins.

## Journey

- Problem the viewer knows: making the same change in many places of a codebase.
- Why the usual ways fall short: find and replace sees only text, by hand does not scale, and an AI assistant writes new code that needs a line-by-line review.
- What the viewer needs to understand: code tools can recognize text, understand structure, judge meaning, and act on that judgment, and each job can go to the tool that does it reliably.
- How each step leads to the next: text search cannot see code, so syntax trees; structure cannot see meaning, so a model judges; a model should not edit code, so it only picks among rules written in advance; a right edit can still break the build, so the compiler checks before anything is written.
- So what: a change that depends on what code means can be automated without a model writing any code.
- Now what: write each possible change as a rule, let a model pick among them, and let the compiler check the result.
- Then what: try it on a change in your own code that is right for only some places, and set the threshold from labeled examples.
- What the viewer can do at the end: automate a change whose right edit differs from place to place, without a model writing code, with every edit a readable rule checked by the compiler.

## Narration

### Opening

1. We open on the result: a diff where some log lines became slog calls, one was deleted, and others were left alone, with no line of it written by a model. Your coding agent could do six lines; the end shows what this gives you that it does not. Every codebase eventually needs the same change in many places: a library swap, an API change, a new convention. Find and replace only sees text, doing it by hand does not scale, and an AI assistant writes new code that someone has to review line by line.

2. Our example: since Go 1.21 the standard library has structured logging, log/slog, where every logged value has a name you can filter on. Moving a service from the older log.Printf to slog is a change many Go teams face.

3. The catch is that the log lines need different changes. An error becomes slog.Error, a leftover "got here" should be deleted, a startup message becomes slog.Info, and a line that prints a password needs a person to decide.

4. So the right change depends on what each line is for. To automate it we have to find every log line, see its structure, judge what each line is for, and apply the right change, and each of those steps exists because the one before it hits a wall.

### Text

5. grep finds every log.Printf instantly, but it only compares characters. Ask it for the calls that log err and it misses one split over two lines and matches one inside a comment. A smarter regex can patch each case, but every new layout needs another patch, and the regex never knows what a call or an argument is.

### Structure

6. To see code instead of characters, we read it the way a compiler does, as a syntax tree: a call, the function it calls, its arguments. Spacing and line breaks are gone, and a comment becomes a comment node, never a call.

7. Your editor already builds this kind of tree, with tree-sitter, to highlight and select code. In Neovim you can open it beside the code and watch each part light up. Live in Neovim, no slide.

8. We search the tree by writing the code we want to find, with a placeholder where it may differ: log.Printf($FMT, err). The pattern becomes a tree too, so ast-grep matches by shape: it finds every call whose second argument is err, whatever the line breaks, and a commented-out call is not a call.

9. Finding is half the job: we want every error line rewritten the same way, without hand edits. The placeholders remember what they matched, so the new line is built from the old one: our first rule turns each error line into slog.Error, with the error as a named field. Captured as a rule, with a pattern to find, a transform to reshape the message and a fix to write, the change runs the same way on every line, every time.

10. Running the rule prints that rewrite as a diff for every line that logs an error; with -U, ast-grep writes it into the files. These lines need no judgment: the code itself says they log an error.

11. Not every line can be rewritten this way, because a rewrite must never change what a log says. slog keeps the value but not printf formatting: a %x line that printed session 1f would print id=31, and a search for the hex id would find nothing. So no rule rewrites such a line; another rule flags it for a person, so no line is skipped without a word. Said in passing, no slide.

12. The same rules run inside your editor: each line is flagged as you read it, and the rule's fix is one key away. Optional, live in Neovim, no slide.

13. The remaining lines each need a different fix: delete the debug print, move the event to slog.Info, leave the password line for a person. To automate them we must pick the right fix for each line, but by structure they all look the same, a call with a message and one value. A rule carries one fix, and what picks the right one is what the line means, which is not in the tree.

### Meaning

14. Understanding what a line means, beyond its structure, is what language models do well, but a chat model answers in free text and often rewrites the code too. We want the understanding without the writing.

15. classif asks a model on your own machine one question, "What is this log line for?", and accepts only an answer from your list: debug or info. For "got here" it answers debug.

16. Why trust an answer like that? classif never lets the model write: it reads the probability the model gives each of your answers and takes the highest. That number ranks the answers; it is not the chance the answer is right, which only checking the model against lines with known answers can tell you. The 0.85 floor here, below which nothing changes, came from a few trial runs, and the scores move a little from run to run.

### Action

17. An answer on its own changes nothing, so each answer gets its own ast-grep rule file, with the question and the answer next to its fix: debug deletes the line and info writes slog.Info. A second question, asked of every line on its own, checks whether the value is a secret or personal data, because a useful event can still print an email address; a yes stops any fix, and the line waits for a person. Every possible change is a rule you can read before the model runs, and the model only chooses.

18. ast-grep finds every line and reads the question from the rule files, and classif answers. Asked about every line, the model sends the events to slog.Info and the debug print to deletion. It leaves the lines that print a password or an email address for a person, and a retry message it was unsure about.

19. Before your files change, the result has to pass the checks you would run yourself. The changes run on a copy, goimports adds the import, and go build and go vet must pass.

20. Those checks catch real mistakes. If the debug line was the only use of a variable, deleting it is right, but Go refuses to compile, and your files stay as they were.

21. They also have a limit: they prove the code compiles, not that every change was right. A line the model wrongly called debug would be deleted and still build, so every change ends as a diff a person reads, and lines that can leak a secret get no fix at all.

22. Run together, the rules move errors and events to slog, remove the debug print, leave the risky lines for a person, and end with code that builds.

### Close

23. This fits when every possible change can be written as a rule, structure cannot pick between them, the deciding fact is in the text the model sees, and a wrong answer is easy to catch in the diff.

24. The model adds meaning between two deterministic steps and replaces neither. Start with a change in your own code that is right for only some of the places it matches.

25. To try it you need ast-grep, Ollama with a local model for classif, and Go's own tools.
