-- Accept suggestions switch from tab to alt+tab
vim.keymap.set('i', '<A-Tab>', 'copilot#Accept("\\<CR>")', {
  	expr = true,
  	replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

