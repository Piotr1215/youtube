-- Loaded on top of your own Neovim config by setup-demo.sh (nvim -S), so the
-- demo shows your colors and which-key. It adds only what this video is about:
-- the ast-grep language server against sgconfig.yml, grug-far, and :Classif.
-- demo.sh drives it over RPC through the Demo table below.
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

-- Your colorschemes.lua dims the background on FocusLost. The caption card
-- holds focus while it waits for Space, so the demo drops that dimming.
for _, au in ipairs(vim.api.nvim_get_autocmds({ event = "FocusLost" })) do
	if type(au.callback) == "function" then
		local source = debug.getinfo(au.callback, "S").source
		if source:find("colorschemes.lua", 1, true) then
			vim.api.nvim_del_autocmd(au.id)
		end
	end
end

-- -S runs after the file has loaded, past the FileType event that attaches a
-- server, so the buffer is read again once ast_grep is enabled. nvim-lspconfig
-- lists bash but not sh, the filetype Neovim gives a .sh file.
vim.lsp.config("ast_grep", {
	filetypes = vim.list_extend(vim.deepcopy(vim.lsp.config.ast_grep.filetypes), { "sh" }),
})
vim.lsp.enable("ast_grep")
vim.cmd.edit()

local dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")

-- grug-far, cloned and pinned by setup-demo.sh, searches with ast-grep as you
-- type. Space s g sits next to your other search keys.
vim.opt.runtimepath:append((vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")) .. "/ast-grep-demo/grug-far.nvim")
vim.keymap.set("n", "<leader>sg", function()
	require("grug-far").open({ engine = "astgrep", transient = true, prefills = { filesFilter = "*.go" } })
end, { desc = "Search with ast-grep (grug-far)" })

-- Your ]d and [d open the message with float = true, which Neovim 0.13
-- deprecates and warns about on screen at the first jump. Same jump, same
-- float, through on_jump; this autocmd runs after yours, so it wins. Both skip
-- hints: a hint is a candidate waiting for :Classif, not a finding.
local findings = { min = vim.diagnostic.severity.INFO }
local function open_float(_, bufnr)
	vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false, severity = findings })
end
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		for lhs, count in pairs({ ["]d"] = 1, ["[d"] = -1 }) do
			vim.keymap.set("n", lhs, function()
				vim.diagnostic.jump({ count = count * vim.v.count1, severity = findings, on_jump = open_float })
			end, { buffer = args.buf, desc = "Go to next diagnostic message" })
		end
	end,
})

-- vague-error-message reports every error message as a hint: whether one
-- names the failed operation is a judgment, not syntax. :Classif scans the
-- buffer, opens a panel with each rule's question and the calls it matched,
-- and pipes the matches through triage.sh, which asks classif about each one.
-- A message the model confirms becomes a warning, one it clears gets a ✓, and
-- the panel shows every verdict next to its call. The rule's fix stays on gra,
-- and a second :Classif judges the fixed text. The buffer goes through a temp
-- copy because saves to example_bad.go are dropped.
local classif_ns = vim.api.nvim_create_namespace("classif")
local cleared_ns = vim.api.nvim_create_namespace("classif-cleared")
local match_ns = vim.api.nvim_create_namespace("classif-match")
local panel_ns = vim.api.nvim_create_namespace("classif-panel")
local panel = {}
Demo = {}
-- Counts finished :Classif runs. demo.sh reads it before typing :Classif and
-- waits for it to grow; a flag could still hold the previous run's true.
Demo.classified = 0

-- Closes the panel and the highlights it put on the matched calls.
local function close_panel()
	if panel.win and vim.api.nvim_win_is_valid(panel.win) then
		vim.api.nvim_win_close(panel.win, true)
	end
	if panel.code then
		vim.api.nvim_buf_clear_namespace(panel.code, match_ns, 0, -1)
	end
	panel = {}
end

