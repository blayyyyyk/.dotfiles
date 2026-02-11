-- file: init.lua
vim.g.mapleader = "<Space>"

-- plugin manager
require("config.lazy")
require("config.iterm")
require("config.remap")
require("config.vscode_remap")
require("config.zed_remap")

-- language servers
vim.lsp.enable({
	"pyright",
	"clangd",
	"lua_ls",
})

-- builtin vim config
vim.cmd("source ~/.config/nvim/config.vim")
-- -- 5A524C

vim.opt.fillchars = {
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
		prefix = "■ ", -- Could be '●', '▎', 'x', '■', , 
	},
	float = { border = border },
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.shiftwidth = 4 -- Number of spaces for auto-indent
vim.opt.tabstop = 4 -- Number of spaces a <Tab> counts for
vim.opt.softtabstop = 4 -- Number of spaces <Tab> inserts in insert mode
-- Hide the status bar
vim.opt.laststatus = 0

-- Hide the "10,20" ruler position (if it still shows up)
vim.opt.ruler = false

-- Hide the command line until you actually type a command (Requires Neovim 0.8+)
vim.opt.cmdheight = 0
