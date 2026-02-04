-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/blakemoody/.cache/nvim/packer_hererocks/2.1.1753364724/share/lua/5.1/?.lua;/Users/blakemoody/.cache/nvim/packer_hererocks/2.1.1753364724/share/lua/5.1/?/init.lua;/Users/blakemoody/.cache/nvim/packer_hererocks/2.1.1753364724/lib/luarocks/rocks-5.1/?.lua;/Users/blakemoody/.cache/nvim/packer_hererocks/2.1.1753364724/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/blakemoody/.cache/nvim/packer_hererocks/2.1.1753364724/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  LuaSnip = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  ["everforest-nvim"] = {
    config = { "\27LJ\2\ng\0\0\3\0\6\0\n6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0016\0\3\0009\0\4\0'\2\5\0B\0\2\1K\0\1\0\27colorscheme everforest\bcmd\bvim\nsetup\15everforest\frequire\0" },
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/everforest-nvim",
    url = "https://github.com/neanias/everforest-nvim"
  },
  harpoon = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/harpoon",
    url = "https://github.com/theprimeagen/harpoon"
  },
  ["hover.nvim"] = {
    config = { "\27LJ\2\n3\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\24hover.providers.lsp\frequireÔ\3\1\0\a\0\24\00026\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0=\3\t\2B\0\2\0016\0\n\0009\0\v\0009\0\f\0'\2\r\0'\3\14\0006\4\0\0'\6\1\0B\4\2\0029\4\1\0045\5\15\0B\0\5\0016\0\n\0009\0\v\0009\0\f\0'\2\r\0'\3\16\0006\4\0\0'\6\1\0B\4\2\0029\4\17\0045\5\18\0B\0\5\0016\0\n\0009\0\v\0009\0\f\0'\2\r\0'\3\19\0006\4\0\0'\6\1\0B\4\2\0029\4\20\0045\5\21\0B\0\5\0016\0\n\0009\0\22\0+\1\2\0=\1\23\0K\0\1\0\19mousemoveevent\bopt\1\0\1\tdesc\23hover.nvim (mouse)\16hover_mouse\16<MouseMove>\1\0\1\tdesc\24hover.nvim (select)\17hover_select\agK\1\0\1\tdesc\15hover.nvim\6K\6n\bset\vkeymap\bvim\17preview_opts\1\0\1\vborder\frounded\rpriority\1\0\1\bLSP\3è\a\tinit\1\0\3\tinit\0\17preview_opts\0\rpriority\0\0\nsetup\nhover\frequire\0" },
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/hover.nvim",
    url = "https://github.com/lewis6991/hover.nvim"
  },
  ["lspsaga.nvim"] = {
    config = { "\27LJ\2\nª\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\21symbol_in_winbar\1\0\1\21symbol_in_winbar\0\1\0\5\venable\2\17folder_level\3\2\14separator\n â€º \14show_file\2\17hide_keyword\2\nsetup\flspsaga\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/opt/lspsaga.nvim",
    url = "https://github.com/nvimdev/lspsaga.nvim"
  },
  ["lualine.nvim"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["mason-lspconfig.nvim"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/mason-lspconfig.nvim",
    url = "https://github.com/williamboman/mason-lspconfig.nvim"
  },
  ["mason.nvim"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/mason.nvim",
    url = "https://github.com/williamboman/mason.nvim"
  },
  ["multiple-cursors.nvim"] = {
    config = { "\27LJ\2\nJ\0\0\3\0\4\0\t6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\1K\0\1\0\17NoMatchParen\14set nocul\bcmd\bvimH\0\0\3\0\4\0\t6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\1K\0\1\0\17DoMatchParen\fset cul\bcmd\bvimÍ\4\1\0\a\0\28\0<6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\0023\3\6\0=\3\a\2B\0\2\0015\0\b\0006\1\t\0009\1\n\0019\1\v\0015\3\f\0'\4\r\0'\5\14\0\18\6\0\0B\1\5\0016\1\t\0009\1\n\0019\1\v\0015\3\15\0'\4\16\0'\5\14\0\18\6\0\0B\1\5\0016\1\t\0009\1\n\0019\1\v\0015\3\17\0'\4\18\0'\5\19\0\18\6\0\0B\1\5\0016\1\t\0009\1\n\0019\1\v\0015\3\20\0'\4\21\0'\5\19\0\18\6\0\0B\1\5\0016\1\t\0009\1\n\0019\1\v\0015\3\22\0'\4\23\0'\5\24\0\18\6\0\0B\1\5\0016\1\t\0009\1\n\0019\1\v\0015\3\25\0'\4\26\0'\5\27\0\18\6\0\0B\1\5\1K\0\1\0'<Cmd>MultipleCursorsAddMatches<CR>\14<Leader>a\1\3\0\0\6n\6x+<Cmd>MultipleCursorsMouseAddDelete<CR>\18<C-LeftMouse>\1\3\0\0\6n\6i\v<C-Up>\1\4\0\0\6n\6i\6x\"<Cmd>MultipleCursorsAddUp<CR>\n<C-k>\1\3\0\0\6n\6x\r<C-Down>\1\4\0\0\6n\6i\6x$<Cmd>MultipleCursorsAddDown<CR>\n<C-j>\1\3\0\0\6n\6x\bset\vkeymap\bvim\1\0\1\vsilent\2\14post_hook\0\rpre_hook\1\0\2\14post_hook\0\rpre_hook\0\0\nsetup\21multiple-cursors\frequire\0" },
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/multiple-cursors.nvim",
    url = "https://github.com/brenton-leighton/multiple-cursors.nvim"
  },
  nerdtree = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/nerdtree",
    url = "https://github.com/preservim/nerdtree"
  },
  ["nerdtree-git-plugin"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/nerdtree-git-plugin",
    url = "https://github.com/Xuyuanp/nerdtree-git-plugin"
  },
  ["nowplaying.nvim"] = {
    config = { "\27LJ\2\nñ\5\0\0\t\0\26\0!6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0005\4\t\0=\4\n\3=\3\v\0025\3\r\0005\4\f\0=\4\n\3=\3\14\0025\3\15\0005\4\16\0005\5\17\0006\6\18\0009\6\19\0069\6\20\6'\b\21\0B\6\2\2'\a\22\0&\6\a\6=\6\23\5=\5\24\4=\4\n\3=\3\25\2B\0\2\1K\0\1\0\npanel\fartwork\14cache_dir\21/nowplaying.nvim\ncache\fstdpath\afn\bvim\1\0\5\fenabled\1\nwidth\3\28\14cache_dir\0\vheight\3\14\rdownload\1\1\0\a\16track_title\2\vvolume\2\fartwork\0\nalbum\2\vartist\2\17progress_bar\2\rcontrols\2\1\0\5\fenabled\2\nwidth\0\relements\0\vheight\0\vborder\frounded\15statusline\1\0\3\relements\0\14separator\b - \15max_length\0032\1\0\5\vplayer\2\16status_icon\2\nalbum\2\vartist\2\16track_title\2\vnotify\relements\1\0\5\vplayer\2\16status_icon\2\nalbum\2\vartist\2\16track_title\2\1\0\3\fenabled\1\relements\0\ftimeout\3Ä\19\tpoll\1\0\2\fenabled\2\16interval_ms\3ˆ'\20player_priority\1\0\a\tpoll\0\15statusline\0\14log_level\twarn\20player_priority\0\16auto_switch\2\npanel\0\vnotify\0\1\3\0\0\16apple_music\fspotify\nsetup\vplayer\frequire\0" },
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/nowplaying.nvim",
    url = "https://github.com/diaszsigma/nowplaying.nvim"
  },
  ["nvim-autopairs"] = {
    config = { "\27LJ\2\n@\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\19nvim-autopairs\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/opt/nvim-autopairs",
    url = "https://github.com/windwp/nvim-autopairs"
  },
  ["nvim-cmp"] = {
    config = { "\27LJ\2\nC\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\15lsp_expand\fluasnip\frequire¬\4\1\0\n\0\29\00086\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\6\0005\4\4\0003\5\3\0=\5\5\4=\4\a\0039\4\b\0009\4\t\0049\4\n\0045\6\f\0009\a\b\0009\a\v\a)\tüÿB\a\2\2=\a\r\0069\a\b\0009\a\v\a)\t\4\0B\a\2\2=\a\14\0069\a\b\0009\a\15\aB\a\1\2=\a\16\0069\a\b\0009\a\17\a5\t\18\0B\a\2\2=\a\19\0069\a\b\0009\a\20\aB\a\1\2=\a\21\0069\a\b\0009\a\22\aB\a\1\2=\a\23\6B\4\2\2=\4\b\0039\4\24\0009\4\25\0044\6\3\0005\a\26\0>\a\1\0065\a\27\0>\a\2\0064\a\3\0005\b\28\0>\b\1\aB\4\3\2=\4\25\3B\1\2\1K\0\1\0\1\0\1\tname\vbuffer\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lsp\fsources\vconfig\f<S-Tab>\21select_prev_item\n<Tab>\21select_next_item\t<CR>\1\0\1\vselect\2\fconfirm\14<C-Space>\rcomplete\n<C-f>\n<C-b>\1\0\6\t<CR>\0\f<S-Tab>\0\14<C-Space>\0\n<C-f>\0\n<C-b>\0\n<Tab>\0\16scroll_docs\vinsert\vpreset\fmapping\fsnippet\1\0\3\fsources\0\fsnippet\0\fmapping\0\vexpand\1\0\1\vexpand\0\0\nsetup\bcmp\frequire\0" },
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-lspconfig"] = {
    after = { "lspsaga.nvim" },
    config = { "\27LJ\2\n†\4\0\0\t\0\23\0$6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0016\0\0\0'\2\3\0B\0\2\0029\0\2\0005\2\5\0005\3\4\0=\3\6\2B\0\2\0016\0\0\0'\2\a\0B\0\2\0029\1\b\0009\1\2\0015\3\t\0006\4\n\0=\4\n\0039\4\v\0009\4\f\4'\6\r\0'\a\14\0'\b\15\0B\4\4\2=\4\16\0035\4\20\0005\5\18\0005\6\17\0=\6\19\5=\5\21\4=\4\22\3B\1\2\1K\0\1\0\rsettings\vpython\1\0\1\vpython\0\ranalysis\1\0\1\ranalysis\0\1\0\4\20autoSearchPaths\2\19diagnosticMode\14workspace\21typeCheckingMode\vstrict\27useLibraryCodeForTypes\2\rroot_dir\21requirements.txt\rsetup.py\t.git\17root_pattern\tutil\17capabilities\1\0\3\rroot_dir\0\rsettings\0\17capabilities\0\fpyright\14lspconfig\21ensure_installed\1\0\1\21ensure_installed\0\1\4\0\0\fpyright\nts_ls\vclangd\20mason-lspconfig\nsetup\nmason\frequire\0" },
    loaded = true,
    only_config = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/nvim-tree/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["toggleterm.nvim"] = {
    config = { "\27LJ\2\n8\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\15toggleterm\frequire\0" },
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/toggleterm.nvim",
    url = "https://github.com/akinsho/toggleterm.nvim"
  },
  undotree = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/undotree",
    url = "https://github.com/mbbill/undotree"
  },
  ["vgit.nvim"] = {
    config = { "\27LJ\2\n2\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\tvgit\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/opt/vgit.nvim",
    url = "https://github.com/tanvirtin/vgit.nvim"
  },
  ["vim-devicons"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/vim-devicons",
    url = "https://github.com/ryanoasis/vim-devicons"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/Users/blakemoody/.local/share/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: nvim-cmp
time([[Config for nvim-cmp]], true)
try_loadstring("\27LJ\2\nC\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\15lsp_expand\fluasnip\frequire¬\4\1\0\n\0\29\00086\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\6\0005\4\4\0003\5\3\0=\5\5\4=\4\a\0039\4\b\0009\4\t\0049\4\n\0045\6\f\0009\a\b\0009\a\v\a)\tüÿB\a\2\2=\a\r\0069\a\b\0009\a\v\a)\t\4\0B\a\2\2=\a\14\0069\a\b\0009\a\15\aB\a\1\2=\a\16\0069\a\b\0009\a\17\a5\t\18\0B\a\2\2=\a\19\0069\a\b\0009\a\20\aB\a\1\2=\a\21\0069\a\b\0009\a\22\aB\a\1\2=\a\23\6B\4\2\2=\4\b\0039\4\24\0009\4\25\0044\6\3\0005\a\26\0>\a\1\0065\a\27\0>\a\2\0064\a\3\0005\b\28\0>\b\1\aB\4\3\2=\4\25\3B\1\2\1K\0\1\0\1\0\1\tname\vbuffer\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lsp\fsources\vconfig\f<S-Tab>\21select_prev_item\n<Tab>\21select_next_item\t<CR>\1\0\1\vselect\2\fconfirm\14<C-Space>\rcomplete\n<C-f>\n<C-b>\1\0\6\t<CR>\0\f<S-Tab>\0\14<C-Space>\0\n<C-f>\0\n<C-b>\0\n<Tab>\0\16scroll_docs\vinsert\vpreset\fmapping\fsnippet\1\0\3\fsources\0\fsnippet\0\fmapping\0\vexpand\1\0\1\vexpand\0\0\nsetup\bcmp\frequire\0", "config", "nvim-cmp")
time([[Config for nvim-cmp]], false)
-- Config for: hover.nvim
time([[Config for hover.nvim]], true)
try_loadstring("\27LJ\2\n3\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\24hover.providers.lsp\frequireÔ\3\1\0\a\0\24\00026\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0=\3\t\2B\0\2\0016\0\n\0009\0\v\0009\0\f\0'\2\r\0'\3\14\0006\4\0\0'\6\1\0B\4\2\0029\4\1\0045\5\15\0B\0\5\0016\0\n\0009\0\v\0009\0\f\0'\2\r\0'\3\16\0006\4\0\0'\6\1\0B\4\2\0029\4\17\0045\5\18\0B\0\5\0016\0\n\0009\0\v\0009\0\f\0'\2\r\0'\3\19\0006\4\0\0'\6\1\0B\4\2\0029\4\20\0045\5\21\0B\0\5\0016\0\n\0009\0\22\0+\1\2\0=\1\23\0K\0\1\0\19mousemoveevent\bopt\1\0\1\tdesc\23hover.nvim (mouse)\16hover_mouse\16<MouseMove>\1\0\1\tdesc\24hover.nvim (select)\17hover_select\agK\1\0\1\tdesc\15hover.nvim\6K\6n\bset\vkeymap\bvim\17preview_opts\1\0\1\vborder\frounded\rpriority\1\0\1\bLSP\3è\a\tinit\1\0\3\tinit\0\17preview_opts\0\rpriority\0\0\nsetup\nhover\frequire\0", "config", "hover.nvim")
time([[Config for hover.nvim]], false)
-- Config for: nowplaying.nvim
time([[Config for nowplaying.nvim]], true)
try_loadstring("\27LJ\2\nñ\5\0\0\t\0\26\0!6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0005\4\t\0=\4\n\3=\3\v\0025\3\r\0005\4\f\0=\4\n\3=\3\14\0025\3\15\0005\4\16\0005\5\17\0006\6\18\0009\6\19\0069\6\20\6'\b\21\0B\6\2\2'\a\22\0&\6\a\6=\6\23\5=\5\24\4=\4\n\3=\3\25\2B\0\2\1K\0\1\0\npanel\fartwork\14cache_dir\21/nowplaying.nvim\ncache\fstdpath\afn\bvim\1\0\5\fenabled\1\nwidth\3\28\14cache_dir\0\vheight\3\14\rdownload\1\1\0\a\16track_title\2\vvolume\2\fartwork\0\nalbum\2\vartist\2\17progress_bar\2\rcontrols\2\1\0\5\fenabled\2\nwidth\0\relements\0\vheight\0\vborder\frounded\15statusline\1\0\3\relements\0\14separator\b - \15max_length\0032\1\0\5\vplayer\2\16status_icon\2\nalbum\2\vartist\2\16track_title\2\vnotify\relements\1\0\5\vplayer\2\16status_icon\2\nalbum\2\vartist\2\16track_title\2\1\0\3\fenabled\1\relements\0\ftimeout\3Ä\19\tpoll\1\0\2\fenabled\2\16interval_ms\3ˆ'\20player_priority\1\0\a\tpoll\0\15statusline\0\14log_level\twarn\20player_priority\0\16auto_switch\2\npanel\0\vnotify\0\1\3\0\0\16apple_music\fspotify\nsetup\vplayer\frequire\0", "config", "nowplaying.nvim")
time([[Config for nowplaying.nvim]], false)
-- Config for: toggleterm.nvim
time([[Config for toggleterm.nvim]], true)
try_loadstring("\27LJ\2\n8\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\15toggleterm\frequire\0", "config", "toggleterm.nvim")
time([[Config for toggleterm.nvim]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\n†\4\0\0\t\0\23\0$6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0016\0\0\0'\2\3\0B\0\2\0029\0\2\0005\2\5\0005\3\4\0=\3\6\2B\0\2\0016\0\0\0'\2\a\0B\0\2\0029\1\b\0009\1\2\0015\3\t\0006\4\n\0=\4\n\0039\4\v\0009\4\f\4'\6\r\0'\a\14\0'\b\15\0B\4\4\2=\4\16\0035\4\20\0005\5\18\0005\6\17\0=\6\19\5=\5\21\4=\4\22\3B\1\2\1K\0\1\0\rsettings\vpython\1\0\1\vpython\0\ranalysis\1\0\1\ranalysis\0\1\0\4\20autoSearchPaths\2\19diagnosticMode\14workspace\21typeCheckingMode\vstrict\27useLibraryCodeForTypes\2\rroot_dir\21requirements.txt\rsetup.py\t.git\17root_pattern\tutil\17capabilities\1\0\3\rroot_dir\0\rsettings\0\17capabilities\0\fpyright\14lspconfig\21ensure_installed\1\0\1\21ensure_installed\0\1\4\0\0\fpyright\nts_ls\vclangd\20mason-lspconfig\nsetup\nmason\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: everforest-nvim
time([[Config for everforest-nvim]], true)
try_loadstring("\27LJ\2\ng\0\0\3\0\6\0\n6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0016\0\3\0009\0\4\0'\2\5\0B\0\2\1K\0\1\0\27colorscheme everforest\bcmd\bvim\nsetup\15everforest\frequire\0", "config", "everforest-nvim")
time([[Config for everforest-nvim]], false)
-- Config for: multiple-cursors.nvim
time([[Config for multiple-cursors.nvim]], true)
try_loadstring("\27LJ\2\nJ\0\0\3\0\4\0\t6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\1K\0\1\0\17NoMatchParen\14set nocul\bcmd\bvimH\0\0\3\0\4\0\t6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\1K\0\1\0\17DoMatchParen\fset cul\bcmd\bvimÍ\4\1\0\a\0\28\0<6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\0023\3\6\0=\3\a\2B\0\2\0015\0\b\0006\1\t\0009\1\n\0019\1\v\0015\3\f\0'\4\r\0'\5\14\0\18\6\0\0B\1\5\0016\1\t\0009\1\n\0019\1\v\0015\3\15\0'\4\16\0'\5\14\0\18\6\0\0B\1\5\0016\1\t\0009\1\n\0019\1\v\0015\3\17\0'\4\18\0'\5\19\0\18\6\0\0B\1\5\0016\1\t\0009\1\n\0019\1\v\0015\3\20\0'\4\21\0'\5\19\0\18\6\0\0B\1\5\0016\1\t\0009\1\n\0019\1\v\0015\3\22\0'\4\23\0'\5\24\0\18\6\0\0B\1\5\0016\1\t\0009\1\n\0019\1\v\0015\3\25\0'\4\26\0'\5\27\0\18\6\0\0B\1\5\1K\0\1\0'<Cmd>MultipleCursorsAddMatches<CR>\14<Leader>a\1\3\0\0\6n\6x+<Cmd>MultipleCursorsMouseAddDelete<CR>\18<C-LeftMouse>\1\3\0\0\6n\6i\v<C-Up>\1\4\0\0\6n\6i\6x\"<Cmd>MultipleCursorsAddUp<CR>\n<C-k>\1\3\0\0\6n\6x\r<C-Down>\1\4\0\0\6n\6i\6x$<Cmd>MultipleCursorsAddDown<CR>\n<C-j>\1\3\0\0\6n\6x\bset\vkeymap\bvim\1\0\1\vsilent\2\14post_hook\0\rpre_hook\1\0\2\14post_hook\0\rpre_hook\0\0\nsetup\21multiple-cursors\frequire\0", "config", "multiple-cursors.nvim")
time([[Config for multiple-cursors.nvim]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd lspsaga.nvim ]]

-- Config for: lspsaga.nvim
try_loadstring("\27LJ\2\nª\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\21symbol_in_winbar\1\0\1\21symbol_in_winbar\0\1\0\5\venable\2\17folder_level\3\2\14separator\n â€º \14show_file\2\17hide_keyword\2\nsetup\flspsaga\frequire\0", "config", "lspsaga.nvim")

time([[Sequenced loading]], false)
vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-autopairs'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'vgit.nvim'}, { event = "VimEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
