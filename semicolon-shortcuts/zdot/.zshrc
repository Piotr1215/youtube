# The presenter's regular shell, plus the slide's commands queued at the
# prompt. Outside tmux, TMUX is set but empty while the presenter's config
# loads, which keeps its tmuxinator autostart out of the demo.
ZDOTDIR="${HOME}"
if [[ -z ${TMUX+X} ]]; then
	TMUX=''
	[[ -f "${HOME}/.zshenv" ]] && source "${HOME}/.zshenv"
	source "${HOME}/.zshrc"
	unset TMUX
else
	[[ -f "${HOME}/.zshenv" ]] && source "${HOME}/.zshenv"
	source "${HOME}/.zshrc"
fi

# Ctrl+D ends the demo even with text left at the prompt.
demo-close() { exit 0; }
zle -N demo-close
bindkey -M emacs '^D' demo-close
bindkey -M viins '^D' demo-close
bindkey -M vicmd '^D' demo-close

# The slide's commands, one per prompt: the buffer stack hands out the last one
# pushed first, so they go on in reverse.
if [[ -n ${DEMO_PRELOAD-} ]]; then
	demo_lines=("${(@f)DEMO_PRELOAD}")
	for ((demo_i = ${#demo_lines}; demo_i > 0; demo_i--)); do
		print -z -- "${demo_lines[demo_i]}"
	done
	unset demo_lines demo_i
fi
unset DEMO_PRELOAD
