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

-- Some rules match calls that only meaning can tell apart, so their fix is
-- right for some and wrong for others. :Classif scans the buffer and pipes
-- the matches through triage.sh, which asks classif about each call. Plain
-- :Classif is a gate: each rule's yes/no question, where the answer named by
-- fix_on lands the rule's fix, clear_on leaves the call as is, and anything
-- else keeps it as a warning. :Classif pick has classif pick one fix among
-- the rules that match the same call, each offering one option. Two lines
-- above each call show the question and the answer; the quickfix list at the
-- bottom repeats them, then ast-grep's other findings. u shows the code before
-- the fix. The buffer goes through a temp copy because saves to
-- example_bad.go are dropped.
local classif_ns = vim.api.nvim_create_namespace("classif")
local verdict_ns = vim.api.nvim_create_namespace("classif-verdict")
Demo = {}
-- Counts finished :Classif runs, so a headless check can wait for one.
Demo.classified = 0

-- Turns a byte offset into the copy, which holds the buffer's lines each
-- ended by a newline, into a 0-based row and byte column.
local function position(lines, offset)
	local row = 0
	while row < #lines - 1 and offset > #lines[row + 1] do
		offset = offset - #lines[row + 1] - 1
		row = row + 1
	end
	return row, offset
end

-- Marks a judged call in the code, with the question and the answer on two
-- lines above it: grey while the model answers, then blue where the rule's
-- fix landed, red where the finding stays a warning, green where the call is
-- left as is.
local function mark(bufnr, r)
	local hl, says, says_hl = "Visual", "…", "Comment"
	local verdict = string.format("%s %s", r.label or "", r.p or "")
	if r.fixed then
		local which = r.pick and ("the " .. r.label .. " fix") or "the rule's fix"
		hl, says, says_hl = "DiffChange", verdict .. " → " .. which .. " applied", "DiagnosticInfo"
	elseif r.label and not r.answered then
		says = r.label == "" and "no answer" or verdict .. " unsure"
		hl, says, says_hl = "DiffDelete", says .. " → a warning, no fix", "DiagnosticWarn"
	elseif r.kept then
		hl, says, says_hl = "DiffDelete", verdict .. " → a warning, no fix", "DiagnosticWarn"
	elseif r.label then
		hl, says, says_hl = "DiffAdd", verdict .. " → left as is", "DiagnosticOk"
	end
	local line = vim.api.nvim_buf_get_lines(bufnr, r.line, r.line + 1, false)[1] or ""
	local indent = string.rep(" ", vim.fn.strdisplaywidth(line:match("^%s*")))
	vim.api.nvim_buf_set_extmark(bufnr, verdict_ns, r.line, r.col, {
		end_row = r.end_line,
		end_col = r.end_col,
		hl_group = hl,
		virt_lines = vim.list_extend({
			{ { indent .. "classif asks: ", "Comment" }, { r.ask, "Question" } },
		}, {
			r.context and { { indent .. "classif reads: ", "Comment" }, { r.context, "Comment" } } or nil,
			{ { indent .. "classif says: ", "Comment" }, { says, says_hl } },
		}),
		virt_lines_above = true,
	})
end

-- Says what an answer did to its call, for the quickfix entry.
local function outcome(r)
	if r.fixed then
		return "fixed by " .. r.rule .. ": " .. r.fix
	elseif not r.answered then
		return "no answer, so a warning and no fix"
	elseif r.kept then
		return "a warning, no fix"
	end
	return "left as is"
end

