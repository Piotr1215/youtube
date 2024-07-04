
![vim-intro](_media/vim-intro.png)

# Vim is a powerful, modal text editor. Let's explore its basics:

1. Modes: The core of Vim's efficiency
   - Normal (default): For navigating and commanding (you're in it now)
   - Insert (i): For typing text (press 'i' to enter, <ESC> to exit)
   - Visual (v): For selecting text (press 'v' to enter, <ESC> to exit)
   - Command (Ex) (:): For executing commands (type ':' in Normal mode)
   - Replace (R): Overwrites existing text (press 'R' to enter, <ESC> to exit)

# Understanding modes is crucial. Now, let's move around:

2. Moving: The h, j, k, l keys are your new arrow keys
   h (left), j (down), k (up), l (right)
   Practice moving around this text using h, j, k, l keys.

# Now that we can move, let's edit some text:

3. Inserting text: Adding content is easy
   i xxxx(before cursor), a (xxxxafter cursor), A (end of line)xxxx, I (start of
   line)
   Press 'i' here xxx_ to insert, 'a' here _ to append, 'A' to append at line end.

4. Deleting: Removing text is just as simple
   x (character), dw (word), dd (line)
   Use 'x' to delete this z, 'dw' to delete this word, 'dd' to delete this line.

# Vim's power comes from combining commands:

5. Motions with count: Efficiency in action
   - 2w: move forward two words
   - 3j: move down three lines
   - 5dw: delete five words
   Try these motions on this text to see how they work.

# Let's explore some more essential operations:

6. Copying and pasting: Vim calls this "yanking" and "putting"
   yy (copy line), p (paste)
   Use 'yy' to copy this line, then 'p' to paste it below.

7. Undo and Redo: Everyone makes mistakes
   u (undo), Ctrl-r (redo)
   Make a change, then press 'u' to undo it. Use Ctrl-r to redo.

8. Searching: Finding text quickly
   /pattern (forward), ?pattern (backward), n (next), N (previous)
   Type /Vim to search for "Vim", then 'n' to find the next occurrence.

9. Replacing: Changing text en masse
   :s/old/new/ (current line), :%s/old/new/g (entire file)
   Use :s/Vim/Editor/ to replace "Vim" with "Editor" on this line.

# Finally, how to save your work and exit:

10. Saving and quitting: Don't forget to save!
    :w (save), :q (quit), :wq (save and quit), :q! (quit without saving)

Remember, Vim's power comes from practice.
