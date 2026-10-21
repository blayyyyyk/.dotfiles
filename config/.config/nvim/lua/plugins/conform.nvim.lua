return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	cmd = "ConformInfo",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			-- Same tool the Python projects use (`ruff format && ruff check`); it
			-- reads each project's own ruff settings.
			python = { "ruff_organize_imports", "ruff_format" },
			-- You can customize some of the format options for the filetype (:help conform.format)
			rust = { "rustfmt", lsp_format = "fallback" },
			-- Conform will run the first available formatter
			javascript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			sh = { "shfmt" },
			bash = { "shfmt" },
		},
		-- Format on every write (auto-save included), like the old BufWritePre
		-- hook. `:FormatToggle` turns it off for the session.
		format_on_save = function()
			if vim.g.disable_autoformat then
				return
			end
			return { timeout_ms = 2000 }
		end,
		-- A filetype with no formatter is normal; don't announce it on each save.
		notify_no_formatters = false,
	},
	init = function()
		vim.api.nvim_create_user_command("FormatToggle", function()
			vim.g.disable_autoformat = not vim.g.disable_autoformat
			vim.notify("Format on save " .. (vim.g.disable_autoformat and "off" or "on"))
		end, { desc = "Toggle format on save" })
	end,
}
