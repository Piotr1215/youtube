# Narrative

The story of the video, written before any slide. Each numbered beat is one moment of the story: what the presenter says, in two or three sentences. The story decides how many slides a beat needs. Each part becomes a chapter. When the slides and this file disagree, this file wins.

## Journey

- Problem the viewer knows: making the same change in many places of a codebase.
- Why the usual ways fall short: find and replace sees only text, by hand does not scale, and an AI assistant writes new code that needs a line-by-line review.
- What the viewer needs to understand: code tools can recognize text, understand structure, judge meaning, and act on that judgment, and each job can go to the tool that does it reliably.
- How each step leads to the next: text search cannot see code, so syntax trees; structure cannot see purpose, so a model judges; a model should not edit code, so it only picks among rules written in advance; a right edit can still break the build, so the compiler checks before anything is written.
- So what: a change that depends on what code means can be automated without a model writing any code.
- Now what: write each possible change as a rule, let a model pick among them, and let the compiler check the result.
- Then what: try it on a change in your own code that is right for only some places, and set the threshold from labeled examples.
- What the viewer can do at the end: automate a change whose right edit differs from place to place, without a model writing code, with every edit a readable rule checked by the compiler.

## Narration

### Opening

1. Every codebase eventually needs the same change in many places: a library swap, an API change, a new convention. Find and replace only sees text, doing it by hand does not scale, and an AI assistant writes new code that someone has to review line by line.

2. Our example: since Go 1.21 the standard library has structured logging, log/slog, where every logged value has a name you can filter on. Moving a service from the older log.Printf to slog is a migration many Go teams face.

3. The catch is that the log lines need different changes. An error becomes slog.Error, a leftover "got here" should be deleted, a startup message becomes slog.Info, and a line that prints a password needs a person to decide.

4. So the right change depends on what each line is for. To automate it, a tool has to recognize text, understand structure, judge meaning, and act on that judgment, and each of those steps exists because the one before it hits a wall.

### Text

5. grep finds every log.Printf instantly, but it only compares characters. It misses a call split over two lines, matches a call inside a comment, and cannot ask for calls whose argument is the error.

### Structure

6. To see code instead of characters, a tool has to read it the way a compiler does, as a syntax tree: a call, the function it calls, its arguments. Spacing, line breaks and comments are gone, and the structure is left.

7. Your editor already builds this kind of tree, with tree-sitter, to highlight and select code. In Neovim you can open it beside the code and watch each part light up.

8. ast-grep searches that tree with patterns written as code. log.Printf($FMT, err) finds every call whose second argument is err, whatever the line breaks, and a commented-out call is not a call.

9. Finding is half the job. The placeholders remember what they matched, so a rule can rewrite it: our first rule turns each error line into slog.Error, with the error as a named field.

10. Running the rule shows a diff for every line that logs an error, before anything changes. These lines need no judgment: the code itself says they log an error.

11. Not every line can be rewritten this way. slog keeps the value but not printf formatting, so a line with a %x or a padded width is never rewritten; another rule flags it for a person, so no line is skipped without a word.

12. The same rules run inside your editor. Open the file in Neovim and each error line is flagged as you read it, and the rule's fix is one key away.

13. The remaining lines all look the same to ast-grep: a call with a message and one value. A rule carries one fix, any one fix is wrong for the others, and what separates them is purpose, which is not in the tree.

### Meaning

14. Reading for purpose is what language models do well, but a chat model answers in free text and often rewrites the code too. We want the reading without the writing.

15. classif asks a model on your own machine one question, "What is this log line for?", and accepts only an answer from your list: debug, info or sensitive. For "got here" it answers debug.

16. Why trust an answer like that? classif never lets the model write: it reads the probability the model gives each of your answers and takes the highest. That number ranks the answers; it is not the chance the answer is right, which only checking the model against lines with known answers can tell you. The 0.9 floor here, below which nothing changes, came from a few trial runs.

### Action

17. An answer on its own changes nothing, so each answer gets its own ast-grep rule: debug deletes the line, info writes slog.Info, and sensitive has no fix, so the line waits for a person. Every possible change is a rule you can read before the model runs, and the model only chooses.

18. Asked about every line, the model sends the events to slog.Info and the debug print to deletion. It leaves the lines that print a password or an email address for a person, and a retry message it was unsure about.

19. Before your files change, the result has to pass the checks you would run yourself. The migration runs on a copy, goimports adds the import, and go build and go vet must pass.

20. Those checks catch real mistakes. If the debug line was the only use of a variable, deleting it is right, but Go refuses to compile, and your files stay as they were.

21. They also have a limit: they prove the code compiles, not that every change was right. A line the model wrongly called debug would be deleted and still build, so every change ends as a diff a person reads, and lines that can leak a secret get no fix at all.

22. Run together, the whole migration moves errors and events to slog, removes the debug print, leaves the risky lines for a person, and ends with code that builds.

### Close

23. This fits when every possible change can be written as a rule, structure cannot pick between them, the deciding fact is in the text the model sees, and a wrong answer is easy to catch in the diff.

24. The model adds meaning between two deterministic steps and replaces neither. Start with a change in your own code that is right for only some of the places it matches.

25. To try it you need ast-grep, Ollama with a local model for classif, and Go's own tools.
