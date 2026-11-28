# Narrative

The story of the video, written before any slide. Each numbered beat is one moment of the story: what the presenter says, in two or three sentences. Each part becomes a chapter. When the slides and this file disagree, this file wins.

The video follows one convenience for terminal power users: getting a value to where we type. It climbs from the mouse, through clipboard tools and fuzzy finders, to the point where they stop helping, and ends with a fuzzy menu that works in every window.

Every step has the same shape: the slide explains the step with a diagram of how it works, a green ✓ for what it fixes and a red ✗ for what it still cannot do; the demo shows it; the ✗ is the problem the next slide answers.

## Flow

Slide, demo, slide, demo. A demo slide shows the command about to run. Ctrl+E opens a new terminal window with a zsh in the dotfiles repo and that command typed at the prompt, up to the first `;;`, so the presenter's own keys start where the trigger does. The presenter shows the step, closes the window with Ctrl+D (bound to close it even with text at the prompt), is back on the slide, talks over it and moves on. Steps in the browser, a chat app or an email are shown by switching to that window and back.

A replayed tmux demo cannot work here: it types with `tmux send-keys`, which writes straight to the pane, while AutoKey watches the keyboard on the X server and never sees those keys, so no `;;` trigger would fire.

## Journey

- Problem the viewer knows: moving a value from where it is to where we are typing (a file path, a URL, an id) still sends us to the mouse or to another window.
- Why the usual ways fall short: mouse selection takes the hand off the keyboard; a clipboard manager and a copy alias need the value printed or copied first; fzf finds a file but the path still goes through the clipboard; Ctrl-T drops a path at the cursor, but only files and only in the shell; in the middle of a command, or in a chat or an email, we still leave to fetch the value.
- What the viewer needs to understand: a desktop-wide trigger can open the same kind of fuzzy menu they know from fzf, in any window; each trigger word points at a list; a list is a file, or a program that prints the values right now; the choice is pasted where the cursor is.
- So what: any value we need lands at the cursor, in any window, without leaving the keyboard or the half-typed command.
- Now what: it is the fzf idea, stretched over the whole desktop with AutoKey, rofi and a bash script.
- Then what: make a list for the value copied by hand most often, and give it a trigger word.

## Subject and example

- Subject: getting the value you need to the cursor, in any window, without breaking your flow.
- Example: a path, a URL and other values, first in a shell command, then in a chat and an email.

## Narration

### Copy and paste

1. As terminal power users we live on the keyboard. Yet one of the most common moves of the day still sends us to the mouse or another window: a file path, a project URL, a ticket id, a cloud account, today's date. Each lives somewhere other than where we need it.

2. With no tools at all, the path is on screen, so we reach for the mouse, drag across it, copy, click back and paste. It works in every app, and the hand leaves the keyboard every single time. Demo: `pwd`, then select and paste with the mouse.

3. In zsh, a global alias, a single capital C at the end of a command, sends its output to the clipboard while still showing it, so no mouse is needed. It copies only what a command prints, and each copy replaces the last. Demo: `pwd C`.

4. A clipboard manager keeps every copy, so something copied ten minutes ago is one pick away. It only holds what we copied before. Demo: `date C`, then the history menu (Ctrl+Alt+1) shows the date and the path from the step before.

### Fuzzy finding

5. Often we do not have the value on screen yet; we only know roughly what it is. fzf turns every file below the folder into a fuzzy menu: a few letters find the path, and it goes to the clipboard. Found and copied, but still pasted by hand. Demo: `fzf | xsel --clipboard`.

### Breaking the flow

6. Halfway through a command, the path is needed right at the cursor. fzf's Ctrl-T opens the same menu mid-command and drops the path there. For files below this folder, inside the shell, that is the right answer, and nothing more. Demo: `nvim`, then Ctrl-T.

7. Now the value is not a file: the address of a project page. We leave the command, open the browser, find the page, copy the URL, come back and paste. Every value is a trip away from the command. Demo: `curl -sI`, with the trip to the browser.

8. Outside the terminal it gets worse. In a chat or an email there is no shell, no fzf and no Ctrl-T, so every value goes through copy and paste by hand. Live in the apps.

### Semicolon shortcuts

9. What we want is the fuzzy menu we already like, in every window, fed by any list we choose, dropping the choice at the cursor. Two semicolons, a word and a space open a menu, and the chosen value lands where the cursor was, mid-command. Demo: `nvim ;;dot`.

10. The same keys work in the chat and the email, where nothing else did. Live in the apps.

11. Each word is its own list: notes, cloud account ids, open tasks, the agents running in tmux. A word can also hold fixed text and type it with no menu at all.

