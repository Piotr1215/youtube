# shellcheck shell=bash
# Sourced by the demo scripts. Pins the deck's own kubeconfig, so every step targets
# ai-dev whatever context the calling shell or tmux pane has, and defines the row
# helpers that print each step in plain words.

export KUBECONFIG="${VIND_KUBECONFIG:-${HOME}/.kube/vind-demo.config}"
CLUSTER="${CLUSTER:-ai-dev}"
GPU_VM="${GPU_VM:-vind-node}"
# shellcheck disable=SC2034 # used by join.sh
GCE=(--project="${PROJECT:-eng-sandbox-02}" --zone="${ZONE:-us-central1-a}")

# Print the command a step runs, the way the audience would type it.
# $1: command line
cmd() { paint gray '  $ ' 'bold white' "$1"; }

# Print one result row: a check mark, a padded label, and what it means.
# $1: label, $2: meaning
ok() { paint green '  ✓  ' cyan "$(printf '%-14s' "$1")" plain "$2"; }

# Print one failure row and the lines that explain it.
# $1: what failed, $2: detail
fail() { paint red '  ✗  ' plain "$1"; [[ -n "$2" ]] && paint gray "$2"; }

# Print a closing line under the rows.
# $1: text
note() { paint; paint yellow "$1"; }
