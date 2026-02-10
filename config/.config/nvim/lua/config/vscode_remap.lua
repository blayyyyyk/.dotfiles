vim.keymap.set("n", "<M-Left>", "b", { desc = "Move word back" })
vim.keymap.set("n", "<M-Right>", "w", { desc = "Move word forward" })
vim.keymap.set("i", "<A-Left>", "<S-Left>", { desc = "Move word back" })
vim.keymap.set("i", "<A-Right>", "<S-Right>", { desc = "Move word forward" })
vim.keymap.set("v", "<M-Left>", "b", { desc = "Move word back" })
vim.keymap.set("n", "<C-Right>", "$", { desc = "Move to end of line" })
vim.keymap.set("v", "<M-Right>", "w", { desc = "Move word forward" })
vim.keymap.set("i", "<C-Right>", "<End>", { desc = "Move to end of line" })
vim.keymap.set("n", "<C-Left>", "0", { desc = "Move to beginning of line" })
vim.keymap.set({ "v", "n" }, "<C-Right>", "$", { desc = "Move to end of line" })
vim.keymap.set("i", "<C-Left>", "<Home>", { desc = "Move to beginning of line" })
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
vim.keymap.set({ "v", "n" }, "<C-Left>", "0", { desc = "Move to beginning of line" })
vim.keymap.set("n", "<C-v>", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set("i", "<C-v>", '<Esc>"+pa', { desc = "Paste from clipboard" })
vim.keymap.set("n", "<C-x>", '"+x', { desc = "Cut to clipboard" })
vim.keymap.set("v", "<C-v>", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set("v", "<C-x>", '"+x', { desc = "Cut to clipboard" })
vim.keymap.set("v", "<BS>", '"_d', { desc = "Delete without yanking" })

-- Normal Mode: Enter Visual Mode and move
vim.keymap.set("n", "<S-Up>", "v<Up>", { desc = "Select Up" })
vim.keymap.set("n", "<S-Down>", "v<Down>", { desc = "Select Down" })
vim.keymap.set("n", "<S-Left>", "vh", { desc = "Select Left" })
vim.keymap.set("n", "<S-Right>", "vl", { desc = "Select Right" })

-- Visual Mode: Extend selection (just move)
vim.keymap.set("v", "<S-Up>", "<Up>", { desc = "Extend Up" })
vim.keymap.set("v", "<S-Down>", "<Down>", { desc = "Extend Down" })
vim.keymap.set("v", "<S-Left>", "<Left>", { desc = "Extend Left" })
vim.keymap.set("v", "<S-Right>", "<Right>", { desc = "Extend Right" })

-- Insert Mode: Exit insert, enter visual, select, then wait
-- (Note: This is tricky in Vim. Usually, it's cleaner to exit to Normal mode first,
-- but this mimics the immediate selection)
vim.keymap.set("i", "<S-Up>", "<Esc>v<Up>", { desc = "Select Up" })
vim.keymap.set("i", "<S-Down>", "<Esc>v<Down>", { desc = "Select Down" })
vim.keymap.set("i", "<S-Left>", "<Esc>vh", { desc = "Select Left" })
vim.keymap.set("i", "<S-Right>", "<Esc>vl", { desc = "Select Right" })

-- Normal Mode: Start word selection
vim.keymap.set("n", "<M-S-Right>", "vw", { desc = "Select word forward" })
vim.keymap.set("n", "<M-S-Left>", "vb", { desc = "Select word back" })

-- Visual Mode: Extend word selection
vim.keymap.set("v", "<M-S-Right>", "w", { desc = "Extend word forward" })
vim.keymap.set("v", "<M-S-Left>", "b", { desc = "Extend word back" })

-- Insert Mode: Drop to visual and select word
vim.keymap.set("i", "<M-S-Right>", "<Esc>vw", { desc = "Select word forward" })
vim.keymap.set("i", "<M-S-Left>", "<Esc>vb", { desc = "Select word back" })

-- Normal Mode: Select to Start/End of line
vim.keymap.set("n", "<C-S-Right>", "v$", { desc = "Select to end of line" })
vim.keymap.set("n", "<C-S-Left>", "v0", { desc = "Select to start of line" })

-- Visual Mode: Extend to Start/End of line
vim.keymap.set("v", "<C-S-Right>", "$", { desc = "Extend to end of line" })
vim.keymap.set("v", "<C-S-Left>", "0", { desc = "Extend to start of line" })

-- Insert Mode
vim.keymap.set("i", "<C-S-Right>", "<Esc>v$", { desc = "Select to end of line" })
vim.keymap.set("i", "<C-S-Left>", "<Esc>v0", { desc = "Select to start of line" })

-- Select All (Ctrl + A)
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select All" })
vim.keymap.set("i", "<C-a>", "<Esc>ggVG", { desc = "Select All" })

-- Undo (Ctrl + Z)
vim.keymap.set("n", "<C-z>", "u", { desc = "Undo" })
vim.keymap.set("i", "<C-z>", "<Esc>ui", { desc = "Undo" })

-- Redo (Ctrl + Y or Ctrl + Shift + Z)
vim.keymap.set("n", "<C-S-z>", "<C-r>", { desc = "Redo" })
vim.keymap.set("i", "<C-S-z>", "<Esc><C-r>i", { desc = "Redo" })
-- Note: <C-S-z> often sends the same code as <C-z> in some terminals.
-- If it doesn't work, stick to <C-y>
