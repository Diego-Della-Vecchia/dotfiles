return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    -- Define the custom copy function
    local function copy_diagnostic(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      if selection then
        -- Diagnostic entries usually store the message in selection.value.message
        -- We fall back to selection.ordinal (what is shown) if .message is missing
        local text = selection.value and selection.value.message or selection.ordinal

        -- Copy to system clipboard (register +)
        vim.fn.setreg("+", text)

        -- Optional: Close telescope after copying. Comment out if you want it to stay open.
        actions.close(prompt_bufnr)

        print("Copied to clipboard: " .. text)
      end
    end

    telescope.setup({
      defaults = {
        -- ADD THIS MAPPINGS BLOCK
        mappings = {
          i = {
            ["<C-y>"] = copy_diagnostic, -- Ctrl+y to copy in insert mode
          },
          n = {
            ["<C-y>"] = copy_diagnostic, -- Ctrl+y to copy in normal mode
          },
        },
        -- END MAPPINGS BLOCK

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
      file_ignore_patterns = { "node_modules", ".git" },
      previewer = true,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    })

    telescope.load_extension("fzf")

    -- Keymaps
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
}
