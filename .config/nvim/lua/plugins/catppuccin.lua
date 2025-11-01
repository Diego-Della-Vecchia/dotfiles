return {
  "catppuccin/nvim",
  name = "catppuccin",
  opts = {
    transparent_background = true,
    flavour = "frappe",
    integrations = {
      telescope = {
        enabled = true,
      },
      noice = true,
      notify = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd("colorscheme catppuccin")
  end,
}
