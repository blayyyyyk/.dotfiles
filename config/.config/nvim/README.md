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
Versions are pinned in `lazy-lock.json`; a new machine installs exactly those commits.

### 2 Keymaps
Custom keymaps I've set are in `nvim/lua/config/remap.lua`. A lot of them are inspired from vscode.
Format on save is on; `Space u F` (or `:FormatToggle`) turns it off for the session.

### 3 Language servers, formatters and parsers
Everything the config expects is listed once in `nvim/lua/config/tools.lua`:
language servers (by [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/tree/master/lsp)
name), Mason tools (formatters, linters, the tree-sitter CLI) and tree-sitter parsers.
Mason installs the servers and tools on first start, nvim-treesitter installs the
parsers, and other languages' parsers install the first time you open such a file.

Per-server settings come from nvim-lspconfig. Local overrides go in
`nvim/after/lsp/<server>.lua`; for example `after/lsp/pyright.lua` points pyright at the
project's `.venv` so its packages resolve even when nvim wasn't started from an
activated shell.

##### 3.1 Adding a language
1. Add the server to `M.servers` in `lua/config/tools.lua` (and a formatter to
   `M.tools` plus `lua/plugins/conform.nvim.lua`, and the parser to `M.parsers`).
2. Run `~/.dotfiles/scripts/nvim-doctor.sh`. It installs the new pieces and checks them.

### 4 Keeping it working
Neovim 0.12+ is required (nvim-treesitter's `main` branch needs it); older versions start
with plugins disabled instead of erroring.

| Command | What it does |
| --- | --- |
| `:checkhealth config` | Quick check: every plugin, server, tool, formatter and parser is installed |
| `:ConfigDoctor` | The quick check plus a smoke test: opens real files and confirms each server attaches and reports diagnostics, each formatter formats, and tree-sitter highlights |
| `:ConfigSync` / `:ConfigSync!` | Install anything missing (`!` first resets plugins to `lazy-lock.json`) |
| `~/.dotfiles/scripts/nvim-doctor.sh` | Sync, then run the doctor headless; exits non-zero on any failure |
| `~/.dotfiles/scripts/nvim-update.sh` | Update plugins and parsers, keep the update only if the doctor passes, otherwise roll `lazy-lock.json` back |

CI runs `setup.sh --ci` (which ends with the doctor) on fresh macOS and Ubuntu machines on
every push and weekly, so a lockfile bump that breaks something fails there first.
