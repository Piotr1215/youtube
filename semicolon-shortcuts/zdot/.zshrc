# The demo shell: fzf's own key bindings and file walker, the presenter's C
# alias read from the dotfiles so it cannot drift, and nothing else, so the
# prompt shows no host, branch or cluster.
PROMPT='%F{cyan}%1~%f %F{yellow}›%f '

# Unset, not empty: an empty FZF_CTRL_T_COMMAND turns Ctrl-T off.
unset FZF_DEFAULT_COMMAND FZF_CTRL_T_COMMAND FZF_ALT_C_COMMAND
source <(fzf --zsh)
eval "$(grep -m1 '^alias -g C=' "${HOME}/dev/dotfiles/.zsh_aliases")"

# Ctrl+D closes the demo window even with text left at the prompt.
demo-close() { exit 0; }
zle -N demo-close
bindkey -M emacs '^D' demo-close
bindkey -M viins '^D' demo-close
bindkey -M vicmd '^D' demo-close

# The slide's command, typed at the first prompt and waiting for the presenter.
if [[ -n ${DEMO_PRELOAD-} ]]; then
	print -z -- "${DEMO_PRELOAD}"
fi
unset DEMO_PRELOAD
