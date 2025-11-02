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

        -- Markdown
        "marksman",

        -- YAML
        "yamlls",
      },
      init_options = {
        html = {
          options = {
            ["bem.enabled"] = true,
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)

      -- Keymaps for LSP
      local opts_keymap = { noremap = true, silent = true }
      vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts_keymap)
      vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts_keymap)
      vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts_keymap)
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
