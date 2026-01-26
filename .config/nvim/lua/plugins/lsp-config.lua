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
        "lua_ls",
        "ts_ls",
        "jsonls",
        "html",
        "cssls",
        "emmet_ls",
        "tailwindcss",
        "rust_analyzer",
        "marksman",
        "yamlls",
      },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)

      -- Gleam
      vim.lsp.enable("gleam")

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

      vim.lsp.config.rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
          },
        },
      }

      vim.lsp.config.eslint = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
          "vue",
          "svelte",
          "astro",
        },
      }
    end,
    keys = {
      { "gd", vim.lsp.buf.definition, desc = "Go to Definition" },
      { "gr", vim.lsp.buf.references, desc = "Go to References" },
      -- K is handled by hover.lua
      { "<leader>rn", vim.lsp.buf.rename, desc = "Rename Symbol" },
      {
        "<leader>ca",
        function()
          require("tiny-code-action").code_action({})
        end,
        desc = "Code Action",
        mode = { "n", "v" },
      },
    },
  },

  -- External formatters & linters via Mason Tool Installer
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "stylua",
        "prettierd",
        "prettier",
        "luacheck",
        "eslint",
        "eslint_d",
        "actionlint",
      },
      auto_update = true,
      run_on_start = true,
    },
  },
}
