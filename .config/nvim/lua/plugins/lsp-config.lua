return {

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
      performance = {
        max_entries = 10,
      },
    },
  },

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
      -- custom ts go lsp because it's not on mason yet
      vim.lsp.config("tsgo", {
        cmd = { "tsgo", "--lsp", "--stdio" },
        root_markers = { "tsconfig.json", "package.json", ".git" },
        filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      })
      vim.lsp.enable("tsgo")

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.semanticTokens = nil
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      require("mason-lspconfig").setup(opts)

      -- disable ts_ls in favor of custom tsgo lsp
      vim.lsp.config.ts_ls = {
        enabled = false,
        autostart = false,
      }

      vim.lsp.config.tailwindcss = {
        capabilities = capabilities,
        settings = {
          tailwindCSS = {
            files = {
              exclude = { "**/.git/**", "**/node_modules/**", "**/.next/**", "**/.bun/**" },
            },
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

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "stylua",
        "prettierd",
        "luacheck",
        "actionlint",
        "oxfmt",
        "oxlint",
      },
      auto_update = true,
      run_on_start = true,
    },
  },
}
