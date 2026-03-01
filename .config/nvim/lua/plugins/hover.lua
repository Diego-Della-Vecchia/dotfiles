return {
  "lewis6991/hover.nvim",
  event = "BufReadPost",
  opts = {
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
      border = "rounded",
      max_width = 80,
    },
    quit_on_move = true,
  },
  keys = {
    {
      "K",
      function()
        require("hover").open()
      end,
      desc = "Hover",
    },
    {
      "gK",
      function()
        require("hover").enter()
      end,
      desc = "Hover select",
    },
  },
  config = function(_, opts)
    require("hover").setup(opts)
  end,
}
