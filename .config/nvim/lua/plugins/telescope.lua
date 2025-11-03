return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
          },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              preview_cutoff = 0,
            },
          },
        },
        previewer = true,
        -- Enable file previewer
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      })
      telescope.load_extension("fzf")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Ripgrep search" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers search" })
      vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "Find references" })
      vim.keymap.set("n", "<leader>fx", builtin.diagnostics, { desc = "Open diagnostics" })
      vim.keymap.set("n", "<leader>fq", builtin.quickfix, { desc = "Open quickfix list" })
      vim.keymap.set("n", "<leader>fl", builtin.loclist, { desc = "Open loc list" })
      vim.keymap.set(
        "n",
        "<leader>fs",
        builtin.lsp_workspace_symbols,
        { desc = "Open workspace symbols list" }
      )
      vim.keymap.set(
        "n",
        "<leader>fS",
        builtin.lsp_document_symbols,
        { desc = "Open document symbols list" }
      )
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
}
