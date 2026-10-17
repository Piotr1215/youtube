-- LuaSnip snippets for Go error handling
-- Add this to your Neovim config

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

-- Snippets for Go
ls.add_snippets("go", {
	-- Smart error wrapping with context
	s(
		"iferr",
		fmt(
			[[
if {} != nil {{
	return {}fmt.Errorf("{}: %w", {})
}}]],
			{
				i(1, "err"),
				c(2, { t("nil, "), t("") }),
				i(3, "failed to process"),
				rep(1),
			}
		)
	),

	-- Error check with custom message
	s(
		"iferrm",
		fmt(
			[[
if {} != nil {{
	return {}fmt.Errorf("{} %s: %w", {}, {})
}}]],
			{
				i(1, "err"),
				c(2, { t("nil, "), t("") }),
				i(3, "operation failed for"),
				i(4, "id"),
				rep(1),
			}
		)
	),

	-- HTTP error handling
	s(
		"ifhttp",
		fmt(
			[[
resp, err := http.{}({})
if err != nil {{
	return nil, fmt.Errorf("HTTP {} %s: %w", {}, err)
}}
defer resp.Body.Close()

if resp.StatusCode != http.Status{} {{
	body, _ := io.ReadAll(resp.Body)
	return nil, fmt.Errorf("unexpected status %d: %s", resp.StatusCode, body)
}}]],
			{
				c(1, { t("Get"), t("Head") }),
				i(2, "url"),
				rep(1),
				rep(2),
				c(3, { t("OK"), t("Created"), t("NoContent") }),
			}
		)
	),

	-- Database error handling
	s(
		"ifdberr",
		fmt(
			[[
if err != nil {{
	if errors.Is(err, sql.ErrNoRows) {{
		return fmt.Errorf("{} not found: %w", err)
	}}
	return fmt.Errorf("database operation failed: %w", err)
}}]],
			{
				i(1, "entity"),
			}
		)
	),

	-- Defer with error handling
	s(
		"deferr",
		fmt(
			[[
defer func() {{
	if err := {}.Close(); err != nil {{
		log.Printf("failed to close {}: %v", err)
	}}
}}()]],
			{
				i(1, "resource"),
				rep(1),
			}
		)
	),

	-- Error type definition
	s(
		"errtype",
		fmt(
			[[
// {}Error represents {}
type {}Error struct {{
	Err     error
	Context string
}}

func (e {}Error) Error() string {{
	return fmt.Sprintf("{}: %s: %v", e.Context, e.Err)
}}

func (e {}Error) Unwrap() error {{
	return e.Err
}}]],
			{
				i(1, "Domain"),
				i(2, "domain-specific error"),
				rep(1),
				rep(1),
				i(3, "error in domain"),
				rep(1),
			}
		)
	),
})
