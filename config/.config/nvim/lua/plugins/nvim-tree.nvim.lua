return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			git = {
				enable = true,
			},
			diagnostics = {
				enable = true,
				show_on_dirs = true,
			},
			view = {
				cursorline = true,
				signcolumn = "yes",
			},
			renderer = {
				indent_markers = {
					enable = true,
					icons = {
						corner = "└ ",
						edge = "│ ",
						item = "│ ",
					},
				},
			},
		})
	end,
}
