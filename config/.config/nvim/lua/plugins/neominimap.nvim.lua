return {
	"Isrothy/neominimap.nvim",
	version = "v3.x.x",
	lazy = false, -- NOTE: NO NEED to Lazy load
	keys = {
		{ "<leader>um", "<cmd>Neominimap Toggle<CR>", desc = "Toggle minimap" },
		{ "<leader>uf", "<cmd>Neominimap ToggleFocus<CR>", desc = "Focus or unfocus minimap" },
	},
	init = function()
		vim.g.neominimap = {
			float = {
				window_border = "rounded",
			},
			click = {
				enabled = true,
				auto_switch_focus = true,
			},
		}
	end,
}
