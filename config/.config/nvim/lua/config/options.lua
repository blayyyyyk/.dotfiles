local opt = vim.opt

opt.number = true
opt.mouse = "a"
opt.mousemodel = "extend"
opt.termguicolors = true
opt.laststatus = 2
opt.signcolumn = "yes"
opt.cursorline = true
opt.showmode = true
opt.splitright = true
opt.splitbelow = true

opt.expandtab = true -- Convert tabs to spaces
opt.shiftwidth = 4 -- Number of spaces for auto-indent
opt.tabstop = 4 -- Number of spaces a <Tab> counts for
opt.softtabstop = 4 -- Number of spaces <Tab> inserts in insert mode

-- Hide the "10,20" ruler position (if it still shows up)
opt.ruler = false

-- Hide the command line until you actually type a command (noice draws it)
opt.cmdheight = 0

-- -- 5A524C
opt.fillchars = {
	horiz = "━",
	horizup = "┻",
	horizdown = "┳",
	vert = "┃",
	vertleft = "┫",
	vertright = "┣",
	verthoriz = "╋",
}

local border = {
	{ "┌", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "┐", "FloatBorder" },
	{ "│", "FloatBorder" },
	{ "┘", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "└", "FloatBorder" },
	{ "│", "FloatBorder" },
}

-- Add border to the diagnostic popup window
vim.diagnostic.config({
	virtual_text = {
		prefix = "■ ", -- Could be '●', '▎', 'x', '■', ,
	},
	float = { border = border },
})
