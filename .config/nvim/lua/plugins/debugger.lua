return {
  {
    "mfussenegger/nvim-dap",
    opts = {},
    dependencies = {
      "igorlfs/nvim-dap-view",
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
    end,
  },
}
