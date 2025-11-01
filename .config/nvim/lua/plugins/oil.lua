return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    -- automatically wipe buffer when file is deleted
    on_delete = function(_, deleted_path)
      local buf = vim.fn.bufnr(deleted_path)
      if buf ~= -1 then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  },
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional for icons
  lazy = false,
  keys = {
    {
      "<leader>e",
      function() require("oil").open() end,
      desc = "Open Oil file explorer",
    },
  },
}

