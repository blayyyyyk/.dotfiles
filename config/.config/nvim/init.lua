-- file: init.lua

-- plugin manager
require("config.lazy")
require("config.remap")

-- language servers
vim.lsp.enable({
    'pyright',
    'clangd',
    'lua_ls',
})

-- builtin vim config
vim.cmd('source ~/.config/nvim/config.vim')
-- -- 5A524C

vim.opt.fillchars = {
  horiz     = '━',
  horizup   = '┻',
  horizdown = '┳',
  vert      = '┃',
  vertleft  = '┫',
  vertright = '┣',
  verthoriz = '╋',
}

-- This adds a thin underline to the entire tab bar area
vim.api.nvim_set_hl(0, 'TabLineFill', { bg = 'NONE', underline = true })