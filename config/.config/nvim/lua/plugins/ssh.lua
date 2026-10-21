return {
	-- Archived upstream (Aug 2026). Pinned by lazy-lock.json and loaded only on
	-- its commands, so it can't affect normal startup.
	"amitds1997/remote-nvim.nvim",
	version = "*", -- Pin to GitHub releases
	cmd = { "RemoteStart", "RemoteStop", "RemoteInfo", "RemoteCleanup", "RemoteConfigDel", "RemoteLog" },
	dependencies = {
		"nvim-lua/plenary.nvim", -- For standard functions
		"MunifTanjim/nui.nvim", -- To build the plugin UI
		"nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
	},
	config = true,
}
