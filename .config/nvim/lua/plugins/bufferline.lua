return {
  "akinsho/bufferline.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("bufferline").setup({
      options = {
        -- Show numbers (optional)
        numbers = "none",
        -- Show only filename, no path
        name_formatter = function(buf)
          return vim.fn.fnamemodify(buf.path, ":t") -- filename only
        end,
        -- Enable webdev icons
        show_buffer_icons = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        separator_style = "padded",
        mode = "tabs",
      },
      highlights = require("catppuccin.special.bufferline").get_theme(),
    })
    vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
    vim.keymap.set("n", "<leader>tn", "<cmd>BufferLineCycleNext<CR>", { desc = "Next tab" })
    vim.keymap.set("n", "<leader>tp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous tab" })
    vim.keymap.set(
      "n",
      "<leader>tx",
      "<cmd>BufferLinePickClose<CR>",
      { desc = "Chose buffer to close" }
    )
  end,
}
