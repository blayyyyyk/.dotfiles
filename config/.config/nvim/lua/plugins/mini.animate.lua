return {
  "echasnovski/mini.animate",
  version = "*",
  event = "VeryLazy",
  opts = function()
    -- Don't use animate when scrolling with the mouse
    local mouse_scrolled = false
    for _, scroll in ipairs({ "Up", "Down" }) do
      local key = "<ScrollWheel" .. scroll .. ">"
      vim.keymap.set({ "", "i" }, key, function()
        mouse_scrolled = true
        return key
      end, { expr = true })
    end

    return {
      -- Cursor movement options
      cursor = {
        enable = true, -- Enable cursor animation
        timing = require("mini.animate").gen_timing.linear({ duration = 50, unit = "total" }), -- Fast, linear movement (feels snappier)
      },
      
      -- Scrolling options
      scroll = {
        enable = true,
        -- Stop the animation if we are using the mouse scroll wheel (avoids "fighting" the scroll)
        subscroll = require("mini.animate").gen_subscroll.equal({
          predicate = function(total_scroll)
            if mouse_scrolled then
              mouse_scrolled = false
              return false
            end
            return total_scroll > 1
          end,
        }),
      },

      -- Resize options (smooth window resizing)
      resize = { enable = true },
    }
  end,
}
