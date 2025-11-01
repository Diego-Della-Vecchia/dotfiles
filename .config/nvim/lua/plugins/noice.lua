return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {},
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  config = function(_, opts)
    -- Get Catppuccin background from the Normal highlight
    local notify_bg = vim.api.nvim_get_hl_by_name("Normal", true).background
    local background_colour = notify_bg and string.format("#%06x", notify_bg) or "#000000"

    -- Setup nvim-notify with proper background
    require("notify").setup({
      background_colour = background_colour,
    })

    -- Setup noice
    require("noice").setup(opts)
  end,
}
