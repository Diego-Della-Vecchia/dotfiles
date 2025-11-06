return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  opts = {
    preset = "modern",
    options = {
      show_sources = {
        enabled = true,
      },
      multilines = {
        enabled = true,
      },
    },
  },
  config = function(_, opts)
    require("tiny-inline-diagnostic").setup(opts)
    vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
  end,
}
