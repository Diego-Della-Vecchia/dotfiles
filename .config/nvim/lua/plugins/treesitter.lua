return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "lua",
        "javascript",
        "typescript",
        "styled",
        "tsx",
        "json",
        "markdown",
        "markdown_inline",
      },
      auto_install = true,
      ignore_install = {},
      sync_install = false,
      modules = {},
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
