return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    transparent_background = true,
    flavour = "frappe",
    integrations = {
      telescope = { enabled = true },
      noice = true,
      notify = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")

    -- Additional transparency customizations
    local hl = vim.api.nvim_set_hl
    hl(0, "TelescopeNormal", { bg = "NONE" })
    hl(0, "TelescopeBorder", { bg = "NONE" })
    hl(0, "TelescopePromptNormal", { bg = "NONE" })
    hl(0, "TelescopePromptBorder", { bg = "NONE" })
    hl(0, "TelescopePreviewNormal", { bg = "NONE" })
    hl(0, "TelescopePreviewBorder", { bg = "NONE" })
    hl(0, "TelescopeResultsNormal", { bg = "NONE" })
    hl(0, "TelescopeResultsBorder", { bg = "NONE" })

    hl(0, "NormalFloat", { bg = "NONE" })
    hl(0, "FloatBorder", { bg = "NONE" })
    hl(0, "TabLine", { bg = "NONE" })
    hl(0, "OilNormal", { bg = "NONE" })
    hl(0, "OilFloat", { bg = "NONE" })
  end,
}
