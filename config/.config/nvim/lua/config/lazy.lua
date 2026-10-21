-- nvim-treesitter installs parsers into stdpath("data")/site. lazy.nvim
-- rebuilds 'runtimepath' from the directories that exist whenever it loads a
-- plugin, so on a fresh machine the not-yet-created site dir would be dropped
-- and parsers installed this session wouldn't load until a restart.
vim.fn.mkdir(vim.fn.stdpath("data") .. "/site", "p")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		-- Offline or no git: keep the editor usable without plugins.
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim; starting without plugins:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
		}, true, {})
		return
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
	-- Missing plugins install at the commits in lazy-lock.json, so a new machine
	-- gets exactly the versions CI tested. Update with scripts/nvim-update.sh.
	install = { missing = true, colorscheme = { "gruvbox-material", "habamax" } },
	checker = { enabled = false },
	change_detection = { notify = false },
	-- No plugin here needs luarocks; this avoids lazy's hererocks health error.
	rocks = { enabled = false },
	ui = { border = "rounded" },
})
