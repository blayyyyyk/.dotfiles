return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	cmd = "Telescope",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MaximilianLloyd/ascii.nvim",
		-- Native sorter; needs make and a C compiler. Telescope still works if
		-- the build failed, just with the slower Lua sorter.
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		local telescope = require("telescope")
		telescope.setup({
			pickers = {
				colorscheme = {
					enable_preview = true,
					theme = "dropdown",
				},
			},
		})
		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "ascii")
	end,
}
