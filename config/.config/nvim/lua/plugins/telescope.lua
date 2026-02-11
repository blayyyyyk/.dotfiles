return {
    	'nvim-telescope/telescope.nvim', version = '*',
    	dependencies = {
        'nvim-lua/plenary.nvim',
        "MaximilianLloyd/ascii.nvim",
        	-- optional but recommended
        	{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    	},
	config = function()
        local telescope = require('telescope')
		telescope.setup({
		        pickers = {
				colorscheme = {
					enable_preview = true,
					theme = "dropdown"
				},
			},
        })
		telescope.load_extension("ascii")
	end
}
