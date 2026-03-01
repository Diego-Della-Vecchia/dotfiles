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

  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
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
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.semanticTokens = nil
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      require("mason-lspconfig").setup(opts)

      if capabilities.workspace then
        capabilities.workspace.didChangeWatchedFiles = {
          dynamicRegistration = false,
        }
      end

      local on_attach = function(client, bufnr)
        client.server_capabilities.semanticTokensProvider = nil
      end

      vim.lsp.config.tailwindcss = {
        on_attach = on_attach,
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
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
          },
        },
      }

      vim.lsp.config.eslint = {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          run = "onSave",
          onType = "off",
          codeActionOnSave = {
            enable = false,
            mode = "all",
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
        "eslint_d",
        "actionlint",
      },
      auto_update = true,
      run_on_start = true,
    },
  },
}
