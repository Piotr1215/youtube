-- Loaded on top of your own Neovim config (nvim -S demo-init.lua FILE), so the
-- demo shows your colors and keys. It adds only what this video is about: the
-- ast-grep language server, reading the rules through sgconfig.yml.
vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/lazy/nvim-lspconfig")

-- The deck's live commands read logs/main.go, so a save during a demo would
-- change every later take. Writes to it are dropped.
vim.api.nvim_create_autocmd("BufWriteCmd", {
	pattern = { "*/logs/main.go" },
	callback = function()
		vim.bo.modified = false
		vim.notify("demo: saves are dropped, the file stays as committed")
	end,
})

-- The log-debug, log-info and log-sensitive rules match every line that logs
-- a value, as hints: candidates for a question, not findings. Only findings
-- are drawn.
local findings = { min = vim.diagnostic.severity.INFO }
vim.diagnostic.config({
	underline = { severity = findings },
	virtual_text = { severity = findings },
	signs = { severity = findings },
})

-- -S runs after the file has loaded, past the FileType event that attaches a
-- server, so the buffer is read again once ast_grep is enabled.
vim.lsp.enable("ast_grep")
vim.cmd.edit()
