return {
	"github/copilot.vim",
	-- Copilot runs on Node; without it the plugin errors on every buffer.
	cond = function()
		return vim.fn.executable("node") == 1
	end,
	event = "InsertEnter",
	cmd = "Copilot",
	init = function()
		-- Accept suggestions with Alt-Tab (as in Zed) instead of Tab.
		vim.g.copilot_no_tab_map = true
	end,
	config = function()
		vim.keymap.set("i", "<A-Tab>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
			desc = "Accept Copilot suggestion",
		})
	end,
}
