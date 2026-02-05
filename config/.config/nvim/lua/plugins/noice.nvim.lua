return {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
        cmdline = {
            view = "cmdline_popup",  -- This centers it
        },
        popupmenu = {
            backend = "cmp",         -- Tells Noice to use cmp for the menu
        },
    },
    dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        "hrsh7th/nvim-cmp",         -- Completion engine
        "rcarriga/nvim-notify",
    }
}