-- Fills the quickfix list: each question classif asked, the answer for every
-- call under it and what the answer did, then ast-grep's other findings,
-- hints aside. The list opens at the bottom; the cursor stays in the code,
-- and Enter on an entry jumps onto its call, where gra finds the fixes.
local function show_list(bufnr, rows)
	local items, asks = {}, {}
	for _, r in ipairs(rows) do
		if not vim.tbl_contains(asks, r.ask) then
			table.insert(asks, r.ask)
		end
	end
	for _, ask in ipairs(asks) do
		table.insert(items, { text = "classif asks: " .. ask })
		for _, r in ipairs(rows) do
			if r.ask == ask then
				table.insert(items, {
					bufnr = bufnr,
					lnum = r.line + 1,
					col = r.col + 1,
					type = r.answered and "I" or "W",
					text = string.format("%s %s, %s", r.label, r.p, outcome(r)),
				})
			end
		end
	end
	local others = vim.diagnostic.toqflist(vim.tbl_filter(function(d)
		return d.namespace ~= classif_ns
	end, vim.diagnostic.get(bufnr, { severity = { min = vim.diagnostic.severity.INFO } })))
	if #others > 0 then
		table.insert(items, { text = "ast-grep, other findings:" })
		vim.list_extend(items, others)
	end
	vim.fn.setqflist({}, " ", { title = "ast-grep + classif", items = items })
	vim.cmd("botright copen " .. math.min(#items, 10))
	vim.cmd("wincmd p")
end

vim.api.nvim_create_user_command("Classif", function(cmd)
	local pick = cmd.args == "pick"
	local key = pick and "choose" or "ask"
	local bufnr = vim.api.nvim_get_current_buf()
	vim.diagnostic.reset(classif_ns, bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, verdict_ns, 0, -1)
	local copy = vim.fn.tempname() .. "." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":e")
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local tick = vim.b[bufnr].changedtick
	vim.fn.writefile(lines, copy)
	local scan = vim.system(
		{ "ast-grep", "scan", "--json=stream", "--include-metadata", copy },
		{ cwd = dir, text = true }
	)
		:wait()
	-- One row per call and question: triage.sh asks once for the rules that
	-- match the same call, and a pick offers each of their fixes.
	local rows, seen = {}, {}
	for line in vim.gsplit(scan.stdout or "", "\n", { trimempty = true }) do
		local f = vim.json.decode(line)
		local ask = type(f.metadata) == "table" and f.metadata[key]
		local id = ask and f.range.byteOffset.start .. ask
		if ask and not seen[id] then
			seen[id] = true
			local r = { rule = f.ruleId, ask = ask, start = f.range.byteOffset.start, pick = pick }
			r.line, r.col = position(lines, f.range.byteOffset.start)
			r.end_line, r.end_col = position(lines, f.range.byteOffset["end"])
			table.insert(rows, r)
			mark(bufnr, r)
		end
	end
	if #rows == 0 then
		vim.fn.delete(copy)
		vim.notify("classif: no rule here asks a question")
		Demo.classified = Demo.classified + 1
		return
	end
	vim.notify(string.format("classif: asking about %d %s", #rows, #rows == 1 and "call" or "calls"))
	vim.system(
		{ dir .. "/triage.sh", "--json", pick and "--pick" or nil },
		{ cwd = dir, text = true, stdin = scan.stdout },
		-- triage.sh reads the copy too, for the declarations a rule asks it
		-- to show the model, so the copy goes once the answers are in.
		vim.schedule_wrap(function(out)
			vim.fn.delete(copy)
			local fixes = {}
			for line in vim.gsplit(out.stdout or "", "\n", { trimempty = true }) do
				local v = vim.json.decode(line)
				for _, r in ipairs(rows) do
					if r.start == v.start and r.ask == v.ask then
						r.label, r.p, r.kept, r.message, r.answered = v.label, v.p, v.kept, v.message, v.answered
						r.context = v.context ~= "" and vim.split(v.context, "\n")[1] or nil
						-- A finding kept for want of an answer is never fixed: a
						-- model that is down must rewrite nothing.
						if v.kept and v.answered and v.fix ~= vim.NIL then
							r.rule, r.fix, r.fix_start, r.fix_end = v.rule, v.fix, v.fix_start, v.fix_end
							table.insert(fixes, r)
						end
					end
				end
			end
			-- The fixes were built from the copy, so they apply only to the
			-- buffer it was taken from. Last offset first keeps the earlier
			-- offsets valid.
			if #fixes > 0 and vim.b[bufnr].changedtick ~= tick then
				vim.notify("classif: the buffer changed while the model answered; no fix applied")
				fixes = {}
			end
			table.sort(fixes, function(a, b)
				return a.fix_start > b.fix_start
			end)
			for _, r in ipairs(fixes) do
				local sl, sc = position(lines, r.fix_start)
				local el, ec = position(lines, r.fix_end)
				local text = vim.split(r.fix, "\n")
				vim.api.nvim_buf_set_text(bufnr, sl, sc, el, ec, text)
				r.fixed = true
				r.line, r.col = sl, sc
				r.end_line = sl + #text - 1
				r.end_col = (#text == 1 and sc or 0) + #text[#text]
			end
			local diags = {}
			vim.api.nvim_buf_clear_namespace(bufnr, verdict_ns, 0, -1)
			for _, r in ipairs(rows) do
				if r.kept and not r.fixed then
					table.insert(diags, {
						lnum = r.line,
						col = r.col,
						end_lnum = r.end_line,
						end_col = r.end_col,
						severity = vim.diagnostic.severity.WARN,
						source = "classif",
						message = string.format("%s (classif: %s %s)", r.message, r.label, r.p),
					})
				end
				mark(bufnr, r)
			end
			vim.diagnostic.set(classif_ns, bufnr, diags)
			show_list(bufnr, rows)
			Demo.classified = Demo.classified + 1
		end)
	)
end, {
	nargs = "?",
	complete = function()
		return { "pick" }
	end,
	desc = "Ask classif about each call and apply the fix its answer names; pick chooses among fixes",
})

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
	"ignored-error-return",
	"panic-on-error",
	"vague-error-message",
}
