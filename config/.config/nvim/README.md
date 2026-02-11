# Neovim Configuration

### 1 Plugins
Plugin configurations are located in `nvim/lua/plugins`. Each plugin config corresponds to its lua file.

### 2 Keymaps
Custom keymaps I've set are in `nvim/lua/config/remap.lua`. A lot of them are inspired from vscode.

### 3 Language Servers
Language server configurations are located in `nvim/lua/lsp`. The server config corresponds to its `.lua` file. If no config is provided, I'm unsure if this will error in neovim but you can go here for [default configs](https://github.com/neovim/nvim-lspconfig/tree/master/lsp).

##### 3.1 Adding an LSP
Make sure when you add an LSP you add it to the list in `nvim/init.lua`.
```lua
-- file: init.lua

-- plugin manager
require("config.lazy")
require("config.remap")

-- language servers
vim.lsp.enable({
    'pyright',
    'clangd',
    'lua_ls', -- <- add it under here
})

-- builtin vim config
vim.cmd('source ~/.config/nvim/config.vim')
```
