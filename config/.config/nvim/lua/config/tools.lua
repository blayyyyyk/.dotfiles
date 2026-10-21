-- Everything this config expects to have installed, in one place.
--
-- Mason installs `servers` and `tools`, nvim-treesitter installs `parsers`,
-- and `:checkhealth config` / `:ConfigDoctor` (run by CI on macOS and Linux)
-- fail if any of it is missing or doesn't work. Add new languages here.
local M = {}

-- LSP servers, by nvim-lspconfig name. `needs` gates a server on a toolchain
-- it can't do anything without, so machines without Go or Rust stay green.
M.servers = {
	{ name = "pyright" }, -- Python type checking
	{ name = "ruff" }, -- Python linting
	{ name = "lua_ls" },
	{ name = "clangd" },
	{ name = "ts_ls" }, -- JavaScript / TypeScript type checking
	{ name = "eslint" }, -- attaches only in projects with an eslint config
	{ name = "html" },
	{ name = "cssls" },
	{ name = "tailwindcss" }, -- attaches only in projects with a tailwind config
	{ name = "jsonls" },
	{ name = "yamlls" },
	{ name = "bashls" }, -- also reports shellcheck findings
	{ name = "taplo" }, -- TOML
	{ name = "marksman" }, -- Markdown
	{ name = "rust_analyzer", needs = "cargo" },
	{ name = "gopls", needs = "go" },
}

-- Formatters, linters and CLIs, by Mason package name.
M.tools = {
	"stylua",
	"prettier",
	"shfmt",
	"shellcheck",
	-- nvim-treesitter's main branch compiles parsers with this CLI.
	"tree-sitter-cli",
}

-- Parsers installed up front. Other languages install the first time a file
-- of that type is opened.
M.parsers = {
	"bash",
	"c",
	"cpp",
	"css",
	"csv",
	"diff",
	"dockerfile",
	"git_config",
	"gitcommit",
	"gitignore",
	"go",
	"html",
	"javascript",
	"jsdoc",
	"json",
	"lua",
	"luadoc",
	"make",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"regex",
	"rust",
	"sql",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

-- Programs plugins shell out to. Missing ones are reported, not installed.
M.external = {
	{ bin = "git", why = "lazy.nvim, vgit, lazygit" },
	{ bin = "rg", why = "Telescope live grep and find files" },
	{ bin = "lazygit", why = "<leader>gg" },
	{ bin = "node", why = "Copilot and the npm-based language servers" },
	{ bin = "curl", why = "Mason and nvim-treesitter downloads" },
	{ bin = "tar", why = "Mason and nvim-treesitter downloads" },
	{ bin = "unzip", why = "Mason downloads" },
	{ bin = "cc", why = "compiling tree-sitter parsers" },
	{ bin = "make", why = "building telescope-fzf-native" },
}

function M.server_enabled(server)
	return server.needs == nil or vim.fn.executable(server.needs) == 1
end

---@return string[]
function M.enabled_servers()
	local names = {}
	for _, server in ipairs(M.servers) do
		if M.server_enabled(server) then
			table.insert(names, server.name)
		end
	end
	return names
end

-- The mason-tool-installer list: servers (lspconfig names, mapped to Mason
-- packages by mason-lspconfig) plus tools.
function M.mason_ensure_installed()
	local list = {}
	for _, server in ipairs(M.servers) do
		table.insert(list, {
			server.name,
			condition = function()
				return M.server_enabled(server)
			end,
		})
	end
	vim.list_extend(list, M.tools)
	return list
end

return M
