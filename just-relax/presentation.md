---
title: Terminal Media Workflow
author: Cloud Native Corner
date: 2025-08-17
---

# Just Relax 🎵

> Managing and consuming media entirely in the terminal

```bash +exec_replace
echo "Just Relax" | figlet -f slant -w 90
```

<!-- end_slide -->

## Why Terminal for Media?

```bash
┌────────────────────────────────────────────────────┐
│                  TERMINAL MEDIA                    │
│                                                    │
│  ✓ No ads, no recommendations, no distractions     │
│  ✓ Minimal RAM usage (cmus: ~15MB vs Spotify: 1GB) │
│  ✓ Keyboard shortcuts for everything               │
│  ✓ Scriptable and automatable                      │
│  ✓ Works over SSH                                  │
│  ✓ Your data stays local                           │
└────────────────────────────────────────────────────┘
                        vs
┌────────────────────────────────────────────────────┐
│                   BROWSER/GUI                      │
│                                                    │
│  ✗ Ads and tracking                                │
│  ✗ Heavy resource usage                            │
│  ✗ Mouse-dependent navigation                      │
│  ✗ Hard to automate                                │
│  ✗ Requires full desktop environment               │
└────────────────────────────────────────────────────┘
```

<!-- end_slide -->

## The Terminal Media Room Concept

```bash
╔═══════════════════════════════════════════════════════╗
║              YOUR TERMINAL MEDIA ROOM                 ║
╠═══════════════════════════════════════════════════════╣
║                                                       ║
║  One tmux session = Your entire media setup           ║
║                                                       ║
║  ┌─────────────────────────────────────────────┐      ║
║  │ Status Bar: 🎵 Now Playing: Dark Ambient... │      ║
║  └─────────────────────────────────────────────┘      ║
║                                                       ║
║  • All media in one place                             ║
║  • Switch with Ctrl-b + window number                 ║
║  • Detach and reattach anytime (tmux detach/attach)   ║
║  • Works over SSH                                     ║
║  • Persists across disconnections                     ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
```

<!-- end_slide -->

## Core Tools & Commands

| Tool           | Key Commands                        |
|------          |--------------                       |
| **tmux**       | `C-b w` window list, `C-b d` detach |
| **tmuxinator** | `tmuxinator start relax`            |
| **mpv**        | `mpv --no-video URL`                |
| **cmus**       | `:add ~/music`, `c` pause/play      |
| **cava**       | Just runs, reads audio              |
| **ytx**        | Browse with arrows, Enter to play   |
| **fzf**        | Type to filter, Enter to select     |

<!-- end_slide -->

## Session Management: tmux + tmuxinator

> **tmuxinator**: github.com/tmuxinator/tmuxinator
> YAML-based session management - define once, launch anytime:

```bash
# Install
gem install tmuxinator

# Start your media room
tmuxinator start relax

# Common tmux commands
C-b w         # List windows
C-b 1/2       # Switch windows
C-b d         # Detach session
tmux attach   # Reattach later
```

<!-- end_slide -->

## Media Players

> **cmus**: github.com/cmus/cmus - Vi-like music player  
> **mpv**: github.com/mpv-player/mpv - Universal media player  
> **cava**: github.com/karlstav/cava - Audio visualizer

```bash
# cmus commands
:add ~/music     # Add music library
c                # Play/pause
/                # Search tracks

# mpv for YouTube/streams
mpv --no-video "youtube.com/watch?v=..."

# cava - just run it, reads system audio
cava
```

<!-- end_slide -->

## Custom Scripts & Integration

```bash +exec
# ytx - browse YouTube
yt-x --help
```

<!-- end_slide -->

## Custom Script for MPV

```bash +exec
# Playlist manager
__play_track.sh --help
```

<!-- end_slide -->

## Tmux integration

```bash
tmux set -g status-right "#(__tmux_playing_track.sh)"
```

<!-- end_slide -->

## Demo Time! 🚀

```bash +exec_replace
just intro And Now Let\'s Relax
```

<!-- end_slide -->

## That's All Folks! 🎬

```bash +exec_replace
echo "That's All Folks" | figlet -f small -w 90
```
