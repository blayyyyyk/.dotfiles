return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function()
        require("nvim-treesitter.configs").setup({
            -- Ensure these parsers are installed
            ensure_installed = { "lua", "python", "vim", "vimdoc", "javascript" },
            
            highlight = {
                enable = true, -- THIS is what gives you the colors
            },
        })
    end,
}