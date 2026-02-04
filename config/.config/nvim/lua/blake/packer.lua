-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'


	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.8',
		-- or                            , branch = '0.1.x',
		requires = { {'nvim-lua/plenary.nvim'} }
	}
	use({
		"neanias/everforest-nvim",
		-- Optional; default configuration will be used if setup isn't called.
		config = function()
			require("everforest").setup()
			vim.cmd("colorscheme everforest")
		end,
	})

	use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
	use('theprimeagen/harpoon')
	use('mbbill/undotree')
	use('tpope/vim-fugitive')
	use('preservim/nerdtree')
	use({"akinsho/toggleterm.nvim", tag = '*', config = function()
	  require("toggleterm").setup()
	end})
	use({
	    "brenton-leighton/multiple-cursors.nvim",
	    config = function()
		require("multiple-cursors").setup({
		    pre_hook = function()
			vim.cmd("set nocul")
			vim.cmd("NoMatchParen")
		    end,
		    post_hook = function()
			vim.cmd("set cul")
			vim.cmd("DoMatchParen")
		    end,
		})

		-- Keybinds (VS Code Style)
		local opts = { silent = true }
		
		-- Add Down
		vim.keymap.set({"n", "x"}, "<C-j>", "<Cmd>MultipleCursorsAddDown<CR>", opts)
		vim.keymap.set({"n", "i", "x"}, "<C-Down>", "<Cmd>MultipleCursorsAddDown<CR>", opts)
		
		-- Add Up
		vim.keymap.set({"n", "x"}, "<C-k>", "<Cmd>MultipleCursorsAddUp<CR>", opts)
		vim.keymap.set({"n", "i", "x"}, "<C-Up>", "<Cmd>MultipleCursorsAddUp<CR>", opts)
		
		-- Mouse Support
		vim.keymap.set({"n", "i"}, "<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>", opts)
		
		-- Add Matches (Word under cursor)
		vim.keymap.set({"n", "x"}, "<Leader>a", "<Cmd>MultipleCursorsAddMatches<CR>", opts)
	    end
    	})
	use({
	    "neovim/nvim-lspconfig",
	    requires = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	    },
	    config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
			    -- Add the servers you need (e.g., pyright for your Python ML projects)
			    ensure_installed = { "pyright", "ts_ls", "clangd" } 
			})

			local lspconfig = require('lspconfig')

			-- Example: Setting up Python (Pyright)
			lspconfig.pyright.setup({
			    capabilities = capabilities,
			    root_dir = lspconfig.util.root_pattern(".git", "setup.py", "requirements.txt"),
			    settings = {
				python = {
				    analysis = {
					-- Options are: "off", "basic", "strict"
					typeCheckingMode = "strict", 
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "workspace", -- Checks all files, not just open ones
				    },
				},
			    },
			})
		end
	})
	use({
	    "lewis6991/hover.nvim",
	    config = function()
    		require("hover").setup({
    		    init = function()
    			-- Require providers you want
    			require("hover.providers.lsp")
    			-- require("hover.providers.gh")
    			-- require("hover.providers.man")
    			-- require("hover.providers.dictionary")
    		    end,
    		    priority = {
    			['LSP'] = 1000
    		    },
    		    preview_opts = {
    			border = 'rounded'
    		    },
    		    
    		})
    
    		-- Setup keymaps
    		-- This replaces the default 'K' behavior with hover.nvim
    		vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim"})
    		vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})
    
    		-- Mouse support (if your iTerm2 mouse reporting is on)
    		vim.keymap.set("n", "<MouseMove>", require("hover").hover_mouse, {desc = "hover.nvim (mouse)"})
    		vim.opt.mousemoveevent = true
		end
	})
	use({
	    "hrsh7th/nvim-cmp",
	    requires = {
		"hrsh7th/cmp-nvim-lsp",     -- Tells cmp how to get data from your LSP
		"hrsh7th/cmp-buffer",       -- Suggestions from current file
		"hrsh7th/cmp-path",         -- Suggestions for file paths
		"L3MON4D3/LuaSnip",         -- Snippet engine
		"saadparwaiz1/cmp_luasnip", -- Snippet completions
	    },
	    config = function()
		local cmp = require("cmp")
		cmp.setup({
		    snippet = {
			expand = function(args)
			    require("luasnip").lsp_expand(args.body)
			end,
		    },
		    mapping = cmp.mapping.preset.insert({
			['<C-b>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			['<C-Space>'] = cmp.mapping.complete(), -- Trigger manual completion
			['<CR>'] = cmp.mapping.confirm({ select = true }), -- 'Enter' to select
			['<Tab>'] = cmp.mapping.select_next_item(),
			['<S-Tab>'] = cmp.mapping.select_prev_item(),
		    }),
		    sources = cmp.config.sources({
			{ name = 'nvim_lsp' }, -- This brings in your type hints
			{ name = 'luasnip' },
		    }, {
			{ name = 'buffer' },
		    })
		})
	    end
	})
	use({
	  'tanvirtin/vgit.nvim',
	  requires = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons' },
	  -- Lazy loading on 'VimEnter' event is necessary.
	  event = 'VimEnter',
	  config = function() require("vgit").setup() end,
	})
	use({
	    "windwp/nvim-autopairs",
	    event = "InsertEnter",
	    config = function()
		require("nvim-autopairs").setup {}
	    end
	})
	use('Xuyuanp/nerdtree-git-plugin')
	use('ryanoasis/vim-devicons')
	use({
	    "nvimdev/lspsaga.nvim",
	    after = "nvim-lspconfig",
	    config = function()
		require("lspsaga").setup({
		    symbol_in_winbar = {
			enable = true, -- This enables the breadcrumbs
			separator = " › ",
			hide_keyword = true,
			show_file = true,
			folder_level = 2,
		    },
		})
	    end,
	})
	use({
	    "akinsho/toggleterm.nvim",
	    tag = '*',
	    config = function()
		require("toggleterm").setup({
		    size = 80, -- Width of the vertical split
		    open_mapping = [[<C-j>]], -- The shortcut to toggle
		    direction = 'vertical',
		})
	    end
	})
	use({
	  'nvim-lualine/lualine.nvim',
	  requires = { 'nvim-tree/nvim-web-devicons', opt = true }
	})
end)
