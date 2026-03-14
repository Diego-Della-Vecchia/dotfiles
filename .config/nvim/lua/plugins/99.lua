return {
  "ThePrimeagen/99",
  config = function()
    local _99 = require("99")

    local cwd = vim.uv.cwd()
    local basename = vim.fs.basename(cwd)
    _99.setup({
      logger = {
        level = _99.DEBUG,
        path = "/tmp/" .. basename .. ".99.debug",
        print_on_error = true,
      },
      provider = _99.Providers.ClaudeCodeProvider,
      tmp_dir = "./tmp",

      completion = {
        custom_rules = {
          "scratch/custom_rules/",
        },
      },

      files = {
        enabled = true,
        max_file_size = 102400,
        max_files = 5000,
        exclude = { ".env", ".env.*", "node_modules", ".git" },
      },

      source = "cmp",

      md_files = {
        "CLAUDE.md",
        "README.md",
      },
    })

    vim.keymap.set("v", "<leader>9v", function()
      _99.visual()
    end, { desc = "99 visual mode" })

    vim.keymap.set("n", "<leader>9x", function()
      _99.stop_all_requests()
    end, { desc = "99 Stop all requests" })

    vim.keymap.set("n", "<leader>9s", function()
      _99.search()
    end, { desc = "99 search mode" })
  end,
}
