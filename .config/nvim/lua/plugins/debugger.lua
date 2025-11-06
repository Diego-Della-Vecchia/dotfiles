return {
  {
    "mfussenegger/nvim-dap",
    opts = {},
    dependencies = {
      "igorlfs/nvim-dap-view",
      "microsoft/vscode-js-debug",
      "mxsdev/nvim-dap-vscode-js",
    },
    config = function(_, opts)
      local dap = require("dap")

      -- Customize breakpoint appearance
      vim.fn.sign_define(
        "DapBreakpoint",
        { text = "", texthl = "DapBreakpointColor", linehl = "", numhl = "" }
      )

      -- Keybinds
      vim.keymap.set("n", "<leader>db", function()
        dap.toggle_breakpoint()
      end, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", function()
        dap.continue()
      end, { desc = "Continue" })
      vim.keymap.set("n", "<leader>di", function()
        dap.step_into()
      end, { desc = "Step Into" })
      vim.keymap.set("n", "<leader>do", function()
        dap.step_over()
      end, { desc = "Step Over" })
      vim.keymap.set("n", "<leader>dr", function()
        dap.repl.open()
      end, { desc = "Open REPL" })
      vim.keymap.set("n", "<leader>dv", "<cmd>DapViewToggle<cr>", { desc = "Toggle Dap View" })

      -- Setup vscodejs dap
      require("dap-vscode-js").setup({
        adapters = { "pwa-node", "pwa-chrome", "node-terminal" }, -- which adapters to register in nvim-dap
      })

      for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        require("dap").configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome",
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest Tests",
            runtimeExecutable = "node",
            runtimeArgs = {
              "./node_modules/jest/bin/jest.js",
              "--runInBand",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
          },
        }
      end
    end,
  },
  {
    "igorlfs/nvim-dap-view",
    opts = {},
    config = function(_, opts)
      require("dap-view").setup(opts)
    end,
  },
  {
    "microsoft/vscode-js-debug",
    opt = true,
    run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
  },
  { "mxsdev/nvim-dap-vscode-js", dependencies = { "microsoft/vscode-js-debug" } },
}
