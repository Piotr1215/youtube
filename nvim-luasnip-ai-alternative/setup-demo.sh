#!/usr/bin/env bash
# Opens a fresh tmux session running your Neovim on example_bad.go, with
# demo-init.lua on top, listening on a socket so demo.sh can tell when the
# ast-grep findings are in. Recreated on every run, so each take starts from
# the file as committed.
set -euo pipefail

session="luasnip-demo"
dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# One demo nvim per tmux server, so two servers never drive each other's.
server="$(tmux display-message -p '#{pid}')"
sock="${XDG_RUNTIME_DIR:-/tmp}/luasnip-demo-${server}.sock"

# grug-far runs ast-grep from a search buffer. Your config does not carry it,
# so the demo clones it here, pinned, and every take looks the same.
plugins="${XDG_DATA_HOME:-${HOME}/.local/share}/luasnip-demo"
fetch_plugin() {
	local repo="$1" commit="$2" dest="${plugins}/${1#*/}"
	[[ -d ${dest} ]] && return 0
	git clone --quiet --filter=blob:none "https://github.com/${repo}" "${dest}"
	git -C "${dest}" checkout --quiet "${commit}"
}
fetch_plugin MagicDuck/grug-far.nvim bbde8ef5ae46ceee2c3bd8b21fc048c5f8ffbfc0

tmux kill-session -t "=${session}" 2>/dev/null || true
rm -f "${sock}"
# -i NONE keeps the demo's searches and registers out of your shada. Copilot
# stays off: the video is about what works without a cloud model.
tmux new-session -d -s "${session}" -c "${dir}" \
	"nvim --cmd 'set noswapfile' --cmd 'let g:copilot_enabled = v:false' -i NONE --listen '${sock}' -S demo-init.lua example_bad.go"

for _ in $(seq 50); do
	[[ -S ${sock} ]] && break
	sleep 0.1
done
[[ -S ${sock} ]] || {
	printf 'The demo nvim did not open %s\n' "${sock}" >&2
	exit 1
}

printf 'Session %s ready: tmux switchc -t %s\n' "${session}" "${session}"
