return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local bufferline = require("bufferline")
		bufferline.setup({
			options = {
				mode = "buffers",
				style_preset = bufferline.style_preset.default,
				themable = true,
				numbers = "none",
				indicator = {
					style = "underline",
				},
				diagnostics = "nvim_lsp",
				separator_style = "thin",
				show_tab_indicators = true,
			},
		})
	end,
}
