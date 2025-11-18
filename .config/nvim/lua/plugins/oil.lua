return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    default_file_explorer = true,
    skip_confirm_for_simple_edits = true,
    -- Show everything except .git and ..
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name, _)
        return name:match("^%.git$") ~= nil
          or name == ".."
          or name == "node_modules"
          or name == "bin"
          or name == "build"
          or name == "dist"
      end,
    },
    -- automatically wipe buffer when file is deleted
    on_delete = function(_, deleted_path)
      local buf = vim.fn.bufnr(deleted_path)
      if buf ~= -1 then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
    float = {
      padding = 2,
      max_width = 80,
      min_width = 40,
      max_height = 30,
      min_height = 10,
      border = "rounded",
      win_options = {
        winblend = 0,
      },
    },
    confirmation = {
      max_width = 80,
      min_width = 40,
      max_height = 40,
      min_height = 10,
      border = "rounded",
      win_options = {
        winblend = 0,
      },
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  keys = {
    {
      "<leader>e",
      function()
        require("oil").open_float()
      end,
      desc = "Open Oil file explorer",
    },
  },
}
