vim.api.nvim_create_augroup("MyShellcheckGroup", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
	group = "MyShellcheckGroup",
	pattern = "*.sh",
	command = "!shellcheck %",
})
