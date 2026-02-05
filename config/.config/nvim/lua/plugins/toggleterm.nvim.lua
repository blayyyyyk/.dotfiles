return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<c-\>]], -- This is the global toggle key
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,   -- whether or not the open mapping applies in insert mode
      terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
      persist_size = true,
      direction = 'horizontal', -- options: 'vertical', 'horizontal', 'tab', 'float'
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = 'rounded',     -- matches your stylistic hover/noice theme
        winblend = 3,
      },
    })

    -- Optional: Custom keymap for a floating terminal
    local Terminal = require('toggleterm.terminal').Terminal
    local float_term = Terminal:new({ direction = "float" })

    function _G._toggle_float_term()
      float_term:toggle()
    end

    vim.keymap.set("n", "<leader>tf", "<cmd>lua _toggle_float_term()<CR>", { desc = "Toggle Floating Terminal" })
  end
}