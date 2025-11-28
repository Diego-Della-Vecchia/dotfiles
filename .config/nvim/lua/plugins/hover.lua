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
      select_providers = {
        "hover.providers.diagnostic",
        "hover.providers.lsp",
        "hover.providers.man",
      },
      mouse_providers = {
        "hover.providers.lsp",
      },
      preview_opts = {
        border = "rounded", -- 'single', 'rounded', 'double', 'shadow', or nil
        max_width = 80,
      },
      quit_on_move = true,
    })

    -- Keymaps
    vim.keymap.set("n", "K", require("hover").open, { desc = "Hover" })
    vim.keymap.set("n", "gK", require("hover").enter, { desc = "Hover select" })
  end,
}
