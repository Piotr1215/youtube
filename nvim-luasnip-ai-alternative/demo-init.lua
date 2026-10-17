-- Config for the demo nvim: stock Neovim plus the two tools this video is
-- about, so viewers see only what the slides explain. ast-grep runs as a
-- language server against sgconfig.yml, and LuaSnip loads the Go snippets.
-- Plugins come from the lazy.nvim install; nothing is downloaded here.
vim.o.number = true
vim.o.swapfile = false
vim.o.signcolumn = "yes"
vim.o.shortmess = vim.o.shortmess .. "I"

local lazy = vim.fn.stdpath("data") .. "/lazy"
vim.opt.runtimepath:prepend(lazy .. "/nvim-lspconfig")
vim.opt.runtimepath:prepend(lazy .. "/LuaSnip")

-- The live scans in the deck read example_bad.go, so a save during a demo
-- would change every later take. Writes to it are dropped.
vim.api.nvim_create_autocmd("BufWriteCmd", {
	pattern = "example_bad.go",
	callback = function()
		vim.bo.modified = false
		vim.notify("demo: example_bad.go stays unchanged")
	end,
})

-- Rule messages show at the end of the line they flag; gra opens the fixes.
vim.diagnostic.config({ virtual_text = true })
vim.lsp.enable("ast_grep")

local ls = require("luasnip")
dofile(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h") .. "/luasnip-go-errors.lua")

-- Tab expands a snippet or jumps to its next field, Shift-Tab jumps back,
-- and Ctrl-J cycles a choice node.
vim.keymap.set({ "i", "s" }, "<Tab>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	else
		vim.api.nvim_feedkeys(vim.keycode("<Tab>"), "n", false)
	end
end)
vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
	ls.jump(-1)
end)
vim.keymap.set({ "i", "s" }, "<C-j>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end)
