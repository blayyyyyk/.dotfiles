return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  opts = {
    left = {
      -- 1. The File Tree
      {
        title = "Nvim Tree",
        ft = "nvim-tree",
        size = { height = 0.5 },
        pinned = true,
      },
      -- 2. The Lazygit Terminal
      {
        title = "Lazygit",
        ft = "terminal",
        size = { height = 0.5 },
        -- This filter ensures ONLY the terminal running lazygit goes here
        filter = function(buf, win)
          return vim.bo[buf].filetype == "terminal" and 
                 string.find(vim.api.nvim_buf_get_name(buf), "lazygit") ~= nil
        end,
        pinned = true,
        -- This 'open' function ensures that if you click the title, it runs the command
        open = "LazyGit", 
      },
    },
  },
}