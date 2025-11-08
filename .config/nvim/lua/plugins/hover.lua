return {
  "lewis6991/hover.nvim",
  event = "BufReadPost", -- load after a buffer is opened
  config = function()
    require("hover").config({
      providers = {
        "hover.providers.diagnostic",
        "hover.providers.lsp",
        "hover.providers.man",
      },
      mouse_providers = {
        "hover.providers.lsp",
      },
      preview_opts = {
        border = nil, -- 'single', 'rounded', 'double', 'shadow', or nil
        max_width = 80,
      },
      -- Whether the hover window gets closed when moving the cursor
      quit_on_move = true,
    })

    -- Keymaps
    vim.keymap.set("n", "K", require("hover").open, { desc = "Hover" })
    vim.keymap.set("n", "gK", require("hover").select, { desc = "Hover select" })
  end,
}
