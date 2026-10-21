local tools = require("config.tools")

-- Headless runs (CI, scripts/nvim-update.sh) install synchronously through
-- :ConfigSync, so they must not start a second install in the background.
local headless = vim.list_contains(vim.v.argv, "--headless")

return {
	{
		"mason-org/mason.nvim",
		version = "^2",
		-- Not lazy: setup() puts Mason's bin/ on PATH, which every server,
		-- formatter and the tree-sitter CLI below are found through.
		lazy = false,
		opts = { ui = { border = "rounded" } },
	},
	{
		-- Only used for its lspconfig-name -> Mason-package mapping. Servers are
		-- enabled explicitly from config.tools so the list lives in one place.
		"mason-org/mason-lspconfig.nvim",
		version = "^2",
		dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
		opts = { automatic_enable = false },
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = false,
		dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
		opts = {
			ensure_installed = tools.mason_ensure_installed(),
			run_on_start = not headless,
			-- Versions stay put until :MasonToolsUpdate; nothing changes underneath you.
			auto_update = false,
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			-- Advertise nvim-cmp's completion capabilities to every server.
			vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("config_lsp", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					-- Pyright's hover has the types and docs; ruff's would shadow it.
					if client and client.name == "ruff" then
						client.server_capabilities.hoverProvider = false
					end
				end,
			})

			-- Server settings come from nvim-lspconfig's lsp/*.lua, with local
			-- overrides in after/lsp/*.lua.
			vim.lsp.enable(tools.enabled_servers())

			-- On a fresh machine, files opened at startup fired FileType before
			-- Mason had installed their servers. enable() again re-checks every
			-- open buffer once the installs finish.
			vim.api.nvim_create_autocmd("User", {
				pattern = "MasonToolsUpdateCompleted",
				group = vim.api.nvim_create_augroup("config_lsp_installed", { clear = true }),
				callback = function()
					vim.schedule(function()
						vim.lsp.enable(tools.enabled_servers())
					end)
				end,
			})
		end,
	},
	{
		-- Neovim API types and completion for lua_ls while editing this config.
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
}
