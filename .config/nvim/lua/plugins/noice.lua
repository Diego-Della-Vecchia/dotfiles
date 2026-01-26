return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {},
  config = function(_, opts)
    -- Get Catppuccin background from the Normal highlight
    local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
    local notify_bg = normal_hl and normal_hl.bg
    local background_colour = notify_bg and string.format("#%06x", notify_bg) or "#000000"

    -- Setup nvim-notify with proper background
    require("notify").setup({
      background_colour = background_colour,
      render = "compact",
      merge_duplicates = true,
      top_down = false,
    })

    -- Setup noice
    require("noice").setup(opts)
  end,
}
