#!/usr/bin/env bash
# Opens a fresh tmux session running your Neovim on logs/main.go, with
# demo-init.lua on top, listening on a socket so demo.sh can tell when the
# ast-grep findings are in. Recreated on every run, so each take starts from
# the file as committed.
#
#   ./setup-demo.sh [SOCKET]
#
# Each run listens on a socket of its own. An nvim unlinks its socket path as
# it exits, so with a shared path the nvim being replaced deleted the socket of
# the one replacing it, and demo.sh waited on a socket that was gone.
set -euo pipefail

session="ast-grep-demo"
dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
sock="${1:-${XDG_RUNTIME_DIR:-/tmp}/ast-grep-demo-$$.sock}"

# grug-far runs ast-grep from a search buffer. Your config does not carry it,
# so the demo clones it here, pinned, and every take looks the same.
plugins="${XDG_DATA_HOME:-${HOME}/.local/share}/ast-grep-demo"
fetch_plugin() {
	local repo="$1" commit="$2" dest="${plugins}/${1#*/}"
	[[ -d ${dest} ]] && return 0
	git clone --quiet --filter=blob:none "https://github.com/${repo}" "${dest}"
	git -C "${dest}" checkout --quiet "${commit}"
}
fetch_plugin MagicDuck/grug-far.nvim bbde8ef5ae46ceee2c3bd8b21fc048c5f8ffbfc0

# demo-init.lua drops saves from Neovim, but a grug-far replace has ast-grep
# rewrite the file on disk, and the live scans on later slides read it.
if ! git -C "${dir}" diff --quiet HEAD -- example_bad.go; then
	printf 'example_bad.go differs from git; restore it with: git checkout example_bad.go\n' >&2
	exit 1
fi

tmux kill-session -t "=${session}" 2>/dev/null || true
# -i NONE keeps the demo's searches and registers out of your shada. Copilot
# stays off: the video is about what works without a cloud model. -S takes
# the full path, since your config moves into logs/, the file's Go module.
tmux new-session -d -s "${session}" -c "${dir}" \
	"nvim --cmd 'set noswapfile' --cmd 'let g:copilot_enabled = v:false' -i NONE --listen '${sock}' -S '${dir}/demo-init.lua' logs/main.go"

for _ in $(seq 50); do
	[[ -S ${sock} ]] && break
	sleep 0.1
done
[[ -S ${sock} ]] || {
	printf 'The demo nvim did not open %s\n' "${sock}" >&2
	exit 1
}

printf 'Session %s ready: tmux switchc -t %s\n' "${session}" "${session}"
