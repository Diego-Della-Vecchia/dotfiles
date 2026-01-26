return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>f", group = "Find (Telescope)", icon = "" },
      { "<leader>c", group = "Code Actions", icon = "" },
      { "<leader>r", group = "Refactor", icon = "󰆦" },
      { "<leader>g", group = "Go to", icon = "" },
      { "<leader>h", group = "Harpoon", icon = "󰛢" },
      { "<leader>q", group = "Sessions", icon = "" },
      { "<leader>s", group = "Splits", icon = "" },
      { "<leader>t", group = "Tabs", icon = "" },
      { "<leader>n", group = "Search", icon = "" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Show Which-Key",
    },
  },
}
