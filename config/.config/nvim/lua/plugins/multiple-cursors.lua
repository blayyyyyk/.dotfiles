return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
        local mc = require("multicursor-nvim")
        mc.setup()

        local set = vim.keymap.set

        -- =================================================================
        -- 1. Triggers (Always Active)
        -- =================================================================
        -- Add cursor above/below (Mapped to Ctrl + Up/Down to match VS Code feel)
        set({"n", "x"}, "<C-A-Up>", function() mc.lineAddCursor(-1) end, { desc = "Add cursor up" })
        set({"n", "x"}, "<C-A-Down>", function() mc.lineAddCursor(1) end, { desc = "Add cursor down" })
        
        -- Add cursor by matching word (Ctrl + D behavior)
        set({"n", "x"}, "<C-d>", function() mc.matchAddCursor(1) end, { desc = "Add next match" })
        set({"n", "x"}, "<C-S-d>", function() mc.matchSkipCursor(1) end, { desc = "Skip next match" })
        
        -- Mouse support
        set("n", "<A-LeftMouse>", mc.handleMouse)
        set("n", "<A-LeftDrag>", mc.handleMouseDrag)
        set("n", "<A-LeftRelease>", mc.handleMouseRelease)

        -- Align cursors (Optional but very useful)
        set({"n", "x"}, "<leader>a", mc.alignCursors, { desc = "Align cursors" })

        -- =================================================================
        -- 2. The "Multi-Cursor Layer" (VS Code Overrides)
        -- These keys ONLY active when you have multiple cursors
        -- =================================================================
        mc.addKeymapLayer(function(layerSet)
            
            -- ESCAPE: Clear cursors (Single press escapes multi-mode)
            layerSet("n", "<Esc>", function()
                if not mc.cursorsEnabled() then
                    mc.enableCursors()
                elseif mc.hasCursors() then
                    mc.clearCursors()
                else
                    -- Default Esc behavior if no cursors
                    vim.cmd("noh") 
                end
            end)

            -- -----------------------------------------------------------
            -- VS Code Navigation (Ctrl/Alt + Arrows)
            -- -----------------------------------------------------------
            -- Alt + Left/Right: Jump by word
            layerSet({"n", "x"}, "<M-Right>", "w")
            layerSet({"n", "x"}, "<M-Left>", "b")

            -- Ctrl + Left/Right: Jump to Start/End of line
            layerSet({"n", "x"}, "<C-Right>", "$")
            layerSet({"n", "x"}, "<C-Left>", "0")

            -- -----------------------------------------------------------
            -- VS Code Selection (Shift + Arrows)
            -- -----------------------------------------------------------
            -- Normal Mode: Shift+Arrow starts selection
            layerSet("n", "<S-Right>", "vl")
            layerSet("n", "<S-Left>", "vh")
            layerSet("n", "<S-Up>", "vk")
            layerSet("n", "<S-Down>", "vj")

            -- Visual Mode: Shift+Arrow extends selection
            layerSet("x", "<S-Right>", "l")
            layerSet("x", "<S-Left>", "h")
            layerSet("x", "<S-Up>", "k")
            layerSet("x", "<S-Down>", "j")

            -- -----------------------------------------------------------
            -- VS Code Word/Line Selection (Shift + Ctrl/Alt + Arrows)
            -- -----------------------------------------------------------
            -- Shift + Alt + Right: Select Word
            layerSet("n", "<M-S-Right>", "vw")
            layerSet("n", "<M-S-Left>", "vb")
            layerSet("x", "<M-S-Right>", "w")
            layerSet("x", "<M-S-Left>", "b")

            -- Shift + Ctrl + Right: Select to End of Line
            layerSet("n", "<C-S-Right>", "v$")
            layerSet("n", "<C-S-Left>", "v0")
            layerSet("x", "<C-S-Right>", "$")
            layerSet("x", "<C-S-Left>", "0")

            -- -----------------------------------------------------------
            -- Editing & Clipboard
            -- -----------------------------------------------------------
            -- Backspace/Delete deletes text (black hole register)
            layerSet({"n", "x"}, "<BS>", '"_d')
            layerSet({"n", "x"}, "<Del>", '"_d')
            
            -- Standard Cut/Copy/Paste
            layerSet("x", "<C-c>", '"+y')
            layerSet("x", "<C-x>", '"+x')
            layerSet({"n", "x"}, "<C-v>", '"+p')

        end)

        -- Customize highlights to match Gruvbox (optional)
        local hl = vim.api.nvim_set_hl
        hl(0, "MultiCursorCursor", { link = "Cursor" })
        hl(0, "MultiCursorVisual", { link = "Visual" })
        hl(0, "MultiCursorSign", { link = "SignColumn"})
        hl(0, "MultiCursorMatchPreview", { link = "Search" })
        hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
        hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    end
}
