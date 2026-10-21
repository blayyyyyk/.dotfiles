-- Maintained fork of pocco81/auto-save.nvim, which stopped getting fixes in 2024.
local excluded_filetypes = { "gitcommit", "gitrebase", "TelescopePrompt", "NvimTree", "alpha", "toggleterm" }

return {
	"okuuva/auto-save.nvim",
	event = { "InsertLeave", "TextChanged" },
	opts = {
		enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
		trigger_events = {
			immediate_save = { "BufLeave", "WinLeave", "FocusLost", "QuitPre", "VimSuspend" },
			defer_save = { "InsertLeave", "TextChanged" },
			cancel_deferred_save = { "InsertEnter" },
		},
		-- Only real files: writing a prompt, terminal or scratch buffer errors out.
		condition = function(buf)
			return vim.bo[buf].modifiable
				and vim.bo[buf].buftype == ""
				and vim.api.nvim_buf_get_name(buf) ~= ""
				and not vim.tbl_contains(excluded_filetypes, vim.bo[buf].filetype)
		end,
		write_all_buffers = false, -- write all buffers when the current one meets `condition`
		debounce_delay = 135, -- saves the file at most every `debounce_delay` milliseconds
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "AutoSaveWritePost",
			group = vim.api.nvim_create_augroup("config_autosave", { clear = true }),
			callback = function()
				vim.api.nvim_echo({ { "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"), "Comment" } }, false, {})
			end,
		})
	end,
}
