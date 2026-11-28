# The demo shell: the presenter's own fzf setup and C alias, read from the
# dotfiles so they cannot drift, and nothing else, so the prompt shows no host,
# branch or cluster.
PROMPT='%F{cyan}%1~%f %F{yellow}›%f '

source <(fzf --zsh)
eval "$(grep -m1 '^export FZF_CTRL_T_COMMAND=' "${HOME}/dev/dotfiles/.zshrc")"
eval "$(grep -m1 '^alias -g C=' "${HOME}/dev/dotfiles/.zsh_aliases")"

# The slide's command, typed at the first prompt and waiting for the presenter.
if [[ -n ${DEMO_PRELOAD-} ]]; then
	print -z -- "${DEMO_PRELOAD}"
fi
unset DEMO_PRELOAD
