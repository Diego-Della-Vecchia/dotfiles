return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Find files" },
    { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Find TODOs" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers search" },
    { "<leader>fr", "<cmd>Telescope lsp_references<CR>", desc = "Find references" },
    { "<leader>fx", "<cmd>Telescope diagnostics<CR>", desc = "Open diagnostics" },
    { "<leader>fq", "<cmd>Telescope quickfix<CR>", desc = "Open quickfix list" },
    { "<leader>fl", "<cmd>Telescope loclist<CR>", desc = "Open loc list" },
    { "<leader>fs", "<cmd>Telescope lsp_workspace_symbols<CR>", desc = "Workspace symbols" },
    { "<leader>fS", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
  },
  opts = function()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    -- Define the custom copy function
    local function copy_diagnostic(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      if selection then
        local text = selection.value and selection.value.message or selection.ordinal
        vim.fn.setreg("+", text)
        actions.close(prompt_bufnr)
        print("Copied to clipboard: " .. text)
      end
    end

    return {
      defaults = {
        mappings = {
          i = { ["<C-y>"] = copy_diagnostic },
          n = { ["<C-y>"] = copy_diagnostic },
        },
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
          horizontal = { preview_cutoff = 0 },
        },
        file_ignore_patterns = { "node_modules", ".git" },
        previewer = true,
      },
    }
  end,
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    telescope.load_extension("fzf")
  end,
}
