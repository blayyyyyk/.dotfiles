-- Install and verify everything listed in config.tools.
--
--   :ConfigSync      install missing plugins, Mason tools and parsers (blocks)
--   :ConfigDoctor    static checks plus a smoke test: open real files and make
--                    sure each language server attaches and reports
--                    diagnostics, each formatter formats, and tree-sitter
--                    highlights. Headless, it prints a report and exits
--                    non-zero on any failure (scripts/nvim-doctor.sh, CI).
--   :checkhealth config   the static checks only.
local tools = require("config.tools")

local M = {}

local function headless()
	return #vim.api.nvim_list_uis() == 0
end

local function log(msg)
	if headless() then
		io.stdout:write(msg .. "\n")
	else
		vim.api.nvim_echo({ { msg } }, true, {})
	end
end

-- Results are { section, name, status = "ok"|"fail"|"skip", detail }.
local Report = {}
Report.__index = Report

local function new_report()
	return setmetatable({ items = {} }, Report)
end

function Report:add(section, name, status, detail)
	table.insert(self.items, { section = section, name = name, status = status, detail = detail })
end

-- `why` explains a failure; `detail` annotates a pass.
function Report:check(section, name, ok, why, detail)
	if ok then
		self:add(section, name, "ok", detail)
	else
		self:add(section, name, "fail", why)
	end
end

function Report:failures()
	return vim.tbl_filter(function(item)
		return item.status == "fail"
	end, self.items)
end

---------------------------------------------------------------------------
-- Static checks
---------------------------------------------------------------------------

local function check_plugins(report)
	local plugins = require("lazy.core.config").plugins
	local names = vim.tbl_keys(plugins)
	table.sort(names)
	for _, name in ipairs(names) do
		local plugin = plugins[name]
		report:check("Plugins", name, plugin._.installed == true, "not installed")
	end
end

local function server_cmd(name)
	local ok, config = pcall(function()
		return vim.lsp.config[name]
	end)
	if not ok or not config then
		return nil, "no nvim-lspconfig config named " .. name
	end
	if type(config.cmd) == "table" then
		return config.cmd[1]
	end
	return true -- cmd is a function; it resolves its own binary
end

local function check_servers(report)
	for _, server in ipairs(tools.servers) do
		if not tools.server_enabled(server) then
			report:add("Language servers", server.name, "skip", server.needs .. " not installed")
		else
			local cmd, err = server_cmd(server.name)
			if cmd == nil then
				report:check("Language servers", server.name, false, err)
			elseif cmd == true then
				report:check("Language servers", server.name, true)
			else
				local exe = vim.fn.exepath(cmd)
				report:check("Language servers", server.name, exe ~= "", cmd .. " not on PATH", exe)
			end
		end
	end
end

local function check_tools(report)
	local registry_ok, registry = pcall(require, "mason-registry")
	for _, pkg in ipairs(tools.tools) do
		local installed = registry_ok and registry.is_installed(pkg)
		report:check("Mason tools", pkg, installed, "not installed by Mason")
	end
end

local function check_formatters(report)
	local conform = require("conform")
	local fts = vim.tbl_keys(conform.formatters_by_ft)
	table.sort(fts)
	for _, ft in ipairs(fts) do
		local spec = conform.formatters_by_ft[ft]
		if type(spec) == "function" then
			spec = spec(0)
		end
		local names = {}
		for _, name in ipairs(spec) do
			table.insert(names, name)
		end
		local available, missing = {}, {}
		for _, name in ipairs(names) do
			local info = conform.get_formatter_info(name)
			table.insert(info.available and available or missing, name)
		end
		local ok = spec.stop_after_first and #available > 0 or #missing == 0
		if not ok and ft == "rust" and vim.fn.executable("cargo") == 0 then
			report:add("Formatters", ft, "skip", "cargo not installed")
		else
			report:check("Formatters", ft, ok, "missing " .. table.concat(missing, ", "), table.concat(available, ", "))
		end
	end
end

local function check_parsers(report)
	report:check(
		"Tree-sitter",
		"tree-sitter CLI",
		vim.fn.executable("tree-sitter") == 1,
		"not on PATH",
		vim.fn.exepath("tree-sitter")
	)
	for _, lang in ipairs(tools.parsers) do
		local ok, loaded = pcall(vim.treesitter.language.add, lang)
		report:check("Tree-sitter", lang, ok and loaded == true, "parser not installed")
	end
end

