return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  config = function()
    -- Helper to detect Prettier config files
    local function get_js_formatter(bufnr)
      local prettier_configs = {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.yml",
        ".prettierrc.yaml",
        ".prettierrc.json5",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.mjs",
        "prettier.config.js",
        "prettier.config.cjs",
        "prettier.config.mjs",
      }

      local found = vim.fs.find(prettier_configs, {
        path = vim.api.nvim_buf_get_name(bufnr),
        upward = true,
      })[1]

      if found then
        return { "prettierd", "prettier" }
      end
      return { "oxfmt" }
    end

    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        -- Use the util for all JS/Web eco files
        javascript = get_js_formatter,
        javascriptreact = get_js_formatter,
        typescript = get_js_formatter,
        typescriptreact = get_js_formatter,
        json = get_js_formatter,
        markdown = get_js_formatter,
        css = get_js_formatter,
        html = get_js_formatter,
        yaml = get_js_formatter,
      },
      format_on_save = {
        timeout_ms = 2500,
        lsp_format = "fallback", -- Updated from lsp_fallback (conform naming)
      },
    })
  end,
}
