# Narrative

The story of the video, written before any slide. Each numbered beat is one moment of the story: what the presenter says, in two or three sentences. The story decides how many slides a beat needs. Each part becomes a chapter. The slides are the presenter's props, not the source of the story: a real file, real command output, a diagram or the chapter map, never what the presenter says aloud. A beat marked live has no slide of its own; the presenter shows it in Neovim. When the slides and this file disagree, this file wins.

The video climbs four levels: text search, structural search, rules, and a model's judgment on top. Level 3 is the payoff the viewer takes home. Level 4 is an experiment, shown with its limits.

## Journey

- Problem the viewer knows: making the same change in many places of a codebase, and keeping it made.
- Why the usual ways fall short: find and replace sees only text, by hand does not scale, and an AI assistant writes hundreds of new edits that each need a review.
- What the viewer needs to understand: code is a tree; you search the tree by writing code with placeholders; a rule captures a search and its rewrite so it runs the same way everywhere, from the shell or in the editor.
- How each step leads to the next: text search cannot see code, so syntax trees; a search is gone once it has run, so rules; rules cannot tell apart code with the same shape, so a model answers one question about each match.
- So what: a change you would make in a hundred places becomes one rule you can read, test and keep.
- Now what: write the rule, or have an AI draft it and let its tests check the draft; run it across the code; keep it running in your editor.
- Then what: where a rule needs a judgment structure cannot make, try a local model's answer as a suggestion, and trust it only as far as it proves right on your code.
- What the viewer can do at the end: search and rewrite code by structure with ast-grep, write and test rules, use them in Neovim, and know where a model's judgment helps and where it cannot be trusted alone.

## Subject and example

- Subject: working with code by its structure, from search to tested rules in your editor, with a model for the judgments structure cannot make.
- Example: moving a Go service from log.Printf to log/slog.

## Narration

### Opening

1. We open on the result: a diff where every line in a service that logs an error became a structured slog call. An AI helped write the rule behind it, but no AI wrote these edits: the rule did, and it would do the same on the next thousand lines.

2. Every codebase eventually needs the same change in many places: a library swap, an API change, a new convention. Find and replace only sees text, doing it by hand does not scale, and an AI assistant writes hundreds of new edits that someone has to review one by one.

3. Our example: since Go 1.21 the standard library has structured logging, log/slog, where every logged value has a name you can filter on. Moving a service from log.Printf to slog is a change many Go teams face.

### Text search

4. grep finds every log.Printf instantly, but it only compares characters. Ask it for the calls that log an error and it misses one split over two lines and matches one inside a comment. Every new layout needs another patch to the regex, because a regex never knows what a call is.

### Syntax trees

5. To see code instead of characters, we read it the way a compiler does, as a syntax tree: a call, the function it calls, its arguments. Your editor already builds this tree. In Neovim you can open it beside the code and watch the split call light up as one call, and the comment as a comment. Live in Neovim.

6. ast-grep searches that tree, and you write the search as code: the code you want to find, with a placeholder where it may differ. The pattern becomes a tree too, so it matches by shape: the split call is found and the comment is skipped.

### Rules

7. Finding is half the job. The placeholders remember what they matched, so the new line is built from the old one: the message without its format verb, and the error as a named field.

8. Written down as a rule, the search, the reshaping and the rewrite live in one small file you can read, commit and share. Its tests list code the rule must flag and code it must leave alone, so an edit to the rule that breaks either fails before it touches your code.

9. Run across the service, the rule rewrites every line that logs an error, and shows the change as a diff first.

10. The same rule runs in your editor. Neovim talks to ast-grep's language server, so every match is underlined as you read and its fix is one code action away. Write a new log.Printf with an error tomorrow and it is flagged as you type: the change is made once and stays made. Live in Neovim.

11. Writing rules takes practice, and this is where an AI assistant earns its place. Describe the change in a sentence and it drafts the rule and its tests. You do not trust the draft: you run its tests and read twenty lines, instead of reviewing three hundred edits. From then on the rule makes every edit, the same way every time, with no model involved.

12. Not every line can be rewritten by a rule. slog keeps the value but not printf formatting, so a %x line would lose its hex, and a second rule flags those lines for a person instead. Said in passing, no slide.

### Semantic checks

13. The lines left over look the same to the tree: a call with a message and a value. One is a debug print someone forgot, one is a startup event, one prints an email address. What sets them apart is what each line means, and no pattern can see that.

14. Telling what text means is what language models do well, but a chat model answers in free text and rewrites code along the way. classif asks a small model on your own machine one question about each match, and the model may only answer from your list: debug or info, yes or no. Each answer comes with a score.

