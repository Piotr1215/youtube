-- LuaSnip snippets for Python and Bash error handling
-- Each one writes the shape the matching ast-grep rule asks for.

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

-- Ahead of any other snippet with the same trigger; key makes a reload
-- replace these instead of adding them twice.
local opts = { key = "python-bash-errors", override_priority = 2000 }

ls.add_snippets("python", {
	-- Catch a named exception and chain it: raise-without-from
	s(
		"tryr",
		fmt(
			[[
try:
    {}
except {} as err:
    raise {}("{}") from err]],
			{
				i(1, "pass"),
				i(2, "OSError"),
				c(3, { t("RuntimeError"), t("ValueError") }),
				i(4, "context"),
			}
		)
	),
}, opts)

ls.add_snippets("sh", {
	-- Strict mode header: missing-strict-mode
	s(
		"strict",
		fmt(
			[[
#!/usr/bin/env bash
set -euo pipefail
{}]],
			{ i(1) }
		)
	),

	-- curl that fails on HTTP errors: curl-without-fail
	s(
		"curlf",
		fmt([[curl --fail --silent --show-error --location {}{}]], {
			i(1, '"$url"'),
			c(2, { t(' -o "$out"'), t(" -O"), t("") }),
		})
	),
}, opts)
