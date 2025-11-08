# VHS Tape for Neovim Workflow Demo
# Demonstrates typical nvim editing patterns

Output nvim-demo.gif

# YouTube-optimized dimensions (16:9 ratio)
Set Width 1200
Set Height 675

# Terminal appearance
Set FontSize 18
Set Theme "Catppuccin Mocha"
Set Padding 20
Set TypingSpeed 60ms
Set PlaybackSpeed 1.0

# Start with clear terminal
Hide
Type "clear"
Enter
Show

Sleep 500ms

# Create example file for demonstration
Type "# Creating example file for Neovim demo"
Enter
Sleep 500ms

Hide
Type "cat > example.go << 'EOF'"
Enter
Type "package main"
Enter
Enter
Type "import \"fmt\""
Enter
Enter
Type "func main() {"
Enter
Type "    name := \"VHS\""
Enter
Type "    fmt.Println(\"Hello from\", name)"
Enter
Type "}"
Enter
Type "EOF"
Enter
Show

Sleep 1s
Type "ls -l example.go"
Enter
Sleep 1.5s

# Open file in neovim
Type "nvim example.go"
Sleep 500ms
Enter
Sleep 2s

# Navigate in normal mode (j/k for down/up)
Type "j"
Sleep 300ms
Type "j"
Sleep 300ms
Type "j"
Sleep 300ms

Sleep 500ms

# Enter insert mode to add a comment
Type "O"
Sleep 300ms
Type "// This is a VHS demonstration"
Sleep 1s
Escape
Sleep 500ms

# Navigate to function name and change it
Type "/main"
Enter
Sleep 500ms
Type "w"
Sleep 300ms

# Change word (cw)
Type "cw"
Sleep 300ms
Type "demonstrate"
Escape
Sleep 1s

# Visual mode to select and yank
Type "gg"
Sleep 300ms
Type "V"
Sleep 300ms
Type "5j"
Sleep 500ms
Type "y"
Sleep 500ms

# Go to end and paste
Type "G"
Sleep 300ms
Type "o"
Enter
Type "// Copied content:"
Escape
Type "p"
Sleep 1.5s

# Save and quit
Type ":"
Sleep 300ms
Type "wq"
Sleep 500ms
Enter

Sleep 1.5s

# Show the result
Type "cat example.go"
Enter
Sleep 3s

# Clean up
Hide
Type "rm example.go"
Enter
Show

Sleep 1s

# Note: For best results:
# - Ensure nvim is configured with your preferred theme
# - Test the tape with your actual nvim setup
# - Adjust timing based on nvim startup time
# - Consider using Hide/Show for long operations
