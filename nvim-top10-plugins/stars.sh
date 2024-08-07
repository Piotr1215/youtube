#!/bin/bash

# Define categories and repositories
declare -A repos
repos=(
	["### Navigation"]="alexghergh/nvim-tmux-navigation"
	["### File Handling"]="echasnovski/mini.files mhinz/vim-startify ixru/nvim-markdown"
	["### Editing Enhancements"]="preservim/nerdcommenter kylechui/nvim-surround"
	["### UI/UX Improvements"]="robitx/gp.nvim shortcuts/no-neck-pain.nvim folke/todo-comments.nvim folke/tokyonight.nvim"
	["### Markdown and Documentation"]="jubnzv/mdeval.nvim iamcco/markdown-preview.nvim epwalsh/obsidian.nvim"
	["### Search and Navigation"]="xiyaowong/telescope-emoji.nvim"
	["### Quickfix Enhancements"]="yssl/QFEnter kevinhwang91/nvim-bqf"
	["### Utility"]="RRethy/nvim-align 3rd/image.nvim"
)

# Function to get the number of stars for a repository
get_stars() {
	repo=$1
	stars=$(gh repo view "$repo" --json stargazerCount -q '.stargazerCount')
	echo "$repo: $stars stars"
}

# Iterate through the categories and repositories
for category in "${!repos[@]}"; do
	echo "$category"
	for repo in ${repos[$category]}; do
		get_stars "$repo"
	done
	echo ""
done
