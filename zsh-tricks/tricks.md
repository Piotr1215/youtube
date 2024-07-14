| Keyboard Shortcut | Action                                                                                                    |
| ----------------- | --------------------------------------------------------------------------------------------------------- |
| Ctrl + U          | Remove from cursor to start of line                                                                       |
| Ctrl + Shift + \_ | Undo last keystroke in command                                                                            |
| Ctrl + K          | Cut from cursor to end of line                                                                            |
| Ctrl + W          | Cut from cursor to start of preceding word.<- LEFT                                                        |
| Ctrl + A          | Go to beginning of line                                                                                   |
| Ctrl + E          | Go to end of line                                                                                         |
| Ctrl + Y          | Copy command line content                                                                                 |
| Ctrl + q          | When a command is already typed, move it to buffer, clear command line and execute another one before     |
| Alt + D           | Remove from cursor to end of next word                                                                    |
| Ctrl + L          | Clear terminal                                                                                            |
| Ctrl + XE         | Edit current command in default editor                                                                    |
| Ctrl + XT         | Swap the current word with previous word                                                                  |
| Alt + .           | Repeat last argument of previous command, same as !$                                                      |
| !_:1 !_:2 ...     | Positional parameters from previous command                                                               |
| !#:1 !#:2 ...     | Positional parameters from current command                                                                |
| !#$               | Expand last argument of the current command                                                               |
| !!:s/x/y          | Substitute word(s) of previous command for example when spelled incorrectly                               |
| $#                | Number of positional parameters passed to the shell script or function                                    |
| $@                | All the positional parameters passed to the shell script or function, individually quoted                 |
| $\*               | All the positional parameters passed to the shell script or function, as a single, space-separated string |
| $_                | The last argument of the previous command                                                                 |
| $?                | Exit status of the last executed command                                                                  |
