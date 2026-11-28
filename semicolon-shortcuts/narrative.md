# Narrative

The story of the video, written before any slide. Each numbered beat is one moment of the story: what the presenter says, in two or three sentences. The story decides how many slides a beat needs. Each part becomes a chapter. The slides are the presenter's props: a real file, real command output, a diagram or the chapter map, never what the presenter says aloud. A beat marked live has no slide of its own; the presenter shows it on the desktop. When the slides and this file disagree, this file wins.

The video follows one convenience for terminal power users: getting a value to where we type. It climbs from the mouse, through clipboard tools and fuzzy finders, to the point where they stop helping, and ends with a fuzzy menu that works in every window.

Every step has the same shape: the slide names what the step gives us, the presenter shows it at once, and the step ends on its limit, which the next slide answers. The limit is a red ✗ line under the demo, so the climb is visible on screen.

## Flow

Slide and demo, slide and demo, in one window. Each demo slide shows the command about to run in a code block marked `+exec +acquire_terminal`. Ctrl+E hands the window to a real zsh in the dotfiles repo with that command already typed at the prompt, up to the first `;;`, so the presenter's own keys start where the trigger does. The presenter finishes it live (Enter, the mouse, Ctrl-T, a `;;` word) and Ctrl+D returns to the same slide. Steps in the browser, a chat app or an email are shown by switching to that window and back.

A replayed tmux demo session, as in tmux-regex-copy, cannot work here: it types with `tmux send-keys`, which writes straight to the pane, while AutoKey watches the keyboard on the X server and never sees those keys, so no `;;` trigger would fire.

## Journey

- Problem the viewer knows: moving a value from where it is to where we are typing (a file path, a URL, an id) still sends us to the mouse or to another window.
- Why the usual ways fall short: mouse selection is slow and fiddly; a clipboard manager and a copy alias need the value printed or copied first; fzf finds it, and its Ctrl-T even drops a file path at the cursor, but only for files and only inside the shell; in the middle of a long command, or in Slack or an email, we still leave what we are doing to go and fetch the value.
- What the viewer needs to understand: a desktop-wide trigger can open the same kind of fuzzy menu they know from fzf, in any window; each trigger word points at a list; a list is a file, or a program that prints the values right now; the choice is pasted where the cursor is.
- How each step leads to the next: the mouse breaks the flow, so copy from the keyboard; copying needs the value on screen, so find it with fzf; fzf finds files inside the shell, but values live in other apps and we type in other apps, so the menu has to work everywhere; a menu that works everywhere needs a way to add lists, so a list is a plain file.
- So what: any value we need lands at the cursor, in any window, without leaving the keyboard or the half-typed command.
- Now what: it is the fzf idea the viewer already uses, stretched over the whole desktop with AutoKey, rofi and a small bash script.
- Then what: make a list for the value you copied by hand most this week, and give it a trigger word.
- What the viewer can do at the end: copy from the terminal without the mouse, pick values with fzf, and set up `;;` triggers that open their own lists in any window.

## Subject and example

- Subject: getting the value you need to the cursor, in any window, without breaking your flow.
- Example: a file path inserted in the middle of a shell command, then values dropped into Slack and an email, with the presenter's `;;` shortcuts.

## Narration

### Copy and paste

1. As terminal power users we live on the keyboard. Yet one of the most common moves of the day, getting a value from where it is to where we are typing, still sends us to the mouse: a file path, a URL, an id.

2. With no tools at all, the path is on screen and we reach for the mouse, drag across it, hope the selection stops at the right character, copy, click back and paste. It works, and it breaks the flow every single time. Live.

3. Here is where we end up. In the middle of a command, two semicolons and a word open a menu, and the chosen path lands at the cursor. Live.

4. The first improvement keeps the hands on the keyboard. A clipboard manager remembers everything we copied, so something from ten minutes ago is one pick away. In zsh, a global alias, a single capital C at the end of a command, sends its output to the clipboard while still showing it.

5. Both need the value printed or copied first. Often we do not have it yet; we only know roughly what it is.

### Fuzzy finding

6. fzf turns any list into a fuzzy menu. List every file, type a few letters, pick one, and send the path to the clipboard. Live.

7. The shell goes one step further: fzf's Ctrl-T opens the same menu while we type a command and drops the chosen path at the cursor. For files, inside the shell, that is the right answer, and every other list would need its own shell widget.

### Breaking the flow

8. Now the value is not a file in this folder: a URL from the browser, a cloud account id, a ticket, a note somewhere else. We are halfway through a command that needs the address of a project page, so we leave the command, open the browser, find the page, copy the URL, come back and hope the half-typed line is still there. Live.

9. Outside the terminal it gets worse. In Slack or an email there is no shell, no fzf and no Ctrl-T, so every value goes through copy and paste by hand. Live.

10. What we want is the fuzzy menu we already like, available in every window, fed by any list we choose, dropping the choice right where the cursor is.

### Semicolon shortcuts

11. In the middle of a command, two semicolons, a word and a space open a menu of paths; we pick one and it lands at the cursor, and the command is still there. The same in Slack and in an email. Live.

