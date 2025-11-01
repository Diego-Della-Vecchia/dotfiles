return {
    "lewis6991/hover.nvim",
    event = "BufReadPost", -- load after a buffer is opened
    config = function()
        require("hover").setup({
            init = function()
                -- Require providers
                require("hover.providers.lsp")  -- lsp hover
                -- You can also enable other providers like markdown, man, etc.
            end,
            preview_opts = {
                border = nil, -- 'single', 'rounded', 'double', 'shadow', or nil
                max_width = 80,
            },
            -- Whether the hover window gets closed when moving the cursor
            quit_on_move = true,
        })

        -- Keymaps
        vim.keymap.set("n", "K", require("hover").hover, { desc = "Hover" })
        vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "Hover select" })
    end,
}
