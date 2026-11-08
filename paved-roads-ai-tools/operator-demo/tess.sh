#!/usr/bin/env bash
# One run of Tess, the operator, on one message: a digest from the processor or
# an instruction from the presenter. Her folder, prompt and model are her stable
# agent profile; the Intake she sees is the demo instance from env.sh.
set -eo pipefail
source "$(dirname "$(readlink -f "$0")")/env.sh"
msg=${1:?usage: tess.sh <message>}
home="$HOME/loft/tenant-operator"
# --home: the builder defaults to the cwd, which is wherever the processor started.
mapfile -t flags < <(python3 "$HOME/.claude/scripts/__role_home.py" tenant-operator --home "${home}")
export PATH="${DEMO_DIR}:${PATH}"
log="${DEMO_STATE}/tess.log"
# One run at a time: a second digest waits for the first to finish.
exec 9>"${DEMO_STATE}/tess.lock"
flock 9
{
	printf '\n=== %s\n%s\n---\n' "$(date +%T)" "${msg}"
	cd "${home}" && direnv exec . claude "${flags[@]}" \
		--system-prompt-file "$HOME/.claude/system-prompts/tenant-operator-system-prompt.md" \
		--model "$("$HOME/.claude/scripts/__models.sh" get tenant-operator)" \
		--allowedTools "Bash(intake:*)" "Bash(tk:*)" "Bash(cat:*)" "Bash(jq:*)" Read Write Edit \
		-p "${msg}"
} >>"${log}" 2>&1
