# Performance Script

The story is what happens in the viewer's mind; the screen is what helps it happen. Each moment says what the viewer is wondering as it starts, what the presenter does and says, what is on screen, and what the viewer is left wondering. That last line is the next moment's first. Slides come from the Screen lines afterwards, and only where speech and the live tools cannot do the job.

Three revelations carry the video:

1. Code has structure (moment 7).
2. Structure is not meaning (moment 13).
3. Meaning can drive edits that stay within bounds (moment 16).

One open loop runs through it: the cold open shows the result and names the viewer's objection, "my coding agent could do that". Moment 17 closes it with demonstrations.

Times are targets. Status notes mark what is not yet built or run.

## Cold open (0:00 to 1:00)

### 1. The result first

- Viewer: nothing yet; deciding whether to stay.
- Screen: the six log lines from the service, all `log.Printf("...", value)`; then the real triage run, giving each line its fate.
- Do: show the lines, pause, run the command.
- Say: "Six log lines. To grep, to your editor, to the compiler, they look the same. One command. One is deleted, two become slog.Info, three wait for me, and a model wrote none of this code."
- Leaves: how did it tell them apart?

### 2. The objection, named

- Viewer: my coding agent could do that.
- Screen: presenter only.
- Say: "You're thinking your coding agent could do this in one prompt. For six lines, it could. At the end I'll run this again, show you every edit it is allowed to make, and none of it leaves this laptop."
- Leaves: a promise to collect, and the first question still open.

## The problem (1:00 to 2:30)

### 3. The change

- Viewer: what change, and why would I make it?
- Screen: the slog code and its real output, every value named.
- Say: "Since Go 1.21, slog gives every logged value a name, so you filter on user=ana instead of grepping a sentence."
- Leaves: worth doing; a find and replace, surely?

### 4. Why find and replace fails here

- Viewer: surely a find and replace?
- Screen: every log line in the service, from a real search; then the usual ways and what each costs.
- Say: "An error becomes slog.Error, a leftover 'got here' should go, a startup message becomes slog.Info, and a line that prints a password needs a person. Find and replace changes them all the same way, by hand stops working at a few hundred, and an agent writes new code you then review line by line."
- Leaves: so what would it take?

### 5. The route

- Viewer: what would it take?
- Screen: the chapter map.
- Say: "Four steps, and each exists because the one before it hits a wall. We'll hit each wall."
- Leaves: oriented, waiting for the first wall.

## Text (2:30 to 3:30)

### 6. grep looks right

- Viewer: I'd just grep for it.
- Screen: three calls in a small file, then the real grep for the calls that log err.
- Do: run grep, let the two hits sit, then point at lines 13 and 15.
- Say: "Two hits. Done? Line 13 is a call split over two lines, and grep missed it. Line 15 is a comment, and grep matched it. You can patch the regex for each case, and the next layout needs another patch, because a regex never knows what a call is."
- Leaves: what does know what a call is?

## Structure (3:30 to 6:30)

### 7. Revelation 1: code has structure

- Viewer: what knows what a call is?
- Screen: Neovim, live, the same file with the syntax tree open beside it. No slide.
- Do: `:InspectTree`; put the cursor on the split call, and one call node lights up across both lines; move to the comment, and it is a comment node.
- Say: "This is how the compiler reads code, and your editor already builds this tree to highlight it. The split call is one call. The comment is a comment, never a call."
- Leaves: can I search that?

### 8. Searching with code

- Viewer: how would I search a tree?
- Screen: the pattern `log.Printf($FMT, err)` beside the tree it becomes, the placeholder marked.
- Say: "There's no query language to learn. You write the code you're looking for, with a placeholder where it changes, and the pattern becomes a tree too."
- Leaves: does it get that file right?

### 9. Same question, right answer

- Viewer: does it get that file right?
- Screen: the real ast-grep run on the same file.
- Say: "Same file, same question: the split call found, the comment skipped."
- Leaves: can it change them too?

### 10. Rewriting by structure

- Viewer: can it change them too?
- Screen: the error rule file, its fix highlighted; then the real diff for every error line in the service.
- Say: "The placeholder remembers what it matched, so the new line is built from the old one. As a rule, it runs the same way on every line, and nothing changes until you've read the diff."
- Leaves: momentum. Do the rest the same way.

## Meaning (6:30 to 9:30)

### 11. The wall: same shape

