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
