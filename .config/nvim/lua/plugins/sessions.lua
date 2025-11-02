return {
  "rmagatti/auto-session",
  lazy = false,

  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    auto_restore = false,
    suppressed_dirs = { "~/", "~/Downloads", "/" },
    allowed_dirs = { "~/Projects", "~/Playground" },
  },
  config = function(_, opts)
    require("auto-session").setup(opts)

    vim.keymap.set(
      "n",
      "<leader>qs",
      "<cmd>AutoSession save<CR>",
      { desc = "Save a session in the current cwd" }
    )
    vim.keymap.set(
      "n",
      "<leader>qr",
      "<cmd>AutoSession restore<CR>",
      { desc = "Restore a session in the current cwd" }
    )
    vim.keymap.set(
      "n",
      "<leader>qx",
      "<cmd>AutoSession delete<CR>",
      { desc = "Delete a session in the current cwd" }
    )
    vim.keymap.set("n", "<leader>qd", "<cmd>AutoSession disable<CR>", { desc = "Disable autosave" })
    vim.keymap.set("n", "<leader>qe", "<cmd>AutoSession enable<CR>", { desc = "Enable autosave" })
    vim.keymap.set(
      "n",
      "<leader>qf",
      "<cmd>AutoSession search<CR>",
      { desc = "Search for sessions" }
    )
    vim.keymap.set(
      "n",
      "<leader>qX",
      "<cmd>AutoSession deletePicker<CR>",
      { desc = "Pick session to delete sessions" }
    )
  end,
}