local function check_external(report)
	report:check(
		"Neovim",
		"version",
		vim.fn.has("nvim-0.12") == 1,
		tostring(vim.version()) .. " < 0.12",
		tostring(vim.version())
	)
	for _, ext in ipairs(tools.external) do
		local exe = vim.fn.exepath(ext.bin)
		report:check("External programs", ext.bin, exe ~= "", "missing: needed for " .. ext.why, exe)
	end
end

function M.static_report()
	local report = new_report()
	check_external(report)
	check_plugins(report)
	check_servers(report)
	check_tools(report)
	check_formatters(report)
	check_parsers(report)
	return report
end

---------------------------------------------------------------------------
-- Smoke test
---------------------------------------------------------------------------

-- Each case opens a file in a throwaway git repo. `clients` must attach;
-- `diagnose` clients must also publish at least one diagnostic for the
-- deliberate mistake in `text`.
local cases = {
	{
		file = "main.py",
		text = { "import os", "", "", "def double(x: int) -> int:", "    return x * 2", "", "", 'double("two")' },
		clients = { "pyright", "ruff" },
		diagnose = { "pyright", "ruff" },
	},
	{
		file = "main.lua",
		text = { "local value = undefined_global_name", "return value" },
		clients = { "lua_ls" },
		diagnose = { "lua_ls" },
	},
	{
		file = "main.sh",
		text = { "#!/usr/bin/env bash", "echo $1" },
		clients = { "bashls" },
		diagnose = { "bashls" }, -- shellcheck SC2086, reported through bashls
	},
	{
		file = "main.ts",
		text = { 'const n: number = "s";', "export default n;" },
		clients = { "ts_ls" },
		diagnose = { "ts_ls" },
	},
	{
		file = "main.c",
		text = { "int main(void) { return missing_symbol; }" },
		clients = { "clangd" },
		diagnose = { "clangd" },
	},
	{ file = "data.json", text = { '{ "a": 1 }' }, clients = { "jsonls" } },
	{ file = "data.yaml", text = { "a: 1" }, clients = { "yamlls" } },
	{ file = "data.toml", text = { "a = 1" }, clients = { "taplo" } },
	{ file = "notes.md", text = { "# Notes" }, clients = { "marksman" } },
	{ file = "index.html", text = { "<p>hi</p>" }, clients = { "html" } },
	{ file = "style.css", text = { "p { color: red; }" }, clients = { "cssls" } },
}

local format_cases = {
	{ file = "fmt.lua", text = { "local   x  =  1", "return x" }, expect = "local x = 1" },
	{ file = "fmt.py", text = { "x=1" }, expect = "x = 1" },
	{ file = "fmt.ts", text = { "const x={a:1}" }, expect = "const x = { a: 1 };" },
	{ file = "fmt.sh", text = { "if true;then echo hi;fi" }, expect = "if true; then echo hi; fi" },
}

local function client_diagnostics(buf, client_name)
	local count = 0
	local namespaces = vim.diagnostic.get_namespaces()
	for _, d in ipairs(vim.diagnostic.get(buf)) do
		local ns = namespaces[d.namespace]
		if ns and ns.name and ns.name:find(client_name, 1, true) then
			count = count + 1
		end
	end
	return count
end

local function open(dir, file, lines)
	local path = dir .. "/" .. file
	vim.fn.writefile(lines, path)
	vim.cmd.edit(vim.fn.fnameescape(path))
	return vim.api.nvim_get_current_buf()
end

