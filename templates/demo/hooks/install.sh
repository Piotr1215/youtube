#!/usr/bin/env bash
set -euo pipefail

if (( EUID == 0 )); then
  echo 'Do not run this installer as root.' >&2
  exit 1
fi
mode=install
dry_run=false
for arg in "$@"; do
  case "$arg" in
    --uninstall) mode=uninstall ;;
    --dry-run) dry_run=true ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done
hook_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
run_active="$hook_dir/run-active"
user=$(id -un)
uid=$(id -u)
unit_dir="$HOME/.config/systemd/user"
unit="$unit_dir/demo-resume.service"
sleep_target=/etc/systemd/system-sleep/demo-lifecycle
nm_target=/etc/NetworkManager/dispatcher.d/90-demo-lifecycle

# Render shell tokens separately from systemd unit arguments.
render() {
  python3 - "$1" "$user" "$HOME" "$uid" "$run_active" "$hook_dir/../README.md" <<'PY'
import pathlib
import shlex
import sys

source, user, home, uid, run_active, readme = sys.argv[1:]
text = pathlib.Path(source).read_text()
if source.endswith('.service'):
    def systemd_arg(value):
        return '"' + value.replace('\\', '\\\\').replace('"', '\\"').replace('%', '%%') + '"'
    values = {'@RUN_ACTIVE@': systemd_arg(run_active), '@README@': systemd_arg('file:' + str(pathlib.Path(readme).resolve()))}
else:
    values = {'@USER@': shlex.quote(user), '@HOME@': shlex.quote(home),
              '@UID@': shlex.quote(uid), '@RUN_ACTIVE@': shlex.quote(run_active)}
for key, value in values.items():
    text = text.replace(key, value)
sys.stdout.write(text)
PY
}
show_command() {
  printf ' '
  printf '%q ' "$@"
  printf '\n'
}
if [[ $mode == uninstall ]]; then
  echo 'Remove the installed hooks and user unit:'
  show_command sudo rm -f -- "$sleep_target" "$nm_target"
  show_command rm -f -- "$unit"
  show_command systemctl --user daemon-reload
  if ! $dry_run; then
    sudo rm -f -- "$sleep_target" "$nm_target"
    rm -f -- "$unit"
    systemctl --user daemon-reload
  fi
  exit 0
fi

echo 'Render the system sleep hook, network dispatcher, and user unit:'
if $dry_run; then
  for source in system-sleep nm-dispatcher demo-resume.service; do
    printf '\n--- %s ---\n' "$source"
    render "$hook_dir/$source"
  done
  echo 'Install the rendered files:'
  show_command sudo install -o root -g root -m 755 '<rendered system-sleep>' "$sleep_target"
  show_command sudo install -o root -g root -m 755 '<rendered nm-dispatcher>' "$nm_target"
  show_command mkdir -p -- "$unit_dir"
  show_command install -m 644 '<rendered demo-resume.service>' "$unit"
  show_command systemctl --user daemon-reload
  exit 0
fi
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
for source in system-sleep nm-dispatcher demo-resume.service; do
  render "$hook_dir/$source" > "$scratch/$source"
done
echo "Install $sleep_target"
sudo install -o root -g root -m 755 "$scratch/system-sleep" "$sleep_target"
echo "Install $nm_target"
sudo install -o root -g root -m 755 "$scratch/nm-dispatcher" "$nm_target"
echo "Install $unit"
mkdir -p -- "$unit_dir"
install -m 644 "$scratch/demo-resume.service" "$unit"
echo 'Reload user systemd units'
systemctl --user daemon-reload
