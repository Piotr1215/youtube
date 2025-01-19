# Repo for my YouTube Channel

Long and short form content

Scripts and presentation for each `video` lives in its own directory and:
- can have optional runnable `demo.sh` script
- usually has `slides.md` to run terminal presentation.

The `demo.sh` script contains all the commands run in the video, which is easy
to execute in a local environment given that the prerequisites are met.

## Building on open source

The script runner `__demo_magic.sh` is inspired by the excellent idea from
[demo-magic](https://github.com/paxtonhare/demo-magic) repository which allows
for simulating commands typing and output in a terminal.

## Prerequisites

- [tmux](https://github.com/tmux/tmux)

- [pv](https://manned.org/pv)

