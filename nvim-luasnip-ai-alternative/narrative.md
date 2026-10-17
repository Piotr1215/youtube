# Narrative

The story of the video, written before any slide. Each numbered beat is one slide: what the presenter says over it, in two or three sentences. Each part becomes a chapter. When the slides and this file disagree, this file wins.

## Journey

- Problem the viewer knows: making the same change in many places of a codebase.
- Why the usual ways fall short: find and replace sees only text, by hand does not scale, and an AI assistant writes new code that needs a line-by-line review.
- What the viewer needs to understand: code tools can recognize text, understand structure, judge meaning, and act on that judgment, and each job can go to the tool that does it reliably.
- How each step leads to the next: text search cannot see code, so syntax trees; structure cannot see purpose, so a model judges; a model should not edit code, so it only picks among rules written in advance; a right edit can still break the build, so the compiler checks before anything is written.
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

6. A compiler reads code as a syntax tree: a call, the function it calls, its arguments, with spacing and comments gone. Your editor builds the same kind of tree with tree-sitter, and Neovim can show it beside the code.

7. ast-grep searches that tree with patterns written as code. log.Printf($FMT, err) finds every call whose second argument is err, whatever the line breaks.

8. The placeholders remember what they matched, so a rule can rewrite it. Our first rule turns each error line into slog.Error with the error as a named field, and shows the diff before changing anything.

9. The remaining lines all look the same to ast-grep: a call with a message and one value. A rule carries one fix, any one fix is wrong for the others, and what separates them is purpose, which is not in the tree.

### Meaning

10. Reading for purpose is what language models do well, but a chat model answers in free text and often rewrites the code too. We want the reading without the writing.

11. classif asks a model on your own machine one question, "What is this log line for?", and accepts only an answer from your list: debug, info or sensitive. For "got here" it answers debug.

12. It never lets the model write: it reads the model's score for each of your answers and takes the highest. That score is how sure the model is, not how often it is right, so below 0.9 nothing changes; the 0.9 came from a few trial runs and should be set from labeled examples.

### Action

13. Each answer gets its own ast-grep rule: debug deletes the line, info writes slog.Info, and sensitive has no fix, so the line waits for a person. Every possible change is a rule you can read before the model runs, and the model only chooses.

14. Asked about every line, the model sends the events to slog.Info and the debug print to deletion. It leaves the lines that print a password or an email address for a person, and a retry message it was unsure about.

15. Before your files change, the result has to pass the checks you would run yourself. The migration runs on a copy, goimports adds the import, and go build and go vet must pass.

16. A right answer can still break the build. If the debug line was the only use of a variable, Go refuses to compile, and your files stay as they were.

17. One command runs it all: errors and events move to slog, the debug print is gone, the risky lines wait for a person, and the code builds.

### Close

18. This fits when every possible change can be written as a rule, structure cannot pick between them, the deciding fact is in the text the model sees, and a wrong answer costs a review instead of broken code.

19. The model adds meaning between two deterministic steps and replaces neither. Start with a change in your own code that is right for only some of the places it matches.
