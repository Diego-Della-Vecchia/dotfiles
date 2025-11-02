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

    -- Additional customization for Telescope transparency
    vim.cmd([[
      " Make Telescope background transparent
      hi TelescopeNormal guibg=NONE ctermbg=NONE
      hi TelescopeBorder guibg=NONE ctermbg=NONE
      hi TelescopePromptNormal guibg=NONE ctermbg=NONE
      hi TelescopePromptBorder guibg=NONE ctermbg=NONE
      hi TelescopePreviewNormal guibg=NONE ctermbg=NONE
      hi TelescopePreviewBorder guibg=NONE ctermbg=NONE
      hi TelescopeResultsNormal guibg=NONE ctermbg=NONE
      hi TelescopeResultsBorder guibg=NONE ctermbg=NONE
    ]])

    -- Make floating windows and tabline transparent
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
  end,
}
