return {
  "akinsho/bufferline.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  keys = {
    { "<leader>to", "<cmd>tabnew<CR>", desc = "Open new tab" },
    { "<leader>tn", "<cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
    { "<leader>tp", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous tab" },
    { "<leader>tx", "<cmd>BufferLinePickClose<CR>", desc = "Choose buffer to close" },
  },
  opts = function()
    return {
      options = {
        numbers = "none",
        name_formatter = function(buf)
          return vim.fn.fnamemodify(buf.path, ":t")
        end,
        show_buffer_icons = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        separator_style = "padded",
        mode = "tabs",
      },
      highlights = require("catppuccin.special.bufferline").get_theme(),
    }
  end,
  config = function(_, opts)
    require("bufferline").setup(opts)
  end,
}
