#!/usr/bin/env bash
# Opens a fresh tmux session running the demo nvim, listening on a socket so
# demo.sh can load exercises and drive the keystroke golf ledger over RPC.
# Recreated on every run so each take starts from the same state.
set -euo pipefail

session="multicursor-demo"
dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# One demo nvim per tmux server, so two servers never drive each other's.
server="$(tmux display-message -p '#{pid}')"
sock="${XDG_RUNTIME_DIR:-/tmp}/multicursor-demo-${server}.sock"
work="${XDG_RUNTIME_DIR:-/tmp}/multicursor-demo-${server}"

if ! nvim --clean --headless -c 'lua io.stdout:write(vim.api.nvim_mcursor and "yes" or "no")' -c 'qa!' 2>/dev/null | grep -q yes; then
	printf 'nvim on PATH has no multicursor: install a nightly build (0.13-dev)\n' >&2
	exit 1
fi

# tiny-cmdline moves the command line mid-screen, where viewers can read each
# Ex command as it is typed. The fork keeps 'cmdheight' as set. Pinned, so
# every take looks the same.
plugins="${XDG_DATA_HOME:-${HOME}/.local/share}/multicursor-demo"
fetch_plugin() {
	local repo="$1" commit="$2" dest="${plugins}/${1#*/}"
	[[ -d ${dest} ]] && return 0
	git clone --quiet --filter=blob:none "https://github.com/${repo}" "${dest}"
	git -C "${dest}" checkout --quiet "${commit}"
}
fetch_plugin Piotr1215/tiny-cmdline.nvim 7df1387d7db8dd8556b1f3992d20e65ba1f79823

tmux kill-session -t "=${session}" 2>/dev/null || true
rm -rf "${sock}" "${work}"
mkdir -p "${work}"
tmux new-session -d -s "${session}" -c "${dir}" \
	"nvim --clean -u '${dir}/demo-init.lua' --listen '${sock}'"

for _ in $(seq 50); do
	[[ -S ${sock} ]] && break
	sleep 0.1
done
[[ -S ${sock} ]] || {
	printf 'The demo nvim did not open %s\n' "${sock}" >&2
	exit 1
}

printf 'Session %s ready: tmux switchc -t %s\n' "${session}" "${session}"