12. Nobody remembers every word. Two semicolons and a question mark list every trigger with what it does, and run the one we pick. Demo: `;;?`.

### Shortcut internals

13. AutoKey watches the keys on the whole desktop. When it sees two semicolons, a word and a space, it runs a bash script for that word; the script reads the word's list, shows it in rofi, a searchable menu like fzf that opens as its own window, and pastes the choice where the cursor was.

14. A list is a plain file, one value per line, with a label after the bar to search by. When the values change, the list is a small program instead, and the menu shows what it prints right now.

15. A trigger is a word and one line that runs the picker with its list name. The trigger fires on the space after the word, so a short word never swallows a longer one.

16. Registering a new list takes two steps: write the list, then point a word at it. Demo: a list of project pages gets the word docs, and the command from the detour takes the URL in two keys.

17. The value is pasted, not typed, so a chat app does not open its command menu on a leading slash and an editor does not add a bracket of its own.

### Getting started

18. On Linux with Xorg you need AutoKey and rofi; the script and example lists are in the presenter's public dotfiles. Start with the one list you reach for every day.

19. Any value lands at the cursor in any window, without leaving the keyboard. It is the fzf idea, spread over the whole desktop, so make a list for the value copied by hand most often.

## Facts checked

- C alias: `.zsh_aliases` line 14, `tee` to the screen and to `xsel --clipboard`, colour codes stripped.
- AutoKey is X11 only: its README says it will not work correctly under Wayland.
- fzf with no input lists the files below the current folder; Ctrl-T comes from `source <(fzf --zsh)`.
- Picker values are pasted with Shift+Insert, and the clipboard is restored a second later (`__value_picker.sh`).
- rofi runs with its default matching, words in order, so the `;;dot` demo searches `alacritty.toml`; fzf's fuzzy `alactoml` stays on the fzf and Ctrl-T slides.
- The clipboard manager is parcellite; Ctrl+Alt+1 opens its history.
- The demo shell unsets the fd-based `FZF_*_COMMAND` variables, so fzf and Ctrl-T use fzf's own walker.

## Slides

Each line: the slide and its demo. Every step slide carries the steps taken so far (`ladder.sh`, later steps hidden), a diagram of how the step works, a ✓ for what it fixes and a ✗ for the problem the next slide answers, with the demo command last.

- Semicolon Shortcuts: title.
- Copy and Paste: divider.
- Values Fetched All Day: table of values, where they live, where they are needed.
- Copying with the Mouse: hand-lane diagram; demo `pwd`.
- Copying What a Command Prints: tee diagram and the alias; demo `pwd C`.
- Clipboard History: diagram; demo `date C`, then Ctrl+Alt+1.
- Fuzzy Finding: divider.
- Any File as a Menu: flow diagram; demo `fzf | xsel --clipboard`.
- Breaking the Flow: divider.
- A Path at the Cursor: Ctrl-T diagram; demo `nvim`.
- The Mid-Command Detour: loop diagram; demo `curl -sI`.
- Outside the Terminal: table of windows and tools; live in the apps.
- Semicolon Shortcuts: divider.
- Two Semicolons and a Word: flow diagram; demo `nvim ;;dot`.
- In Every Window: the same table with a `;;` column; live in the apps.
- A Word for Every List: the trigger list.
- Every Trigger in One Menu: diagram; demo `;;?`.
- Shortcut Internals: divider.
- From Keys to Value: the whole path as a diagram, each piece handing its output to the next.
- Why These Pieces: piece, job, why this one.
- A List Is a File: the demo list and what each side of the bar does.
- A List Can Be a Program: the dotfiles list program and its output.
- A Word Points at a List: the trigger entry and the line it runs.
- A New List, Live: the two registration steps; demo `curl -sI ;;docs | head -1`.
- Pasted, Not Typed: rows.
- Getting Started: divider.
- Install: packages, the picker files, the trigger example and where a first list goes.
- Takeaways, Resources, That's All Folks.

## Demo state

- `;;docs` is the only change the demo makes to the desktop. `demo.toml` declares it as a live step, so `just reset` removes it.
- The demo shell is zsh with fzf's own key bindings and the C alias and nothing else, so the prompt shows no host, branch or cluster.
- `register` records what it added in `.registered` (gitignored) and refuses to touch a `docs` list or `;;docs` trigger it did not create; `unregister` removes only what that file names.
- Before recording: clear the parcellite history, since the Clipboard History demo shows it. `;;?` lists every trigger's description (no values); pick only `;;dot` or `;;date` from it.
