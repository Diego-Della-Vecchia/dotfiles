return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Show Which-Key",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Which-key
    wk.add({
      { "<leader>?", desc = "Show Which-Key", icon = "" },
    })

    -- Clear search highlight
    wk.add({
      { "<leader>n", group = "Search", icon = "" },
      { "<leader>nh", desc = "Clear Search Highlight", icon = "" },
    })

    --Code actions
    wk.add({
      { "<leader>c", group = "Code Actions", icon = "" },
      { "<leader>ca", desc = "Use code action", icon = "" },
      { "<leader>r", group = "Refactor", icon = "󰆦" },
      { "<leader>rn", name = "Rename Symbol", icon = "󰆦" },
      { "<leader>g", group = "Go to", icon = "" },
      { "<leader>gd", desc = "Go to Definition", icon = "" },
      { "<leader>gr", desc = "Go to References", icon = "" },
      { "gK", desc = "Show Hover Select Documentation", icon = "" },
      { "K", desc = "Show Hover Documentation", icon = "" },
    })

    -- Save file
    wk.add({
      { "<C-s>", desc = "Save file", icon = "" },
    }, { mode = { "n", "i", "v" } })

    -- File explorer
    wk.add({
      { "<leader>e", desc = "Toggle File Explorer", icon = "" },
    })

    -- Window management
    wk.add({
      { "<leader>s", group = "Splits", icon = "" },
      { "<leader>sv", desc = "Split window vertically", icon = "" },
      { "<leader>sh", desc = "Split window horizontally", icon = "" },
      { "<leader>se", desc = "Make splits equal size", icon = "" },
      { "<leader>sx", desc = "Close current split", icon = "" },
    })

    -- Register tab keymaps
    wk.add({
      { "<leader>t", group = "Tabs", icon = "" },
      { "<leader>to", desc = "Open New Tab", icon = "" },
      { "<leader>tn", desc = "Next Tab", icon = "" },
      { "<leader>tp", desc = "Previous Tab", icon = "" },
      { "<leader>tx", desc = "Close Tab", icon = "" },
    })

    -- Flash
    wk.add({
      { "s", desc = "Flash", icon = "" },
      { "S", desc = "Flash Treesitter", icon = "" },
      { "r", desc = "Remote Flash", icon = "" },
      { "R", desc = "Treesitter Search", icon = "" },
      { "<c-s>", desc = "Toggle Flash Search", icon = "" },
    })

    -- Harpoon
    wk.add({
      { "<leader>h", group = "Harpoon", icon = "" },
      { "<leader>hx", desc = "Add File to Harpoon", icon = "" },
      { "<leader>hm", desc = "Toggle Harpoon Menu", icon = "" },
      { "<leader>hn", desc = "Next Harpoon File", icon = "" },
      { "<leader>hp", desc = "Previous Harpoon File", icon = "" },
      { "<leader>ha", desc = "Select First Harpoon File", icon = "1" },
      { "<leader>hq", desc = "Select Second Harpoon File", icon = "2" },
      { "<leader>hs", desc = "Select Third Harpoon File", icon = "3" },
      { "<leader>hw", desc = "Select Fourth Harpoon File", icon = "4" },
    })

    -- Autosessions
    wk.add({
      { "<leader>q", group = "Sessions", icon = "" },
      { "<leader>qs", desc = "Save Session", icon = "" },
      { "<leader>qr", desc = "Reload Session", icon = "" },
      { "<leader>qx", desc = "Delete Session", icon = "" },
      { "<leader>qX", desc = "Choose session to delete", icon = "" },
      { "<leader>qf", desc = "Search Sessions", icon = "" },
    })

    -- Surround
    wk.add({
      { "ys", desc = "Add Surround", icon = "" },
      { "ds", desc = "Delete Surround", icon = "" },
      { "cs", desc = "Change Surround", icon = "" },
    })

    -- Telescope
    wk.add({
      { "<leader>f", group = "Telescope", icon = "" },
      { "<leader>ff", desc = "Find Files", icon = "" },
      { "<leader>fr", desc = "Find references", icon = "" },
      { "<leader>fg", desc = "Live Grep", icon = "" },
      { "<leader>fb", desc = "Buffers", icon = "﬘" },
      { "<leader>fx", desc = "Search diagnostics", icon = "" },
      { "<leader>fq", desc = "Open quickfix list", icon = "" },
      { "<leader>fl", desc = "Open loc list", icon = "" },
      { "<leader>fs", desc = "Workspace Symbols", icon = "" },
      { "<leader>fS", desc = "Document Symbols", icon = "" },
    })
  end,
}
