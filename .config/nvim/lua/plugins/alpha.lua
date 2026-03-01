return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      [[                                                                       ]],
      [[                                                                     ]],
      [[       ████ ██████           █████      ██                     ]],
      [[      ███████████             █████                             ]],
      [[      █████████ ███████████████████ ███   ███████████   ]],
      [[     █████████  ███    █████████████ █████ ██████████████   ]],
      [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
      [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
      [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      [[                                                                       ]],
    }

    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("g", "  Find Text", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("n", "  New File", "<cmd>ene <BAR> startinsert<CR>"),
      dashboard.button("s", "󰺄  Search sessions", "<cmd>AutoSession search<CR>"),
      dashboard.button("d", "  Delete sessions", "<cmd>AutoSession deletePicker<CR>"),
      dashboard.button("r", "  Recent", "<cmd>Telescope oldfiles<CR>"),
      dashboard.button("u", "  Update Plugins", "<cmd>Lazy update<CR>"),
      dashboard.button("c", "  Settings", "<cmd>e $MYVIMRC<CR>"),
      dashboard.button("q", "⏻  Quit", "<cmd>qa<CR>"),
    }

    dashboard.config.opts.layout = {
      { type = "padding", val = 3 },
      dashboard.section.header,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      { type = "padding", val = 1 },
      dashboard.section.footer,
    }

    dashboard.section.header.opts.hl = "Include"
    dashboard.section.buttons.opts.hl = "Keyword"

    alpha.setup(dashboard.config)
  end,
}
