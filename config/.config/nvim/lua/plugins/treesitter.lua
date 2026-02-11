return {
	"nvim-treesitter/nvim-treesitter",
	version = false, -- Last release is way too old
	build = ":TSUpdate",
	-- event = { "BufReadPost", "BufNewFile" },
	lazy = false, -- Keep false to ensure loading for Neo-tree
	main = "nvim-treesitter.configs", -- Lazy handles the require logic here
	branch = "master", -- Explicitly force the stable branch
	opts = {
		ensure_installed = {
			"lua",
			"vim",
			"vimdoc",
			"query",
			"python",
			"c",
			"cpp",
			"markdown",
			"markdown_inline",
			"csv",
			"json",
		},
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true },
	},
	-- Fallback config to handle edge cases
	config = function(_, opts)
		-- Protective call: If treesitter fails to load, don't crash neovim
		local status_ok, configs = pcall(require, "nvim-treesitter.configs")
		if not status_ok then
			return
		end
		configs.setup(opts)
	end,
}
