-- Config for the demo nvim: stock Neovim, so viewers see the defaults they
-- get, plus the keystroke golf ledger from the dotfiles when it exists and a
-- command line centered on screen, so every Ex command reads as it is typed.
-- demo.sh drives it over RPC through the Demo table below; those calls are
-- not keystrokes, so the ledger counts only the keys the demo types.
vim.g.mapleader = " "
vim.o.number = true
vim.o.swapfile = false
vim.o.showcmd = true
vim.o.shortmess = vim.o.shortmess .. "I"
vim.o.statusline = " %t %m%=%l,%c "
-- Diff mode marks what still differs from the goal, down to the character.
-- It folds matching lines, and a solved exercise would fold away whole, so
-- the windows below turn folding off.
vim.opt.diffopt:append({ "foldcolumn:0" })
pcall(function()
	vim.opt.diffopt:append({ "inline:char" })
end)

-- ui2 draws the command line in a window of its own, and tiny-cmdline moves
-- that window mid-screen while a command or search is typed. setup-demo.sh
-- clones tiny-cmdline here; without it the command line stays at the bottom.
require("vim._core.ui2").enable({})
local plugins = (vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")) .. "/multicursor-demo"
vim.opt.runtimepath:prepend(plugins .. "/tiny-cmdline.nvim")
local has_cmdline, cmdline = pcall(require, "tiny-cmdline")
if has_cmdline then
	-- Keep 'cmdheight' so messages stay on the bottom row, and center searches
	-- too: hole 3 places its cursors with one.
	cmdline.setup({ manage_cmdheight = false, native_types = {} })
end

package.path = vim.fn.expand("~/.config/nvim/lua") .. "/?.lua;" .. package.path
local has_golf, golf = pcall(require, "user_functions.keystroke_golf")
if has_golf then
	golf.setup()
end

local mc_ns = vim.api.nvim_create_namespace("nvim.multicursor")
local goal_group = vim.api.nvim_create_augroup("demo_goal", { clear = true })
local work_buf, goal_buf, work_win

-- Reports whether the edit copy matches the goal.
local function is_solved()
	if not (work_buf and goal_buf) then
		return false
	end
	if not (vim.api.nvim_buf_is_valid(work_buf) and vim.api.nvim_buf_is_valid(goal_buf)) then
		return false
	end
	return vim.deep_equal(
		vim.api.nvim_buf_get_lines(work_buf, 0, -1, false),
		vim.api.nvim_buf_get_lines(goal_buf, 0, -1, false)
	)
end

-- Turns the edit window's bar green the moment its text matches the goal.
local function mark_goal()
	if work_win and vim.api.nvim_win_is_valid(work_win) then
		vim.wo[work_win].winbar = is_solved() and "%#DiffAdd# edit  ✓ matches the goal %*" or " edit"
	end
end

Demo = {}

-- Opens the exercise copy on top, its goal below, diffed against each other,
-- and the ledger at the bottom. Puts the cursor on the first line of the copy
-- with no cursors, search, or recording left over.
function Demo.load(work, goal)
	vim.cmd("stopinsert")
	vim.cmd("diffoff!")
	vim.cmd("only")
	vim.cmd("enew | setlocal bufhidden=wipe")
	-- An exercise played earlier left its copy modified; demo.sh has just
	-- rewritten the file, and reopening that buffer would stop on a W12 prompt.
	local path = vim.fn.fnamemodify(work, ":p")
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		vim.api.nvim_buf_clear_namespace(buf, mc_ns, 0, -1)
		if vim.api.nvim_buf_get_name(buf) == path then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
	vim.cmd("edit " .. vim.fn.fnameescape(work))
	work_win = vim.api.nvim_get_current_win()
	work_buf = vim.api.nvim_get_current_buf()
	vim.cmd("diffthis")
	vim.wo.foldenable = false
	vim.cmd("belowright split " .. vim.fn.fnameescape(goal))
	goal_buf = vim.api.nvim_get_current_buf()
	vim.bo.modifiable = false
	vim.wo.winbar = " goal"
	vim.cmd("diffthis")
	vim.wo.foldenable = false
	vim.api.nvim_win_set_height(work_win, 9)
	vim.api.nvim_clear_autocmds({ group = goal_group })
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		group = goal_group,
		buffer = work_buf,
		callback = mark_goal,
	})
	if has_golf then
		golf.toggle_panel()
	end
	vim.api.nvim_set_current_win(work_win)
	vim.api.nvim_win_set_cursor(work_win, { 1, 0 })
	vim.fn.setreg("/", "")
	vim.cmd("nohlsearch")
	mark_goal()
end

-- Starts or stops a keystroke golf recording; a no-op without the module.
function Demo.golf_toggle()
	if has_golf then
		golf.toggle_recording()
	end
end

-- Empties the ledger so each exercise ranks only its own attempts.
function Demo.golf_reset()
	if has_golf then
		golf.clear_ledger()
	end
end

-- Puts the edit copy back to the exercise's starting text.
function Demo.reset()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		vim.api.nvim_buf_clear_namespace(buf, mc_ns, 0, -1)
	end
	vim.api.nvim_set_current_win(work_win)
	vim.cmd("edit!")
	vim.cmd("diffupdate")
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	vim.fn.setreg("/", "")
	vim.cmd("nohlsearch")
	mark_goal()
end

-- 1 when the edit copy matches the goal, for the caption card.
function Demo.solved()
	return is_solved() and 1 or 0
end
