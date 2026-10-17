#!/usr/bin/env bash
# Migrates the log.Printf calls in a Go package to log/slog. ast-grep finds
# every call and builds every fix, classif decides which fix each call gets,
# and Go's own tools check the result.
#
#   ./migrate.sh [--diff | --apply] [DIR]
#
# The work happens on a copy of DIR (default: logs), in three steps:
#
#   1  syntax   ast-grep applies the fixes no model needs: a call logging err
#               moves to slog.Error
#   2  meaning  classif reads every other call and picks what it is for; the
#               rule for that answer applies its fix: debug output goes, an
#               event moves to slog.Info, and a sensitive or unsure line stays
#               for a person
#   3  verify   goimports, go build and go vet must pass on the copy
#
# Without a flag nothing outside the copy changes. --diff then prints the diff
# against DIR. --apply prints it and copies the files into DIR, only after
# step 3 passed.
set -euo pipefail

dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mode=check
if [[ ${1:-} == --diff || ${1:-} == --apply ]]; then
	mode="${1#--}"
	shift
fi
pkg="$(cd -- "${1:-${dir}/logs}" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
cp -r -- "${pkg}/." "${work}/"
PATH="${PATH}:$(go env GOPATH)/bin"

# Prints a step's number and what it does.
step() {
	printf '\n\e[1;33m%s  %s\e[0m\n' "$1" "$2"
}

# Runs ast-grep inside the copy, so its rows name files as DIR does, with the
# rules from this directory.
scan() {
	ast-grep scan --config "${dir}/sgconfig.yml" "$@" .
}

cd "${work}"
step 1 'syntax: ast-grep applies the fixes no model needs'
scan --filter '^log-error$' --json=stream | jq -r '
	"  \u001b[32m✓\u001b[0m \u001b[36m\(.file):\(.range.start.line + 1)\u001b[0m  \(.text)  \u001b[33msyntax\u001b[0m",
	"    \u001b[38;2;128;128;128mfix ›\u001b[0m \u001b[32m\(.replacement)\u001b[0m"'
scan --filter '^log-error$' -U >/dev/null

step 2 'meaning: classif picks what each other line is for'
scan --filter '^log-' --json=stream --include-metadata | "${dir}/triage.sh" --pick --apply

step 3 'verify: goimports, go build, go vet'
if ! { goimports -w . && go build -o /dev/null ./... && go vet ./...; }; then
	printf '  \e[31mverification failed; %s is unchanged\e[0m\n' "${pkg}" >&2
	exit 1
fi
printf '  \e[32m✓ builds and vets\e[0m\n'

[[ ${mode} == check ]] && exit 0
printf '\n'
for file in ./*.go; do
	file="${file#./}"
	diff -U1 --color=always --label "a/${pkg##*/}/${file}" --label "b/${pkg##*/}/${file}" -- "${pkg}/${file}" "${file}" || true
done
if [[ ${mode} == apply ]]; then
	cp -- ./*.go "${pkg}/"
	printf '\n  \e[32mwritten to %s\e[0m\n' "${pkg}"
fi
