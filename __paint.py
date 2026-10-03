#!/usr/bin/env python3
"""Color slide text with readable markup instead of ANSI escape codes.

Reads stdin and prints it with colors for presenterm +exec_replace blocks.
Markup is rich's: [cyan]text, [bold yellow]text, [#ff8800]text, [grey50]text,
[color(208)]text, [white on red]text. A later tag overrides an earlier one,
every line starts uncolored, and \\[ prints a literal bracket.

presenterm only parses the eight basic colors and RGB reliably: it ignores the
bright codes (90-97) and the 256-color grey ramp. Every other color is
therefore sent as RGB, so names like bright_black and grey50 still show.
"""

import sys

from rich.color import Color, ColorType
from rich.console import Console
from rich.style import Style
from rich.text import Span, Text

console = Console(
	force_terminal=True,
	color_system="truecolor",
	width=10_000,
	emoji=False,
	highlight=False,
)


# Keep the eight basic colors, so they follow the terminal palette like
# \e[36m does; convert every other color to an RGB triplet.
def presenterm_color(color):
	if color is None or color.type in (ColorType.DEFAULT, ColorType.TRUECOLOR):
		return color
	if color.type is ColorType.STANDARD and color.number < 8:
		return color
	return Color.from_triplet(color.get_truecolor())


# Parse one line of markup and rewrite its colors for presenterm.
def paint(line):
	text = Text.from_markup(line)
	spans = []
	for span in text.spans:
		style = console.get_style(span.style)
		fixed = style + Style(
			color=presenterm_color(style.color),
			bgcolor=presenterm_color(style.bgcolor),
		)
		spans.append(Span(span.start, span.end, fixed))
	text.spans = spans
	return text


for line in sys.stdin.read().splitlines():
	console.print(paint(line), soft_wrap=True)
