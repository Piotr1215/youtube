-- AI-generated LuaSnip snippets for Go error handling
-- Add this to your Neovim config

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

-- Helper function to get package name
local function get_package_name()
  local file_path = vim.fn.expand("%:p:h")
  local package = file_path:match("([^/]+)$")
  return package or "pkg"
end

-- Snippets for Go
ls.add_snippets("go", {
  -- Smart error wrapping with context
  s("iferr", fmt([[
if {} != nil {{
	return {}.Wrap({}, "{}")
}}]], {
    i(1, "err"),
    f(function() return get_package_name() end),
    ls.restoreNode(1),
    i(2, "failed to process"),
  })),

  -- Error check with custom message
  s("iferrm", fmt([[
if {} != nil {{
	return {}.Wrapf({}, "{}: %w", {})
}}]], {
    i(1, "err"),
    f(function() return get_package_name() end),
    ls.restoreNode(1),
    i(2, "operation failed"),
    ls.restoreNode(1),
  })),

  -- HTTP error handling
  s("ifhttp", fmt([[
resp, err := http.{}({})
if err != nil {{
	return {}.Wrap(err, "HTTP {} failed")
}}
defer resp.Body.Close()

if resp.StatusCode != http.Status{} {{
	body, _ := io.ReadAll(resp.Body)
	return {}.Errorf("unexpected status %d: %s", resp.StatusCode, body)
}}]], {
    c(1, {t("Get"), t("Post"), t("Put"), t("Delete")}),
    i(2, "url"),
    f(function() return get_package_name() end),
    ls.restoreNode(1),
    c(3, {t("OK"), t("Created"), t("NoContent")}),
    f(function() return get_package_name() end),
  })),

  -- Database error handling
  s("ifdberr", fmt([[
if err != nil {{
	if errors.Is(err, sql.ErrNoRows) {{
		return {}.Wrap(err, "{} not found")
	}}
	return {}.Wrap(err, "database operation failed")
}}]], {
    f(function() return get_package_name() end),
    i(1, "entity"),
    f(function() return get_package_name() end),
  })),

  -- Defer with error handling
  s("deferr", fmt([[
defer func() {{
	if err := {}.Close(); err != nil {{
		log.Printf("failed to close {}: %v", err)
	}}
}}()]], {
    i(1, "resource"),
    i(2, "resource"),
  })),

  -- Error type definition
  s("errtype", fmt([[
// {}Error represents {}
type {}Error struct {{
	{}
}}

func (e {}Error) Error() string {{
	return fmt.Sprintf("{}: %s", {})
}}

func (e {}Error) Unwrap() error {{
	return e.Err
}}]], {
    i(1, "Domain"),
    i(2, "domain-specific error"),
    ls.restoreNode(1),
    i(3, "Err error\n\tContext string"),
    ls.restoreNode(1),
    i(4, "error in domain"),
    i(5, "e.Context"),
    ls.restoreNode(1),
  })),
})