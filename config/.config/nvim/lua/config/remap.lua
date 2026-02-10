-- builtin
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

-- Map Numpad 0 (NumLock OFF) which is technically the <Insert> key
--vim.keymap.set('n', '<Insert>', 'i', { desc = 'Enter Insert Mode (Insert Key)' })
--vim.keymap.set('i', '<Insert>', '<Esc>', { desc = 'Exit Insert Mode (Insert Key)' })

-- window navigation
vim.keymap.set("n", "<M-w", "<C-w>h")
vim.keymap.set("n", "<M-w", "<C-w>j")
vim.keymap.set("n", "<M-w", "<C-w>k")
vim.keymap.set("n", "<M-w", "<C-w>l")
vim.keymap.set({ "n", "v" }, "<C-w>b", ":NvimTreeFocus<CR>")
vim.keymap.set({ "n", "v" }, "<C-b>", ":NvimTreeToggle<CR>")
vim.keymap.set({ "n", "v" }, "<C-o>", ":Outline<CR>")

-- telescope
vim.keymap.set("n", "<C-l>", ":Telescope colorscheme<CR>")
vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>")
vim.keymap.set("n", "<C-S-p>", ":Telescope<CR>")
vim.keymap.set("n", "<A-Down>", ":MoveLine(1)<CR>")
vim.keymap.set("n", "<A-Up>", ":MoveLine(-1)<CR>")
vim.keymap.set("v", "<A-Down>", ":MoveBlock(1)<CR>")
vim.keymap.set("v", "<A-Up>", ":MoveBlock(-1)<CR>")
