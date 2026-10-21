-- nvim-treesitter's `main` branch: the `master` branch is frozen and does not
-- support Neovim 0.12. Parsers are compiled with the tree-sitter CLI, which
-- Mason installs (see config.tools), and land in stdpath("data")/site.
local tools = require("config.tools")

local M = {}

-- False while the old `master` checkout is still loaded (the first start after
-- switching branches); everything here then waits for the next start.
local function on_main_branch()
	return type(require("nvim-treesitter").get_available) == "function"
end

local available
local function is_available(lang)
	if not on_main_branch() then
		return false
	end
	if not available then
		available = {}
		for _, name in ipairs(require("nvim-treesitter").get_available()) do
			available[name] = true
		end
	end
	return available[lang] == true
end

-- Start highlighting (and indentation, where the language has indent queries)
-- for a buffer. Returns false when the parser isn't installed yet.
local function start(buf, lang)
	local ok, loaded = pcall(vim.treesitter.language.add, lang)
	if not (ok and loaded) then
		return false
	end
	if not pcall(vim.treesitter.start, buf, lang) then
		return false
	end
	if #vim.api.nvim_get_runtime_file("queries/" .. lang .. "/indents.scm", false) > 0 then
		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
	return true
end

-- Re-run `start` for every loaded buffer of a language once its parser lands.
local function restart(lang)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.treesitter.language.get_lang(vim.bo[buf].filetype) == lang then
			start(buf, lang)
		end
	end
end

local pending = {}
local function install(langs)
	langs = vim.tbl_filter(function(lang)
		return not pending[lang]
	end, langs)
	if #langs == 0 or vim.fn.executable("tree-sitter") == 0 then
		return
	end
	for _, lang in ipairs(langs) do
		pending[lang] = true
	end
	require("nvim-treesitter").install(langs):await(function()
		vim.schedule(function()
			for _, lang in ipairs(langs) do
				pending[lang] = nil
				restart(lang)
			end
		end)
	end)
end

---@return string[]
function M.missing_parsers()
	local have = {}
	for _, lang in ipairs(require("nvim-treesitter").get_installed("parsers")) do
		have[lang] = true
	end
	return vim.tbl_filter(function(lang)
		return not have[lang]
	end, tools.parsers)
end

-- Install the configured parsers. On a fresh machine the tree-sitter CLI is
-- still being installed by Mason, so wait for that to finish first.
function M.ensure_parsers()
	if not on_main_branch() then
		return
	end
	local missing = M.missing_parsers()
	if #missing == 0 then
		return
	end
	if vim.fn.executable("tree-sitter") == 1 then
		install(missing)
	else
		vim.api.nvim_create_autocmd("User", {
			pattern = "MasonToolsUpdateCompleted",
			once = true,
			callback = function()
				vim.schedule(M.ensure_parsers)
			end,
		})
	end
end

function M.attach(buf, filetype)
	local lang = vim.treesitter.language.get_lang(filetype)
	if not lang or start(buf, lang) then
		return
	end
	-- Not installed yet: fetch it if nvim-treesitter knows the language.
	if is_available(lang) then
		install({ lang })
	end
end

package.loaded["config.treesitter"] = M

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false, -- nvim-treesitter does not support lazy-loading
	build = ":TSUpdate",
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("config_treesitter", { clear = true }),
			callback = function(args)
				M.attach(args.buf, args.match)
			end,
		})
		-- Headless runs install synchronously through :ConfigSync instead.
		if not vim.list_contains(vim.v.argv, "--headless") then
			M.ensure_parsers()
		end
	end,
}