12. Each word is its own list: notes in the vault, cloud account ids, open tasks, the agents running in tmux. A word can also hold fixed text, like an email address, and type it with no menu at all.

13. Nobody remembers every word. Two semicolons and a question mark list every trigger with what it does, and run the one we pick.

### Shortcut internals

14. AutoKey watches the keys on the whole desktop. When it sees two semicolons, a word and a space, it runs a small bash script for that word; the script reads the word's list, shows it in rofi, which is fzf for the desktop, and pastes the choice where the cursor was.

15. A list is a plain file, one value per line, with an optional label to search by. When the values change, the list is a small program instead, and the menu shows what it prints right now.

16. Registering a new list takes two steps: write the list, then point a trigger word at it. Live: a list of project pages gets the word docs, and the command from the detour takes the URL in two keys. There is nothing to build or restart for a new value: the script reads the list fresh every time.

17. Two details make it work in every app. The trigger fires only on the space after the word, so a short word never swallows a longer one. The value is pasted, not typed, so Slack does not open its command menu on a leading slash and a newline never presses Enter.

### Getting started

18. On Linux you need AutoKey and rofi; the script and the example lists are in the presenter's public dotfiles. Start with the one list you reach for every day.

19. Any value you need lands at the cursor in any window, without leaving the keyboard. It is the fzf idea you already know, spread over the whole desktop, so make a list for the value you copied by hand most this week.

## Before the slides

- AutoKey and X11: the setup runs on X11; check AutoKey's Wayland support before the Install slide says anything about it.
- Nothing private on screen: no email, home address, account ids, environment values or real note and task titles. Demos use lists pointed at a demo folder, a demo vault and demo ids.
- Ctrl-T: verified in `~/.zshrc` (`source <(fzf --zsh)`, `FZF_CTRL_T_COMMAND='fd --hidden'`).
- The C alias: verified in `.zsh_aliases` line 14, `tee` to the screen and to `xsel --clipboard`, with colour codes stripped.
- Clipboard manager: parcellite runs here; the slide names the kind of tool, not the product.

## Slides

Each line: the slide, the question the viewer has when it appears, and the limit it ends on (✗), which the next slide answers. Demo marks a code block run with Ctrl+E; app marks a switch to another window.

### Opening

- Semicolon Shortcuts: title.

### Copy and paste

- Copy and Paste: divider, "How do we get a value to where we type?"
- Copying with the Mouse: what does it look like with no tools? Demo `fd alacritty`, then select and paste with the mouse. ✗ The hand leaves the keyboard every time.
- First Look: what does the fix look like? Demo `nvim ;;dot`.
- Copying from the Keyboard: can we skip the mouse? The real C alias line, then demo `fd alacritty C`. ✗ The value has to be on screen first.

### Fuzzy finding

- Fuzzy Finding: divider, "What if the value is not on screen yet?"
- Any List as a Menu: how do we find a path we only half remember? Demo `fd --type f | fzf | xsel --clipboard`. ✗ Found, copied, then pasted by hand.
- A Path at the Cursor: does the shell do this already? Demo `bindkey '^T'`, then Ctrl-T mid-command. ✗ Only files below this folder, and only in the shell.

### Breaking the flow

- Breaking the Flow: divider, "What happens when the value lives somewhere else?"
- The Mid-Command Detour: what does fetching a URL cost? Loop diagram, then demo `curl -sI` with the detour to the browser. ✗ Every value is a trip away from the command.
- Outside the Terminal: what about Slack and email? Rows: no shell, no fzf, no Ctrl-T; app. ✗ Every value goes through copy and paste by hand.

### Semicolon shortcuts

- Semicolon Shortcuts: divider, "What if the fuzzy menu worked in every window?"
- A Menu in Every Window: does it really work everywhere? Demo `bat ;;dot`, then app: `;;dot` and `;;date` in a chat and an email.
- A Word for Every List: what can a word hold? `+exec_replace` of the trigger list.
- Every Trigger in One Menu: what if I forget a word? Demo `;;?`.

### Shortcut internals

- Shortcut Internals: divider, "What runs between the keys and the menu?"
- From Keys to Value: how does it work? Diagram: keys, AutoKey, the bash script, the list, rofi, paste at the cursor.
- A List Is a File: where do the values come from? The demo list of project pages as a file snippet.
- A List Can Be a Program: what if the values change? The dotfiles list program as a file snippet, its output from `+exec`.
- A Word Points at a List: how does a word find its list? The real trigger entry and the line it runs.
- A New List, Live: how long does a new one take? Demo `curl -sI ;;docs | head -1`, after the slide registers `;;docs`.
- Pasted, Not Typed: why does it behave in Slack? Rows: a typed slash, a typed newline, a paste.

### Getting started

- Getting Started: divider, "What do I need to try it?"
- Install: AutoKey, rofi, the dotfiles link.
- Takeaways: so what, now what, then what.
- Resources.
- That's All Folks.

## Demo state

- `;;docs` is the only change the demo makes to the desktop. `demo.toml` declares it as a live step, so `just reset` removes it and the deck is ready to record again.
- The demo shell is zsh with the presenter's own fzf setup and C alias and nothing else, so the prompt shows no host, branch or cluster.
