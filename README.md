# Repo for recording shorts on terminal

Each `short` lives in its own directory and has a runnable `demo.sh` script.

The `demo.sh` script contains all the commands run in the short, which is easy
to execute in a local environment.

## Building on open source

The script runner `__demo_magic.sh` is inspired by the excellent idea from
[demo-magic](https://github.com/paxtonhare/demo-magic) repository which allows
for simulating commands typing and output in a terminal.

## Prerequisites

- `tmux`

```bash
tmux
Terminal multiplexer.It allows multiple sessions with windows, panes, and more.See also: zellij, screen.More information: https://github.com/tmux/tmux.

 - Start a new session:
   tmux

 - Start a new named session:
   tmux new -s {{name}}

 - List existing sessions:
   tmux ls

 - Attach to the most recently used session:
   tmux attach

 - Detach from the current session (inside a tmux session):
   <Ctrl>-B d

 - Create a new window (inside a tmux session):
   <Ctrl>-B c

 - Switch between sessions and windows (inside a tmux session):
   <Ctrl>-B w

 - Kill a session by name:
   tmux kill-session -t {{name}}

```

- `pv`
```bash
pv
Monitor the progress of data through a pipe.More information: https://manned.org/pv.

 - Print the contents of the file and display a progress bar:
   pv {{path/to/file}}

 - Measure the speed and amount of data flow between pipes (--size is optional):
   command1 | pv --size {{expected_amount_of_data_for_eta}} | command2

 - Filter a file, see both progress and amount of output data:
   pv -cN in {{big_text_file}} | grep {{pattern}} | pv -cN out > {{filtered_file}}

 - Attach to an already running process and see its file reading progress:
   pv -d {{PID}}

 - Read an erroneous file, skip errors as dd conv=sync,noerror would:
   pv -EE {{path/to/faulty_media}} > image.img

 - Stop reading after reading specified amount of data, rate limit to 1K/s:
   pv -L 1K --stop-at --size {{maximum_file_size_to_be_read}}
```

