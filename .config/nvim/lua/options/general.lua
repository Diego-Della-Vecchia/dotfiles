local opt = vim.opt --For concicesness

opt.relativenumber = false
opt.number = true
opt.fillchars = { eob = " " }

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

opt.termguicolors = true -- enable true colors for modern colorschemes
opt.background = "dark" -- tell colorschemes the background is dark
opt.signcolumn = "yes" -- always show the sign column to prevent text shift

opt.backspace = "indent,eol,start"

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- inline error messages
vim.diagnostic.config({
  virtual_text = {
    prefix = "▶",
    spacing = 2,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Populate quickix/location list with diagnostics
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  callback = function()
    vim.diagnostic.setqflist({ open = false })
    vim.diagnostic.setloclist({ open = false })
  end,
})