-- Draws the panel over the top of the window: for each rule, its name and
-- question, then each matched call with classif's verdict, or "asking" while
-- the model has not answered. The calls are highlighted in the code too.
local function draw_panel(bufnr, rows)
	local lines, marks, width = {}, {}, 0
	for _, r in ipairs(rows) do
		width = math.max(width, vim.fn.strdisplaywidth(r.text))
	end
	local function add(text, hls)
		table.insert(lines, text)
		for _, hl in ipairs(hls or {}) do
			table.insert(marks, { #lines - 1, hl[1], hl[2], hl[3] })
		end
	end
	local rule
	for _, r in ipairs(rows) do
		if r.rule ~= rule then
			rule = r.rule
			if #lines > 0 then
				add("")
			end
			add(" rule   " .. r.rule, { { 1, 5, "Comment" }, { 8, 8 + #r.rule, "Identifier" } })
			add(" asks   " .. r.ask, { { 1, 5, "Comment" }, { 8, 8 + #r.ask, "Title" } })
			add("")
		end
		local mark, verdict, hl = "…", "asking the model", "Comment"
		if r.label then
			mark = r.kept and "✗" or "✓"
			hl = r.kept and "DiagnosticWarn" or "DiagnosticOk"
			verdict = string.format("%-3s %s  %s", r.label, r.p, r.kept and "warning" or "cleared")
		end
		local head = string.format(" %s %3d  ", mark, r.line + 1)
		local text = r.text .. string.rep(" ", width - vim.fn.strdisplaywidth(r.text)) .. "   "
		add(head .. text .. verdict, { { 1, 1 + #mark, hl }, { #head + #text, #head + #text + #verdict, hl } })
		vim.api.nvim_buf_set_extmark(bufnr, match_ns, r.line, r.col, {
			id = r.id,
			end_row = r.end_line,
			end_col = r.end_col,
			hl_group = r.label and (r.kept and "DiffDelete" or "DiffAdd") or "Visual",
		})
	end
	if not (panel.buf and vim.api.nvim_buf_is_valid(panel.buf)) then
		panel.buf = vim.api.nvim_create_buf(false, true)
	end
	vim.api.nvim_buf_set_lines(panel.buf, 0, -1, false, lines)
	vim.api.nvim_buf_clear_namespace(panel.buf, panel_ns, 0, -1)
	for _, m in ipairs(marks) do
		vim.api.nvim_buf_set_extmark(panel.buf, panel_ns, m[1], m[2], { end_col = m[3], hl_group = m[4] })
	end
	local config = {
		relative = "editor",
		row = 1,
		col = 2,
		width = math.min(vim.o.columns - 6, math.max(unpack(vim.tbl_map(vim.fn.strdisplaywidth, lines))) + 1),
		height = #lines,
		style = "minimal",
		border = "rounded",
		title = " classif ",
		focusable = false,
	}
	if panel.win and vim.api.nvim_win_is_valid(panel.win) then
		vim.api.nvim_win_set_config(panel.win, config)
	else
		panel.win = vim.api.nvim_open_win(panel.buf, false, config)
		vim.wo[panel.win].wrap = false
	end
	panel.code = bufnr
	-- Keep the cursor line out from under the panel.
	if vim.fn.winline() <= #lines + 2 then
		vim.cmd("normal! zz")
	end
end

vim.api.nvim_create_user_command("Classif", function()
	local bufnr = vim.api.nvim_get_current_buf()
	close_panel()
	vim.diagnostic.reset(classif_ns, bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, cleared_ns, 0, -1)
	local copy = vim.fn.tempname() .. "." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":e")
	vim.fn.writefile(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), copy)
	local scan = vim.system({ "ast-grep", "scan", "--json=stream", "--include-metadata", copy }, { cwd = dir, text = true }):wait()
	vim.fn.delete(copy)
	local rows = {}
	for line in vim.gsplit(scan.stdout or "", "\n", { trimempty = true }) do
		local f = vim.json.decode(line)
		if type(f.metadata) == "table" and f.metadata.ask then
			table.insert(rows, {
				id = #rows + 1,
				rule = f.ruleId,
				ask = f.metadata.ask,
				text = f.text,
				line = f.range.start.line,
				col = f.range.start.column,
				end_line = f.range["end"].line,
				end_col = f.range["end"].column,
			})
		end
	end
	if #rows == 0 then
		vim.notify("classif: no rule here asks a question")
		Demo.classified = Demo.classified + 1
		return
	end
	draw_panel(bufnr, rows)
	vim.system(
		{ dir .. "/triage.sh", "--json" },
		{ cwd = dir, text = true, stdin = scan.stdout },
		vim.schedule_wrap(function(out)
			local diags = {}
			for line in vim.gsplit(out.stdout or "", "\n", { trimempty = true }) do
				local v = vim.json.decode(line)
				for _, r in ipairs(rows) do
					if r.line == v.line and r.col == v.col then
						r.label, r.p, r.kept = v.label, v.p, v.kept
					end
				end
				local verdict = string.format("classif: %s %s", v.label, v.p)
				if v.kept then
					table.insert(diags, {
						lnum = v.line,
						col = v.col,
						end_lnum = v.end_line,
						end_col = v.end_col,
						severity = vim.diagnostic.severity.WARN,
						source = "classif",
						message = string.format("%s (%s)", v.message, verdict),
					})
				else
					vim.api.nvim_buf_set_extmark(bufnr, cleared_ns, v.line, 0, {
						virt_text = { { "✓ " .. verdict, "DiagnosticOk" } },
					})
				end
			end
			vim.diagnostic.set(classif_ns, bufnr, diags)
			draw_panel(bufnr, rows)
			-- The panel stays until the cursor moves.
			local at = vim.api.nvim_win_get_cursor(0)
			vim.api.nvim_create_autocmd("CursorMoved", {
				buffer = bufnr,
				callback = function()
					if vim.deep_equal(vim.api.nvim_win_get_cursor(0), at) then
						return
					end
					close_panel()
					return true
				end,
			})
			Demo.classified = Demo.classified + 1
		end)
	)
end, { desc = "Ask classif about ast-grep findings whose rule carries a question" })

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
	"vague-error-message",
}
