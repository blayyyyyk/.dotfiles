return {
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000, -- load before other UI plugins read highlight groups
		config = function()
			vim.g.gruvbox_material_enable_italic = true
			vim.g.gruvbox_material_background = "medium"
			vim.g.gruvbox_material_palette = "mix"
			if not pcall(vim.cmd.colorscheme, "gruvbox-material") then
				vim.cmd.colorscheme("habamax")
			end
		end,
	},
	{ "sainnhe/everforest" },
	{ "motaz-shokry/gruvbox.nvim" },
	{ "xero/miasma.nvim" },
	{ "srcery-colors/srcery-vim" },
	{ "ghifarit53/tokyonight-vim" },
	{ "oxidescheme/oxide.nvim" },
	{ "joshdick/onedark.vim" },
	{ "nlknguyen/papercolor-theme" },
	{ "rose-pine/neovim" },
	{ "projekt0n/github-nvim-theme" },
	{ "sainnhe/sonokai" },
}
