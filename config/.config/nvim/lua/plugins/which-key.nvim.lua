return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		spec = {
			{ "<leader>c", group = "Code" },
			{ "<leader>d", group = "Diagnostics" },
			{ "<leader>e", group = "Explorer" },
			{ "<leader>f", group = "Find" },
			{ "<leader>g", group = "Git" },
			{ "<leader>r", group = "Refactor" },
			{ "<leader>s", group = "Symbols" },
			{ "<leader>t", group = "Terminal" },
			{ "<leader>u", group = "UI" },
			{ "<leader>w", group = "Windows" },
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ keys = "<leader>", mode = "n", delay = 0 })
			end,
			desc = "Show keyboard shortcuts",
		},
	},
}
