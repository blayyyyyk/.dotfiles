-- file: init.lua
-- Leader must be set before lazy.nvim loads any plugin keymaps.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")

-- nvim-treesitter's main branch and the vim.lsp.config API need Neovim 0.12.
-- On anything older, skip plugins instead of erroring in every buffer.
if vim.fn.has("nvim-0.12") == 0 then
	vim.schedule(function()
		vim.notify(
			"This config needs Neovim 0.12+ (found " .. tostring(vim.version()) .. "). Plugins are disabled.",
			vim.log.levels.WARN
		)
	end)
	return
end

-- plugin manager
require("config.lazy")
require("config.iterm")
require("config.remap")
require("config.vscode_remap")
require("config.doctor").setup()
