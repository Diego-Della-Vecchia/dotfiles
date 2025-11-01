return {
  "windwp/nvim-autopairs",
  dependencies = { "hrsh7th/nvim-cmp" },
  config = function()
    local npairs = require("nvim-autopairs")
    npairs.setup({ check_ts = true })

    -- integrate with nvim-cmp for function parentheses
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    local cmp = require("cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end,
}
