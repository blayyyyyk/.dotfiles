-- builtin
vim.g.mapleader = " "
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set({ "n", "v", "i" }, "<C-z>", "u")
vim.keymap.set('n', '<M-S-Down>', function()
  require('nvim-treesitter.textobjects.move').goto_next_start('@function.outer')
end, { desc = "Next function" })

vim.keymap.set('n', '<M-S-Up>', function()
  require('nvim-treesitter.textobjects.move').goto_previous_start('@function.outer')
end, { desc = "Previous function" })

-- imported from vscode
vim.keymap.set('n', '<M-Left>', 'b', { desc = 'Move word back' })
vim.keymap.set('n', '<M-Right>', 'w', { desc = 'Move word forward' })
vim.keymap.set('i', '<M-Left>', '<S-Left>', { desc = 'Move word back' })
vim.keymap.set('i', '<M-Right>', '<S-Right>', { desc = 'Move word forward' })
vim.keymap.set('v', '<M-Left>', 'b', { desc = 'Move word back' })
vim.keymap.set('v', '<M-Right>', 'w', { desc = 'Move word forward' })

-- neotree
vim.keymap.set({ "n", "v" }, "<C-b>", ":NvimTreeToggle<CR>")

-- telescope
vim.keymap.set("", "<C-S-f>", "<cmd>Telescope find_files<CR>")
vim.keymap.set("", "<C-S-p>", "<cmd>Telescope<CR>")

-- move.nvim
local opts = { noremap = true, silent = true }
-- Normal-mode commands
vim.keymap.set('n', '<A-Down>', ':MoveLine(1)<CR>', opts)
vim.keymap.set('n', '<A-Up>', ':MoveLine(-1)<CR>', opts)
vim.keymap.set('n', '<A-Left>', ':MoveHChar(-1)<CR>', opts)
vim.keymap.set('n', '<A-Right>', ':MoveHChar(1)<CR>', opts)
vim.keymap.set('n', '<leader>wf', ':MoveWord(1)<CR>', opts)
vim.keymap.set('n', '<leader>wb', ':MoveWord(-1)<CR>', opts)
-- Visual-mode commands
vim.keymap.set('v', '<A-Down>', ':MoveBlock(1)<CR>', opts)
vim.keymap.set('v', '<A-Up>', ':MoveBlock(-1)<CR>', opts)
vim.keymap.set('v', '<A-Left>', ':MoveHBlock(-1)<CR>', opts)
vim.keymap.set('v', '<A-Right>', ':MoveHBlock(1)<CR>', opts)
