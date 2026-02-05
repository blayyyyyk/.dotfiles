return {'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function()
        vim.g.barbar_auto_setup = false
        
    end,
    opts = {
        -- Use the default values: {event = 'BufWinLeave', text = '', align = 'left'}
        sidebar_filetypes = {
            NvimTree = true,
            Outline = {event = 'BufWinLeave', text = 'symbols-outline', align = 'right'},
        },
        icons = {
            separator = { left = '┃', right = ' ' }   
        },
        
      },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
}