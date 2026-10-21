return {
	"bassamsdata/namu.nvim",
	cmd = "Namu",
	opts = {
		global = {},
		namu_symbols = { -- Specific Module options
			options = {},
		},
	},
	keys = {
		{ "<leader>ss", "<cmd>Namu symbols<cr>", desc = "Jump to LSP symbol" },
		{ "<leader>sw", "<cmd>Namu workspace<cr>", desc = "LSP Symbols - Workspace" },
	},
}
