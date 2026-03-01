return {
  {
    -- Harpoon lualine component
    "letieu/harpoon-lualine",
    dependencies = {
      {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
      },
    },
  },
  {
    -- Macro recording lualine component
    "yavorski/lualine-macro-recording.nvim",
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "catppuccin/nvim",
      "letieu/harpoon-lualine",
      "yavorski/lualine-macro-recording.nvim",
    },
    opts = {
      options = {
        theme = "catppuccin",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { right = "", left = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          "filename",
          "%=",
          {
            "harpoon2",
            icon = "󰛢",
            indicators = { "a", "s", "q", "w" },
            active_indicators = { "A", "S", "Q", "W" },
            color_active = { fg = "#8caaee" },
            _separator = " ",
            no_harpoon = "No Harpoon",
            align = "center",
          },
        },
        lualine_x = {
          "macro_recording",
          "diagnostics",
          { "fileformat", symbols = { unix = "" } },
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
    config = function(_, opts)
      require("lualine").setup(opts)
    end,
  },
}
