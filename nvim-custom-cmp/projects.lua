local source = {}

local function fetch_project_names()
	local path = vim.fn.expand("~/projects.txt")
	local projects = {}
	for line in io.lines(path) do
		if line ~= "" then
			table.insert(projects, line)
		end
	end
	return projects
end

---Invoke completion (required).
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
	local project_names = fetch_project_names()
	local items = {}
	for _, name in ipairs(project_names) do
		table.insert(items, { label = name })
	end
	callback(items)
end

require("cmp").register_source("projects", source)
