local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set header (logo)
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

-- Menu buttons
dashboard.section.buttons.val = {
  dashboard.button("f", "  Find File", ":Telescope find_files<CR>"),
  dashboard.button("g", "  Find Text", ":Telescope live_grep<CR>"),
  dashboard.button("n", "  New File", ":ene <BAR> startinsert<CR>"),
  dashboard.button("s", "󰺄  Search sessions", ":AutoSession search<CR>"),
  dashboard.button("d", "  Delete sessions", ":AutoSession deletePicker<CR>"),
  dashboard.button("r", "  Recent", ":Telescope oldfiles<CR>"),
  dashboard.button("u", "  Update Plugins", ":Lazy update<CR>"),
  dashboard.button("c", "  Settings", ":e $MYVIMRC<CR>"),
  dashboard.button("q", "⏻  Quit", ":qa<CR>"),
}

-- Center everything vertically
dashboard.config.opts.layout = {
  { type = "padding", val = 3 },
  dashboard.section.header,
  { type = "padding", val = 2 },
  dashboard.section.buttons,
  { type = "padding", val = 1 },
  dashboard.section.footer,
}

-- Set highlight
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"

-- Enable line numbers (optional)
vim.wo.number = true
vim.wo.relativenumber = false

alpha.setup(dashboard.config)
