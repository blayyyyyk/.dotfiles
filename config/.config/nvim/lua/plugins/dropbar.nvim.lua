return {
	-- Breadcrumb winbar. Replaces barbecue.nvim, which is archived upstream.
	"Bekaboo/dropbar.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = { "BufReadPost", "BufNewFile" },
	opts = {},
}
