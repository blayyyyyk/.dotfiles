-- Merged over nvim-lspconfig's lsp/pyright.lua.
--
-- Point pyright at the project's virtualenv so its packages resolve even when
-- nvim wasn't started from an activated shell. An activated env wins, then
-- uv's .venv, then venv, at the project root.
local function find_python(root)
	local candidates = {}
	if vim.env.VIRTUAL_ENV then
		table.insert(candidates, vim.env.VIRTUAL_ENV .. "/bin/python")
	end
	if root then
		table.insert(candidates, root .. "/.venv/bin/python")
		table.insert(candidates, root .. "/venv/bin/python")
	end
	for _, python in ipairs(candidates) do
		if vim.fn.executable(python) == 1 then
			return python
		end
	end
end

---@type vim.lsp.Config
return {
	before_init = function(_, config)
		local python = find_python(config.root_dir)
		if python then
			-- Mutate in place: the client keeps a reference to this settings table.
			config.settings = config.settings or {}
			config.settings.python = config.settings.python or {}
			config.settings.python.pythonPath = python
		end
	end,
}
