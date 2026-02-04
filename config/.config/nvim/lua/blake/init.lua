vim.cmd('source ~/.config/.vimrc')
vim.lsp.enable('pyright')
require("blake.packer")
require("blake.remap")
vim.cmd("source ~/.config/nvim/remap.vim")
vim.diagnostic.config({
    virtual_text = true, -- Shows the error message next to the code
    signs = true,        -- Shows an 'E' or icon in the gutter
    underline = true,    -- The red underline you're looking for
    update_in_insert = false, -- Wait until you leave insert mode to show errors (less distracting)
    severity_sort = true,
})
