# Narrative

A teammate asks how the terminal pastes text and where to find the fuzzy finder. The answer is a short note with the Alacritty config path, the `Shift+Insert` binding, and the fzf project link. The same note runs through the video. Each demo leaves something visible in it.

The idea is a searchable list that inserts a value wherever the cursor already is on X11. The examples are a file path and a URL. The setup is worth learning because opening the source app, copying, and returning gets old even when every individual step is easy.

## Narration

### The note by hand

1. A teammate wants to reproduce the terminal's paste shortcut. I can show the setting and send the link for the finder, but the information lives in different places and the note is where it all needs to land.
2. The mouse can copy a path I can see. A shell alias copies the same command output from the keyboard, and clipboard history lets me pick it again after I've copied another value. Those tools help once the value has already reached the screen or the clipboard.
3. A fuzzy finder gets me to a file I only half remember. Its shell shortcut can put the result straight into the command I'm typing. It can get me to the configuration, but the project link lives in the browser, and the shell shortcut can't help in the note.

### The missing piece

4. The useful part of the finder is picking from a list while I'm in the middle of something. On X11, it can start from the keys typed in the focused app, show choices in a desktop menu, and deliver the picked value back to that app.
5. AutoKey recognises the trigger and calls a script with a list name. The script reads a file or runs a program, sends labels to rofi, and uses the selected row to get the original value. It waits for the original window before clearing the trigger and pasting the value.
6. A phrase can insert fixed text on its own. A picker needs a list, and the list can be a small file I maintain or a program that gets the current values. A picker with one result can paste it immediately.

### The same note, assembled in place

7. I can pick the same configuration inside the command and then inside an editor or chat draft. Both get the value from the same list, so I don't have to carry it between apps. The project link still needs its own list.
8. I can keep a list of useful project links and give it a word. When the link appears in the same note, the only new pieces are the values and a binding to the picker I already have.
9. The whole system is a way to bring a value to the cursor. A first useful list is whatever I copied several times this week.

## Demo beats and what stays on screen

Keep the draft open throughout. It starts as `Paste key: …`, `Config file: …`, `fzf docs: …`. Use the regular zsh in the dotfiles checkout. Run each terminal block as a continuous session in presenterm's terminal. Switch to the existing browser or draft only when the action calls for it.

### Demo 1. Find the setting and build the note by hand

- Start with a job the viewer recognises. Find evidence for the paste setting with `rg -nH -F 'action = "Paste"' "$PWD/.config/alacritty/alacritty.toml"`. Select and copy the file path, then paste it into the draft. The config line shows `Insert` with the `Shift` modifier.
- Back in the same terminal, run `realpath .config/alacritty/alacritty.toml C`. The same path appears on screen and goes to the clipboard. Copy `Shift+Insert` as the next value in the note, then recover the file path from clipboard history. Open the history menu after the two public copies have replaced its initial contents.
- Start `bat `, use Ctrl-T and search `alactoml`. The path fills in at the prompt and `bat` shows the config. For the fzf explanation, show how a matching file path comes out as a line. Keep the terminal interaction on the actual config lookup.
- Need the fzf link. Switch to the project's page, copy its URL manually, and paste it in the draft. The viewer sees the complete note and the switches it took to fill it. Keep it as the reference for the next two blocks.

- ✓ A command, the clipboard and a finder can get the values into the note.
- ✗ The shell shortcut ends at the prompt, and the browser still holds the link.

### Design and code before the shortcut demo

Show the full sequence with `just plantuml use-shortcut`. The first and last messages go through the same app. Bash reads a value set and sends labels to rofi, which returns the selected row.

Keep source to the interfaces the viewer needs. Show the AutoKey abbreviation and the `subprocess.Popen` line that passes the set name and trigger length. Show one real `VALUE<TAB>label` row and the `rofi -dmenu` call. Explain the focus check, trigger erasure and clipboard restore while pointing at the return path.

A fixed phrase with public sample text, a plain URL list, and the executable dotfiles list show the types without opening the personal shortcut inventory.

### Demo 2. Fill the same field from where the cursor is

- Start `bat ` in the same terminal. Type `;;dot` and Space, search `alacritty.toml`, and select the same configuration file from Demo 1. Hold on the completed command before running it so the insertion is visible.
- Switch to the working draft, leave the cursor after `Config file:`, and pick that file again. Show the same path appearing in the draft without a trip to the terminal to copy it. Leave the `fzf docs:` field empty in this copy of the note.

- ✓ The same picker fills in the command and the draft on X11.
- ✗ The project link needs a list of its own.

### Demo 3. Add the list, then finish the note

- Use `just plantuml build-shortcut` to show how the list, AutoKey entry and existing picker fit together before registering the binding.
- Show the checked-in `lists/docs` row for fzf. Show how `;;docs` points the picker at that list, then register the demo binding from the same terminal. The list and binding are the visible inputs. The registration helper is just what applies them on the recording machine.
- Return to the pending `fzf docs:` field in the same draft. Type `;;docs` and Space, filter to `fzf`, and select the link. Hold on the completed note. It contains the same values as the manual version.

- ✓ A file of links and a trigger are enough to pick a new value in place.
- ▶ The first list to make is one for a value that keeps sending you to another app.

## Recording state

- The reference note and working draft contain only the public file path, shortcut and URL. Use draft text throughout.
- Clipboard history uses the demo profile with two public entries and a two-entry limit. The live history can pick up whatever the monitored X11 selection already holds at startup. Start the demo profile before seeding both entries and never open the menu before they are present.
- `;;dot` uses the regular public dotfiles example. The rofi query is `alacritty.toml`; `alactoml` is for fzf. A live `;;?` menu would reveal the personal shortcut inventory.
- Register `;;docs` through the demo helper. Its live-step cleanup removes the demo's list and binding. Reset restores the presenter's clipboard manager if the demo profile was used.
