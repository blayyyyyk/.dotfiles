return {
    'nvimdev/lspsaga.nvim',
    config = function()
        require("lspsaga").setup({
		    symbol_in_winbar = {
    			enable = true, -- This enables the breadcrumbs
    			separator = " › ",
    			hide_keyword = true,
    			show_file = true,
    			folder_level = 2,
            },
            ui = {
                border = 'rounded',
                devicon = true,
            },
            hover = {
                max_width = 0.6,
                open_link = 'gx',
            }
		})
    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    }
}