- Viewer: write a rule for the rest.
- Screen: one pattern, `log.Printf($FMT, $ARG)`, matching three lines that need three different fixes.
- Say: "Here the tree gives up. All three are a call with a message and a value. What decides the fix is what the line is for, and that isn't in the tree."
- Leaves: then what decides? This is the deck's tension peak.

### 12. The idea

- Viewer: then what decides?
- Screen: `line → classif → one answer from our list → its rule`.
- Say: "Telling what text means is what language models are good at. We don't let it write. We ask one question, and it may only answer from our list."
- Leaves: show me.

### 13. Revelation 2: three answers

- Viewer: show me.
- Screen: the real triage of three lines with one shape: debug 0.96, info 0.99, and an unsure 0.72.
- Do: run, and let each answer land before the next.
- Say: "Same shape, three answers. A local model, about a third of a second a line, and it wrote nothing."
- Leaves: what if it's wrong?
- Status: debug 0.92 ran as a direct call in 0.35 s; info and sensitive come from the triage run. The three-call command still needs writing.

### 14. When it isn't sure

- Viewer: what if it's wrong?
- Screen: two outcomes: 0.92, apply the fix; 0.55, leave it for a person. A footnote: a rule for acting, not the chance of being right.
- Say: "Acting on a guess can damage code. 'retrying in' could be either, the scores say so, and below 0.85 nothing changes. I picked 0.85 from a few runs; your own labeled lines should pick yours."
- Leaves: reassured. How does an answer become an edit?

## Action (9:30 to 13:00)

### 15. Where the edit comes from

- Viewer: how does an answer become an edit?
- Screen: the debug rule file, with the question, the answer and the fix highlighted.
- Say: "Each answer points at a rule written in advance. This file is everything 'debug' can do: delete the line. The model picks; the rule edits."
- Leaves: so every possible edit sits in these files.

### 16. Revelation 3: one operation

- Viewer: what happens across the whole service?
- Screen: the real full run on a copy.
- Do: run it, and name each step as it lands.
- Say: "Errors to slog.Error, events to slog.Info, the debug print gone, the risky lines left for me, the import added, build and vet green, and here's the diff."
- Leaves: the cold open, now understood, and the objection is back.

### 17. Closing the loop

- Viewer: my agent could still have done this.
- Screen: every fix the rules can write, from the rule files themselves.
- Say: "On six lines your agent is fine. On six hundred you'd review six hundred hand-written edits, and a second run would write different ones. Here every edit is one of these rules, every decision comes with a score you can check, the unsure lines wait for you, and log lines with passwords never left the laptop."
- Leaves: convinced, ready for the limits.

### 18. What the checks catch and miss

- Viewer: what can still go wrong?
- Screen: a right deletion that breaks the build, with the real compiler error; then what the checks catch and what they miss.
- Say: "A right answer can still break the build. The compiler stops it, and your files stay as they were. A wrong answer that still builds gets through, which is why you read the diff, and why a line that can leak a secret gets no fix at all."
- Leaves: an honest picture. Would this work for me?

## Your setup (13:00 to 15:00)

### 19. When it fits

- Viewer: would this work for me?
- Screen: the four conditions, and the one that rules it out.
- Say: "Every change can be a rule, the structure can't pick between them, the deciding fact is in the text, and a wrong answer is easy to spot in the diff."
- Leaves: I have a change like that.

### 20. In your editor (optional)

- Viewer: does this live only in scripts?
- Screen: Neovim, live: the same rules flag the lines as you read, and the fix is one key away.
- Leaves: I could use this tomorrow.

### 21. The takeaway

- Viewer: what do I keep?
- Screen: presenter, then Takeaways.
- Say: "The model adds meaning between two deterministic steps and replaces neither."

### 22. Start

- Viewer: where do I start?
- Screen: the tools and links.
- Say: "Pick one change in your code that's right for only some of the places it matches."

## Open decisions

1. Hook screen in moment 1: the triage output, which shows each line's fate, or the final diff, which shows the code.
2. Scale: a run on a real open-source Go repo with hundreds of log calls would let moment 17 show the point, not argue it. This is new work, not built or run.
3. The printf formatting limit (the %x line): one sentence in moment 10, or its own slide.
4. The four-step plan slide: the chapter map in moment 5 may be enough.
5. Codex's earlier sensitivity veto, still yours to decide.

Once this is approved, the narrative beats change to match (the cold open and the open loop are new, and the editor beat moves to moment 20), and the slides follow.