15. The question lives in the rule, next to the fix each answer points to, so ast-grep asks it of every match and the answer picks which fix to suggest. In Neovim the question and the answer appear above each call, and you take the fix or leave it. Live in Neovim.

16. A second question looks at the same lines from another side: does this value hold a secret or personal data? A yes means no fix is suggested at all, and the line waits for a person.

17. This is an experiment, and its limits are real. The score ranks the answers; it is not the chance of being right. On forty test lines from code the model had never seen, the small model chose right about six times in ten, and some wrong answers came with high scores. A larger model on a laptop was right four times in five, but rarely sure. So the answers are suggestions you read, never edits that land on their own.

18. That still leaves an interesting possibility: a structural match plus one question a local model answers in about a third of a second, without your code leaving the machine. The question is yours to write, and the tree decides what the model reads.

### Close

19. Rules fit any change you can describe by its shape: a library swap, a review comment you keep writing, a pattern your team has banned. A model's question fits only where a person would decide by reading the code in front of them, and where a wrong answer costs a look, not a broken file.

20. Let the tree find and the rule rewrite; let a model suggest only where meaning decides. Start with a review comment you keep writing, and make it a rule.

21. To try it you need ast-grep, Neovim with its language server, and for the experiment, Ollama with a local model for classif.

## Sources for beat 17

Measured on 2026-10-17 with the deck's own question and answers, the function around each line as context, and the 0.85 floor. Twenty pairs of identical lines in different functions, written by an agent that did not see the rules; its intent for each line is the answer key, not a person's label. Small model, winnow 12B: 25 of 40 right, and 6 wrong answers scored above the floor. Larger model, ornith 35B on the Mac: 32 of 40 right, and 6 answers of the 40 scored above the floor, one of them wrong.

## Slides

Each line: the slide, the question the viewer has when it appears, and its state. Keep means the slide exists and stays; new needs building; cut leaves the deck.

### Opening

- Code Intelligence: title. Keep.
- Bulk Code Changes: why is changing code in many places still hard? Keep.
- Before and After: what does the end look like? Change: the diff from the error rule alone.
- From log.Printf to log/slog: what change, and why make it? Keep.
- The Log Lines in Our Service: how many places? Keep.
- The Usual Ways: surely a find and replace? Keep; the AI row says hundreds of edits to review.

### Text search

- Text Search: what does a text search see in code? Keep.
- Finding Error Calls with grep: would grep do? Keep.

### Syntax trees

- Syntax Trees: how do we see code as code? Keep.
- The Syntax Tree, Live: what does a tree look like? Keep, live in Neovim.
- A Pattern Written as Code: how do I search a tree? Keep.
- Finding Error Calls by Structure: does it get that file right? Keep.

### Rules

- Rules: how does a search become a change you keep? New divider.
- Building the New Line from the Old: can it change them too? Keep.
- The Rewrite as a Rule: where does that live? Keep.
- Rule Tests: how do I know the rule is right? New: the test file, then the test run.
- Every Error Line, Rewritten: what happens across the service? Keep.
- Rules in Neovim: does this live only in the shell? New, live: diagnostics and the code action.
- A Rule Drafted by an AI: do I have to learn to write these? New, live or replayed: one sentence, the draft, its tests.

### Semantic checks

- Semantic Checks: what can a model add where the tree cannot decide? Divider, renamed from Judging Meaning.
- Same Shape, Different Fixes: what is left? Keep, moved here.
- From Meaning to an Action: how could anything decide? Keep; it ends on the suggested fix.
- From the Rule to classif: where does the question come from? Keep, merged with The Debug Rule: the rule file, then the call it makes.
- Same Shape, Different Answers: does it tell them apart? Keep.
- classif in Neovim: what does that look like while I work? New, live: the question and answer above each call.
- A Second Question: what about the email line? Keep.
- Limits: can I trust it? New: the measured numbers.

### Your own codebase

- Your Own Codebase: when is this worth doing? Keep.
- Where Rules and Questions Fit: which of my changes fit? Rewritten from When a Model Should Pick the Change.
- Takeaways: what do I keep? Rewritten.
- Installing the Tools: how do I start? Keep; Neovim's language server row comes back.
- Resources, That's All Folks: keep.

### Cut

Sure and Unsure, The Debug Rule (merged), Acting on the Answer, The Whole Service, Every Edit These Rules Can Make, A Right Answer That Breaks the Build.

### To verify before building

- ast-grep's language server in Neovim, flagging and fixing in the deck's service.
- An AI drafting a rule that passes its tests from one sentence; if it needs tries, the slide replays a recorded run.
- The :Classif view, restored from git history (commit d892da5 deleted it).
