local M = {}

function M.fetch_project_names()
	local path = vim.fn.expand("~/projects.txt")
	local projects = {}
	for line in io.lines(path) do
		if line ~= "" then
			table.insert(projects, line)
		end
	end
	return projects
end

return M
