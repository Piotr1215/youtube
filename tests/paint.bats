#!/usr/bin/env bats

setup() {
	source "${BATS_TEST_DIRNAME}/../__paint.sh"
}

@test "basic color uses the palette code" {
	run paint cyan 'find the spot'
	[ "$status" -eq 0 ]
	[ "$output" = $'\e[36mfind the spot\e[0m' ]
}

@test "text is printed verbatim" {
	run paint yellow '[ok] 100% \n [red] $HOME'
	[ "$output" = $'\e[33m[ok] 100% \\n [red] $HOME\e[0m' ]
}

@test "plain segments carry no codes" {
	run paint plain 'a ' - 'b'
	[ "$output" = 'a b' ]
}

@test "segments join on one line" {
	run paint cyan 'a' gray ' ──▶ ' 'bold yellow' 'b'
	[ "$output" = $'\e[36ma\e[0m\e[38;2;128;128;128m ──▶ \e[0m\e[1;33mb\e[0m' ]
}

@test "hex colors become RGB" {
	run paint '#ff8800' 'x'
	[ "$output" = $'\e[38;2;255;136;0mx\e[0m' ]
}

@test "on sets the background" {
	run paint 'white on red' 'x' 'on #000080' 'y'
	[ "$output" = $'\e[37;41mx\e[0m\e[48;2;0;0;128my\e[0m' ]
}

@test "no arguments prints a blank line" {
	run paint
	[ "$status" -eq 0 ]
	[ "$output" = '' ]
}

@test "odd argument count fails" {
	run paint cyan
	[ "$status" -eq 1 ]
	[[ "$output" == *'expected color/text pairs'* ]]
}

@test "unknown color fails" {
	run paint teal 'x'
	[ "$status" -eq 1 ]
	[[ "$output" == *'unknown color "teal"'* ]]
}

@test "caller IFS does not break multi-word colors" {
	IFS=$'\n\t'
	run paint 'bold yellow' 'x'
	[ "$output" = $'\e[1;33mx\e[0m' ]
}

@test "runs as a command" {
	run "${BATS_TEST_DIRNAME}/../__paint.sh" cyan 'x' plain ' [ok]'
	[ "$status" -eq 0 ]
	[ "$output" = $'\e[36mx\e[0m [ok]' ]
}

@test "command exits non-zero on bad input" {
	run "${BATS_TEST_DIRNAME}/../__paint.sh" teal 'x'
	[ "$status" -eq 1 ]
}
