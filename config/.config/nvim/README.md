# Neovim Configuration

This is a terminal IDE built on Lazy.nvim. It keeps the existing Gruvbox Material
visual language and plugins while making common workflows discoverable to a VS
Code user. Press `Space ?` at any time to browse the configured shortcuts.

## VS Code workflow guide

`Space` is the leader key. Mouse support is enabled in every mode: click to
place the cursor or focus a split, drag to select, scroll normally, click a
bufferline tab to switch files, and click its close icon to close that buffer.

| Task | Keyboard | Mouse / discoverable path |
| --- | --- | --- |
| File explorer | `Ctrl-b` or `Space e` | Double-click an nvim-tree item to open it; press `g?` in the tree for available actions |
| Reveal current file | `Space e f` | Open the explorer, then navigate the highlighted file |
| Quick open | `Ctrl-p` or `Space f f` | `Space ?` → Find → Find files |
| Search workspace | `Ctrl-Shift-f` or `Space f g` | `Space ?` → Find → Find text in workspace |
| Command palette | `Ctrl-Shift-p` | Telescope lists available commands |
| Symbols / outline | `Ctrl-o` or `Space o` | Click the outline window to focus it, then select a symbol |
| Definition / references | `g d` / `g r` | Put the cursor on a symbol, then use `Space ?` to discover related actions |
| Hover details | `K` | Shows the same LSP detail used by editor hover UI |
| Code action | `Space c a` | `Space ?` → Code → Code actions |
| Rename symbol | `Space r n` | `Space ?` → Refactor → Rename symbol |
| Format | `Space c f` | Formats the document or visual selection, with LSP fallback |
| Diagnostics | `[ d`, `] d`, `Space d d`, `Space d q` | Signs stay visible; click the target line and use `Space d d` for details |
| Git | `Space g g` | Opens the installed LazyGit interface |
| Terminal | `Ctrl-\\`, `Space t t`, or `Space t f` | Opens horizontal or floating ToggleTerm terminals |
| Split editor | `Space w v` / `Space w s` | Click a split to focus it; `Alt-h/j/k/l` or `Space w h/j/k/l` also moves focus |
| Open buffers | `Space f b` | Click bufferline tabs across the top |
| Minimap | `Space u m` / `Space u f` | Click the minimap to jump; toggle focus when keyboard navigation is needed |

In Telescope pickers, type to filter, use arrow keys or `Ctrl-j` / `Ctrl-k` to
move, press `Enter` to open, and press `Esc` to close. In the terminal, press
`Ctrl-\\` to hide it and return to the editor.

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
