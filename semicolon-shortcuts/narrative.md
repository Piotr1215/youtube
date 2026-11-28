# Narrative

A teammate asks how the terminal pastes text and where to find the fuzzy finder. The answer is a short note with the Alacritty config path, the `Shift+Insert` binding, and the fzf project link. The same note runs through the video. Each demo leaves something visible in it.

The story starts with a familiar act, copying something already on screen. It moves to finding a missing value, then getting it directly into the draft. Each step gets one explanation and leaves the next problem visible.

## Screen and voice

The screen shows what to look at while the narration explains why it matters. Start on the draft with two empty fields. Hold on the real command output, the chosen path at the cursor, and the completed draft when each appears. Use a title and diagram for each sequence. Give each new milestone a short gain and remaining limit when that limit motivates the next slide.

## Narration

### The note by hand

1. I can select a URL in the browser or a line of command output and copy it with the mouse. That gets a visible value into the teammate's note.
2. For command output, a shell suffix skips the mouse. If another copy replaces the file path, clipboard history brings it back.
3. The clipboard can only give me values I have already copied. A fuzzy finder can find an unseen path, and its shell binding drops that path into the command I'm typing. The draft still has no shell binding.

### The missing piece

4. The useful part of the finder is picking from a list while I'm in the middle of something. On X11, it can start from the keys typed in the focused app, show choices in a desktop menu, and deliver the picked value back to that app.
5. AutoKey recognises the trigger and calls a script with a list name. The script reads a file or runs a program, sends labels to rofi, and uses the selected row to get the original value. It waits for the original window before clearing the trigger and pasting the value.
6. A phrase can insert fixed text on its own. A picker needs a list, and the list can be a small file I maintain or a program that gets the current values. A picker with one result can paste it immediately.

### The same note, assembled in place

7. I can pick the same configuration inside the command and then inside an editor or chat draft. Both get the value from the same list, so I don't have to carry it between apps. The project link still needs its own list.
8. I can keep a list of useful project links and give it a word. When the link appears in the same note, the only new pieces are the values and a binding to the picker I already have.
9. The whole system is a way to bring a value to the cursor. A first useful list is whatever I copied several times this week.

## Demo beats and what stays on screen

Keep the draft open with `Paste key: Shift+Insert`, `Config file: …`, and `fzf docs: …`. Run the terminal demos in presenterm's terminal. Each slide hands off to the next problem.

### Demo 1. Find the setting and build the note by hand

- Select and copy the fzf URL in the browser. In the terminal, run `rg -nw Paste .config/alacritty`, then select and copy its output the same way. Put the values in the draft.
- Show `realpath .config/alacritty/alacritty.toml C` once. The absolute path reaches the clipboard without a mouse selection.
- Copy the public fzf URL from the browser as the second value. Back in the draft, recover the earlier path from history. Open the menu only after both public values have replaced the initial contents.
- Run `fzf` once to find a path that is missing from the screen. Start `rg -w Paste `, then use Ctrl-T and `alactoml` to put the result into the command. Return to the draft and point out its remaining gap. The same key there cannot open the shell's file picker.

- ✓ A command, the clipboard and a finder can get the values into the note.
- ✗ The shell picker ends at the prompt. In the draft, the values still come from another app.

### Design and code before the shortcut demo

Show the full sequence with `just plantuml use-shortcut`. The first and last messages go through the same app. Bash reads a value set and sends labels to rofi, which returns the selected row.

Keep source to the interfaces the viewer needs. Show the AutoKey abbreviation and the `subprocess.Popen` line that passes the set name and trigger length. Show one real `VALUE<TAB>label` row and the `rofi -dmenu` call. Explain the focus check, trigger erasure and clipboard restore while pointing at the return path.

A fixed phrase with public sample text, a plain URL list, and the executable dotfiles list show the types without opening the personal shortcut inventory.

### Demo 2. Fill the same field from where the cursor is

- Start `rg -w Paste ` in the same terminal. Type `;;dot` and Space, search `alacritty.toml`, and select the same configuration file from Demo 1. Hold on the completed command before running it so the insertion is visible.
- Switch to the working draft, leave the cursor after `Config file:`, and pick that file again. Show the same path appearing in the draft without a trip to the terminal to copy it. Leave the `fzf docs:` field empty in this copy of the note.

- ✓ The same picker fills in the command and the draft on X11.
- ✗ The project link needs a list of its own.

### Demo 3. Add the list, then finish the note

- Use `just plantuml build-shortcut` to show how the list, AutoKey entry and existing picker fit together before registering the binding.
- Show the checked-in `lists/docs` row for fzf. Show how `;;docs` points the picker at that list, then register the demo binding from the same terminal. The list and binding are the visible inputs. The registration helper is just what applies them on the recording machine.
- Pick the link at the `curl -sI ` prompt. Then return to the pending `fzf docs:` field in the same draft and use the same `;;docs` trigger there. Hold on the completed note. It contains the same values as the manual version.

- ✓ A file of links and a trigger are enough to pick a new value in place.
- ▶ The first list to make is one for a value that keeps sending you to another app.

## Recording state

- The reference note and working draft contain only the public file path, shortcut and URL. Use draft text throughout.
- Clipboard history uses the demo profile with two public entries and a two-entry limit. The live history can pick up whatever the monitored X11 selection already holds at startup. Start the demo profile before seeding both entries and never open the menu before they are present.
- `;;dot` uses the regular public dotfiles example. The rofi query is `alacritty.toml`; `alactoml` is for fzf. A live `;;?` menu would reveal the personal shortcut inventory.
- Register `;;docs` through the demo helper. Its live-step cleanup removes the demo's list and binding. Reset restores the presenter's clipboard manager if the demo profile was used.
