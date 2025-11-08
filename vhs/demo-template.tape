# VHS Demo Template
# Use this as a starting point for recording terminal demos

# Output settings - Creates an optimized GIF for YouTube
Output demo.gif

# Set up terminal dimensions (YouTube friendly 16:9 ratio)
Set Width 1200
Set Height 675

# Terminal settings
Set FontSize 18
Set Theme "Catppuccin Mocha"
Set Padding 20

# Typing speed (milliseconds per character)
Set TypingSpeed 50ms

# Playback speed - how long to pause between commands
Set PlaybackSpeed 1.0

# Hide the typing indicator once the command has been typed
Hide
Type "clear"
Enter
Show

# Wait before starting the demo
Sleep 500ms

# Demo Introduction
Type "# Welcome to the demo!"
Sleep 1s
Enter
Sleep 500ms

# Example command with typed effect
Type "echo 'Hello from VHS'"
Sleep 500ms
Enter
Sleep 1s

# Example with directory navigation
Type "ls -la"
Sleep 500ms
Enter
Sleep 2s

# Show file content
Type "cat README.md"
Sleep 500ms
Enter
Sleep 2s

# Final pause before ending
Sleep 2s

# Tips:
# - Use Sleep to add pauses (e.g., Sleep 500ms, Sleep 2s)
# - Use Enter to execute commands
# - Use Ctrl+C to simulate interrupting
# - Use Backspace to simulate corrections
# - Use Hide/Show to skip parts without recording
