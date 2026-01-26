return {
  "rmagatti/auto-session",
  lazy = false,
  opts = {
    auto_restore = false,
    suppressed_dirs = { "~/", "~/Downloads", "/" },
    allowed_dirs = { "~/Projects", "~/Playground" },
  },
  keys = {
    { "<leader>qs", "<cmd>AutoSession save<CR>", desc = "Save session" },
    { "<leader>qr", "<cmd>AutoSession restore<CR>", desc = "Restore session" },
    { "<leader>qx", "<cmd>AutoSession delete<CR>", desc = "Delete session" },
    { "<leader>qd", "<cmd>AutoSession disable<CR>", desc = "Disable autosave" },
    { "<leader>qe", "<cmd>AutoSession enable<CR>", desc = "Enable autosave" },
    { "<leader>qf", "<cmd>AutoSession search<CR>", desc = "Search sessions" },
    { "<leader>qX", "<cmd>AutoSession deletePicker<CR>", desc = "Pick session to delete" },
  },
}
