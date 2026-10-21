local map = vim.keymap.set

-- builtin
map("v", ">", ">gv", { desc = "Indent and keep selection" })
map("v", "<", "<gv", { desc = "Outdent and keep selection" })

-- Map Numpad 0 (NumLock OFF) which is technically the <Insert> key
--vim.keymap.set('n', '<Insert>', 'i', { desc = 'Enter Insert Mode (Insert Key)' })
--vim.keymap.set('i', '<Insert>', '<Esc>', { desc = 'Exit Insert Mode (Insert Key)' })

-- window navigation
map("n", "<M-h>", "<C-w>h", { desc = "Focus left split" })
map("n", "<M-j>", "<C-w>j", { desc = "Focus lower split" })
map("n", "<M-k>", "<C-w>k", { desc = "Focus upper split" })
map("n", "<M-l>", "<C-w>l", { desc = "Focus right split" })
map("n", "<leader>wh", "<C-w>h", { desc = "Focus left split" })
map("n", "<leader>wj", "<C-w>j", { desc = "Focus lower split" })
map("n", "<leader>wk", "<C-w>k", { desc = "Focus upper split" })
map("n", "<leader>wl", "<C-w>l", { desc = "Focus right split" })
map("n", "<leader>wv", "<C-w>v", { desc = "Split editor right" })
map("n", "<leader>ws", "<C-w>s", { desc = "Split editor below" })
map("n", "<leader>wc", "<C-w>c", { desc = "Close current split" })
map({ "n", "v" }, "<C-w>b", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer" })
map({ "n", "v" }, "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Reveal file in explorer" })
map({ "n", "v" }, "<C-o>", "<cmd>Outline<CR>", { desc = "Toggle symbol outline" })

-- telescope
map("n", "<C-l>", "<cmd>Telescope colorscheme<CR>", { desc = "Choose color scheme" })
map("n", "<C-p>", "<cmd>Telescope find_files<CR>", { desc = "Quick open file" })
map("n", "<C-S-p>", "<cmd>Telescope commands<CR>", { desc = "Command palette" })
map("n", "<C-S-f>", "<cmd>Telescope live_grep<CR>", { desc = "Search text in workspace" })
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Find text in workspace" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find open editor" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Search help" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Open recent file" })

map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Show symbol details" })
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map({ "n", "v" }, "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format document or selection" })

map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostics list" })

map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Open LazyGit" })
-- Normal mode only: a terminal-mode <Space> mapping makes every space typed in
-- the terminal wait for 'timeoutlen'. Ctrl-\ toggles from inside the terminal.
map("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
map("n", "<leader>uF", "<cmd>FormatToggle<CR>", { desc = "Toggle format on save" })

-- Neovim 0.11+ maps grn/gra/grr/gri/grt by default, which makes `gr`
-- (references, above) wait for 'timeoutlen'. <Space>rn and <Space>ca cover
-- rename and code actions.
for _, mode in ipairs({ "n", "x" }) do
	for _, keymap in ipairs(vim.api.nvim_get_keymap(mode)) do
		if keymap.lhs:match("^gr.$") then
			pcall(vim.keymap.del, mode, keymap.lhs)
		end
	end
end

map("n", "<A-Down>", "<cmd>MoveLine(1)<CR>", { desc = "Move line down" })
map("n", "<A-Up>", "<cmd>MoveLine(-1)<CR>", { desc = "Move line up" })
map("v", "<A-Down>", ":MoveBlock(1)<CR>", { desc = "Move selection down" })
map("v", "<A-Up>", ":MoveBlock(-1)<CR>", { desc = "Move selection up" })
