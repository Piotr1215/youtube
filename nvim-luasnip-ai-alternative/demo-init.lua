-- Loaded on top of your own Neovim config by setup-demo.sh (nvim -S), so the
-- demo shows your colors, which-key, and snippet keys. It adds only what this
-- video is about: the ast-grep language server against sgconfig.yml and the
-- Go snippets. demo.sh drives it over RPC through the Demo table below.
vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/lazy/nvim-lspconfig")

-- The live scans in the deck read example_bad.go, so a save during a demo
-- would change every later take. Writes to it are dropped.
vim.api.nvim_create_autocmd("BufWriteCmd", {
	pattern = "example_bad.go",
	callback = function()
		vim.bo.modified = false
		vim.notify("demo: example_bad.go stays unchanged")
	end,
})

-- -S runs after the file has loaded, past the FileType event that attaches a
-- server, so the buffer is read again once ast_grep is enabled.
vim.lsp.enable("ast_grep")
vim.cmd.edit()

local dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
dofile(dir .. "/luasnip-go-errors.lua")

-- Your snippet keys from config/luasnip.lua. mappings.lua loads later and maps
-- <A-l> in insert mode and <A-j> in visual mode, which shadows two of them, so
-- the demo sets all three again.
local ls = require("luasnip")
vim.keymap.set({ "i", "s" }, "<M-l>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end, { desc = "snippet: expand or jump" })
vim.keymap.set({ "i", "s" }, "<M-h>", function()
	if ls.jumpable(-1) then
		ls.jump(-1)
	end
end, { desc = "snippet: jump back" })
vim.keymap.set({ "i", "s" }, "<M-j>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end, { desc = "snippet: next choice" })

-- grug-far, cloned and pinned by setup-demo.sh, searches with ast-grep as you
-- type. Space s g sits next to your other search keys.
vim.opt.runtimepath:append((vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")) .. "/luasnip-demo/grug-far.nvim")
vim.keymap.set("n", "<leader>sg", function()
	require("grug-far").open({ engine = "astgrep", transient = true, prefills = { filesFilter = "*.go" } })
end, { desc = "Search with ast-grep (grug-far)" })

-- Your ]d and [d open the message with float = true, which Neovim 0.13
-- deprecates and warns about on screen at the first jump. Same jump, same
-- float, through on_jump; this autocmd runs after yours, so it wins.
local function open_float(_, bufnr)
	vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
end
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		for lhs, count in pairs({ ["]d"] = 1, ["[d"] = -1 }) do
			vim.keymap.set("n", lhs, function()
				vim.diagnostic.jump({ count = count * vim.v.count1, on_jump = open_float })
			end, { buffer = args.buf, desc = "Go to next diagnostic message" })
		end
	end,
})

Demo = {}

-- Number of ast-grep findings in the current buffer, so demo.sh can wait for
-- the language server before the first scene.
function Demo.findings()
	local n = 0
	for _, d in ipairs(vim.diagnostic.get(0)) do
		if d.source == "ast-grep" or (d.code and vim.tbl_contains(Demo.rules, d.code)) then
			n = n + 1
		end
	end
	return n
end

Demo.rules = {
	"bare-error-return",
	"direct-http-error-return",
	"fmt-errorf-without-wrap",
	"ignored-error",
	"panic-on-error",
}