local function smoke(report)
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir .. "/.git", "p") -- root marker for every server
	local enabled = {}
	for _, name in ipairs(tools.enabled_servers()) do
		enabled[name] = true
	end

	-- Force-load lazy plugins so their config() runs and any error surfaces.
	local lazy_plugins = {}
	for name, plugin in pairs(require("lazy.core.config").plugins) do
		if plugin._.cond ~= false and not plugin._.loaded then
			table.insert(lazy_plugins, name)
		end
	end
	require("lazy").load({ plugins = lazy_plugins })
	report:check("Smoke test", "load all plugins", true, nil, #lazy_plugins .. " lazy plugins loaded")
	report:check(
		"Smoke test",
		"telescope fzf sorter",
		require("telescope").extensions.fzf ~= nil,
		"telescope-fzf-native failed to build or load"
	)

	for _, case in ipairs(cases) do
		local buf = open(dir, case.file, case.text)
		local label = case.file

		report:check(
			"Smoke test",
			label .. ": tree-sitter",
			vim.treesitter.highlighter.active[buf] ~= nil,
			"not highlighting"
		)

		for _, name in ipairs(case.clients) do
			if enabled[name] then
				local attached = vim.wait(90000, function()
					return #vim.lsp.get_clients({ bufnr = buf, name = name }) > 0
				end, 200)
				report:check("Smoke test", label .. ": " .. name .. " attaches", attached, "never attached")
			end
		end
		for _, name in ipairs(case.diagnose or {}) do
			if enabled[name] then
				local got = vim.wait(90000, function()
					return client_diagnostics(buf, name) > 0
				end, 250)
				report:check(
					"Smoke test",
					label .. ": " .. name .. " reports diagnostics",
					got,
					"no diagnostics within 90s",
					client_diagnostics(buf, name) .. " found"
				)
			end
		end
	end

	local conform = require("conform")
	for _, case in ipairs(format_cases) do
		local buf = open(dir, case.file, case.text)
		local ok, err = pcall(conform.format, { bufnr = buf, async = false, timeout_ms = 20000 })
		local first = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
		report:check(
			"Smoke test",
			case.file .. ": formats",
			ok and first == case.expect,
			ok and ("got: " .. tostring(first)) or tostring(err)
		)
	end

	vim.cmd("silent! %bwipeout!")
	vim.fn.delete(dir, "rf")
end

---------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------

-- Errors raised anywhere while the doctor runs count as failures.
local function capture_errors()
	local errors = {}
	local notify = vim.notify
	vim.notify = function(msg, level, opts)
		if level and level >= vim.log.levels.ERROR then
			table.insert(errors, tostring(msg))
		end
		return notify(msg, level, opts)
	end
	return errors, function()
		vim.notify = notify
	end
end

local function message_errors()
	local out = vim.api.nvim_exec2("messages", { output = true }).output
	local errors = {}
	for line in vim.gsplit(out, "\n") do
		if line:match("^E%d+:") or line:match("^Error") or line:match("stack traceback") then
			table.insert(errors, line)
		end
	end
	return errors
end

local function print_report(report)
	local section
	for _, item in ipairs(report.items) do
		if item.section ~= section then
			section = item.section
			log("\n" .. section)
		end
		local mark = ({ ok = "  ok  ", fail = "  FAIL", skip = "  skip" })[item.status]
		log(string.format("%s  %s%s", mark, item.name, item.detail and ("  (" .. item.detail .. ")") or ""))
	end
	local failures = report:failures()
	log(string.format("\n%d checks, %d failed", #report.items, #failures))
	return #failures == 0
end

function M.sync(opts)
	opts = opts or {}
	if opts.restore then
		log("Restoring plugins to lazy-lock.json ...")
		require("lazy").restore({ wait = true, show = false })
	else
		require("lazy").install({ wait = true, show = false })
	end
	log("Installing Mason tools ...")
	vim.cmd("MasonToolsInstallSync")
	log("Installing tree-sitter parsers ...")
	local ts = require("nvim-treesitter")
	ts.install(tools.parsers, { summary = true }):wait(30 * 60 * 1000)
	ts.update(nil, { summary = true }):wait(30 * 60 * 1000)
end

function M.doctor()
	local errors, restore = capture_errors()
	local report = M.static_report()
	local ok, err = pcall(smoke, report)
	report:check("Smoke test", "completed", ok, tostring(err))
	restore()
	for _, msg in ipairs(vim.list_extend(errors, message_errors())) do
		report:add("Errors raised", msg:sub(1, 200), "fail")
	end
	local passed = print_report(report)
	if headless() then
		vim.cmd(passed and "qall!" or "cquit 1")
	end
	return passed
end

function M.health()
	local report = M.static_report()
	local section
	for _, item in ipairs(report.items) do
		if item.section ~= section then
			section = item.section
			vim.health.start(section)
		end
		local text = item.name .. (item.detail and (": " .. item.detail) or "")
		if item.status == "ok" then
			vim.health.ok(text)
		elseif item.status == "skip" then
			vim.health.info("skipped " .. text)
		else
			vim.health.error(text)
		end
	end
end

function M.setup()
	vim.api.nvim_create_user_command("ConfigSync", function(cmd)
		M.sync({ restore = cmd.bang })
	end, { bang = true, desc = "Install plugins, Mason tools and parsers (! restores lazy-lock.json)" })
	vim.api.nvim_create_user_command("ConfigDoctor", function()
		M.doctor()
	end, { desc = "Verify servers, formatters and parsers actually work" })
end

return M
