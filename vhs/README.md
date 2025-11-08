# VHS Terminal Recorder

This directory contains VHS tape files for creating terminal GIFs and videos for YouTube content.

## What is VHS?

VHS is a tool for generating terminal GIFs and videos. It allows you to write scripted terminal sessions as code, making demos reproducible and easy to update.

## Installation

Install VHS using Go:

```bash
go install github.com/charmbracelet/vhs@latest
```

### Dependencies

VHS requires `ffmpeg` and `ttyd` for recording:

```bash
# On Ubuntu/Debian
sudo apt install ffmpeg

# ttyd (for terminal recording)
# Download from: https://github.com/tsl0922/ttyd/releases
```

Alternatively, install all dependencies via package managers:

```bash
# macOS
brew install vhs

# This installs VHS and all dependencies
```

## Usage

### Using Just Recipes

Record a tape file using the justfile:

```bash
# Record a specific tape file
just record kubectl-demo

# Record the demo.sh from a video folder
just record-demo kubectl-basics
```

### Direct VHS Commands

```bash
# Record a tape file
vhs < demo-template.tape

# Or specify the tape file directly
vhs kubectl-demo.tape

# Record and output to a specific file
vhs nvim-demo.tape -o output.gif
```

## Template Files

### demo-template.tape
Basic template for general terminal demos. Use this as a starting point for custom recordings.

**Use cases:**
- Simple command-line demonstrations
- Quick terminal tips
- General shell workflows

### kubectl-demo.tape
Kubernetes-focused demo showing kubectl commands in action.

**Use cases:**
- Kubernetes tutorials
- kubectl command demonstrations
- Container orchestration workflows

**Prerequisites:**
- Running Kubernetes cluster (minikube, kind, or remote)
- kubectl configured and connected

### nvim-demo.tape
Neovim workflow demonstration showing editing patterns.

**Use cases:**
- Neovim tutorials
- Editor workflow demonstrations
- Plugin showcases

**Prerequisites:**
- Neovim installed and configured
- Your preferred theme and plugins set up

## Best Practices for YouTube Content

### 1. Dimensions
- Use 1200x675 (16:9 ratio) for YouTube
- Scales well in HD (1080p) and 4K content
- Maintains readability on mobile devices

### 2. Font Size
- Minimum 16pt, recommended 18-20pt
- Test visibility on smaller screens
- Consider viewer's display settings

### 3. Timing
- `TypingSpeed`: 40-60ms (natural but not too slow)
- `Sleep`: 1-2s after command execution
- `Sleep`: 2-3s for complex output
- Give viewers time to read output

### 4. Output Formats
- **GIF**: Great for GitHub, docs, small demos
  - Limited to 256 colors
  - Larger file sizes for long recordings
  - Max ~30 seconds recommended

- **MP4**: Better for YouTube integration
  - Superior compression
  - No color limitations
  - Can be longer (1-2 minutes)

```tape
# For MP4 output
Output demo.mp4
```

- **WebM**: Alternative video format
  - Good compression
  - Web-optimized

```tape
# For WebM output
Output demo.webm
```

### 5. Theme Selection
Choose high-contrast themes for readability:
- Catppuccin Mocha (default in templates)
- Dracula
- Nord
- Tokyo Night
- Gruvbox Dark

```tape
Set Theme "Dracula"
```

### 6. Recording Tips

**Do:**
- Clear the screen before starting (`clear`)
- Add context with comments (`# This demonstrates...`)
- Use realistic examples
- Show both success and error handling
- Include cleanup steps
- Test tapes multiple times

**Don't:**
- Rush through commands (adjust TypingSpeed)
- Show sensitive information (API keys, passwords)
- Make recordings too long (break into segments)
- Forget to cleanup resources
- Assume instant command execution

### 7. File Organization
```
video-folder/
├── demo.sh           # Traditional tmux demo
├── vhs/
│   ├── part1.tape   # Segmented VHS recordings
│   ├── part2.tape
│   └── full.tape    # Complete demo
└── presentation.md
```

### 8. Combining with Existing Workflows

VHS complements the existing demo.sh approach:

- **demo.sh**: Live demonstrations, interactive presentations
- **VHS tapes**: Polished recordings, consistent output, easy editing

Use both:
1. Create demo.sh for live presentation
2. Create VHS tape for YouTube thumbnail/preview
3. Record both for different audience needs

## Customization

### Variables in Templates

Common settings to adjust:

```tape
# Dimensions (16:9 recommended)
Set Width 1200
Set Height 675

# Font
Set FontSize 18
Set FontFamily "JetBrains Mono"

# Speed
Set TypingSpeed 50ms      # How fast to type
Set PlaybackSpeed 1.0     # Speed multiplier

# Appearance
Set Theme "Catppuccin Mocha"
Set Padding 20
Set Framerate 60
Set CursorBlink true
```

### Advanced Features

```tape
# Hide typing indicator for fast operations
Hide
Type "some fast command"
Show

# Simulate user corrections
Type "kubeclt"
Sleep 500ms
Backspace 3
Type "ctl"

# Ctrl+C to interrupt
Type "long-running-command"
Sleep 1s
Ctrl+C

# Environment variables
Env KUBECONFIG /path/to/config
```

## Troubleshooting

### Slow Startup
If nvim or other tools start slowly, use `Hide`:
```tape
Hide
Type "nvim file.txt"
Enter
Sleep 3s  # Wait for startup
Show
```

### Commands Not Found
Ensure commands are in PATH:
```tape
Env PATH /usr/local/bin:/usr/bin:/bin
```

### Font Issues
Specify full font path if needed:
```tape
Set FontFamily "/usr/share/fonts/truetype/jetbrains/JetBrainsMono-Regular.ttf"
```

## Resources

- [VHS Documentation](https://github.com/charmbracelet/vhs)
- [VHS Examples](https://github.com/charmbracelet/vhs/tree/main/examples)
- [Charm Terminal Tools](https://charm.sh)
- [YouTube Video Specs](https://support.google.com/youtube/answer/6375112)

## Integration with Workflow

After recording with VHS:

1. Review the output GIF/video
2. If satisfied, include in video project folder
3. Reference in presentation slides or use as B-roll
4. Upload to YouTube as demo material
5. Keep tape files for easy updates

## Examples from This Repository

See the demo.sh files for inspiration:
- `/home/user/youtube/kubectl-basics/demo.sh` - kubectl workflows
- `/home/user/youtube/nvim-luasnip-ai-alternative/demo.sh` - nvim demonstrations
- `/home/user/youtube/docker-basics/demo.sh` - Docker command examples

Convert these to VHS tapes for reproducible recordings.
