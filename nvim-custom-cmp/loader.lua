local M = {}
local step_index = 1

M.files = {
	"./step1.lua",
	"./step3.lua",
}

function M.load_next_file()
	if step_index <= #M.files then
		local file_path = vim.fn.expand(M.files[step_index])
		local lines = {}

		-- Open and read the file
		local file = io.open(file_path, "r")
		if file then
			for line in file:lines() do
				table.insert(lines, line)
			end
			file:close()
		else
			print("Error: Could not open file " .. file_path)
			return
		end

		-- Append the lines to the current buffer
		vim.api.nvim_buf_set_lines(0, -1, -1, false, lines)

		-- Move to the next step
		step_index = step_index + 1
	else
		print("No more files to load.")
	end
end

-- Bind the function to a key
vim.api.nvim_set_keymap(
	"n",
	"<leader>nf",
	[[<Cmd>lua require('loader').load_next_file()<CR>]],
	{ noremap = true, silent = true }
)

return M
