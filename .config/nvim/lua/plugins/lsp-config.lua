return {
  -- Mason core
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  -- LSP servers
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        -- Lua
        "lua_ls",

        -- Web
        "ts_ls",
        "jsonls",
        "html",
        "cssls",
        "emmet_ls",
        "tailwindcss",

        -- Markdown
        "marksman",

        -- YAML
        "yamlls",
      },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)

      -- Tailwind CSS LSP settings
      vim.lsp.config.tailwindcss = {
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "clsx\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "twMerge\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
              },
            },
          },
        },
      }

      -- Keymaps for LSP
      vim.keymap.set(
        "n",
        "gd",
        vim.lsp.buf.definition,
        { noremap = true, silent = true, desc = "Go to Definition" }
      )
      vim.keymap.set(
        "n",
        "gr",
        vim.lsp.buf.references,
        { noremap = true, silent = true, desc = "Go to References" }
      )
      vim.keymap.set(
        "n",
        "K",
        vim.lsp.buf.hover,
        { noremap = true, silent = true, desc = "Hover Documentation" }
      )
      vim.keymap.set(
        "n",
        "<leader>ca",
        vim.lsp.buf.code_action,
        { noremap = true, silent = true, desc = "Code Action" }
      )
      vim.keymap.set(
        "n",
        "<leader>rn",
        vim.lsp.buf.rename,
        { noremap = true, silent = true, desc = "Rename Symbol" }
      )
    end,
  },

  -- External formatters & linters via Mason Tool Installer
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Formatters
          "stylua",
          "prettierd",
          "prettier",

          -- Linters
          "luacheck",
          "eslint",
          "eslint_d",
        },
        auto_update = true,
        run_on_start = true,
      })
    end,
  },
}
