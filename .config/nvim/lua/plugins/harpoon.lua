return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    -- basic telescope configuration
    local function toggle_telescope(harpoon_files)
      local finder = function()
        local paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(paths, item.value)
        end

        return require("telescope.finders").new_table({
          results = paths,
        })
      end

      require("telescope.pickers")
        .new({}, {
          prompt_title = "Harpoon",
          finder = finder(),
          previewer = false,
          sorter = require("telescope.config").values.generic_sorter({}),
          layout_config = {
            height = 0.4,
            width = 0.5,
            prompt_position = "top",
            preview_cutoff = 120,
          },
          attach_mappings = function(prompt_bufnr, map)
            local rm_mark = function()
              local state = require("telescope.actions.state")
              local selected_entry = state.get_selected_entry()
              local current_picker = state.get_current_picker(prompt_bufnr)

              table.remove(harpoon_files.items, selected_entry.index)
              current_picker:refresh(finder())
            end
            map("i", "<C-d>", rm_mark)
            map("n", "<C-d>", rm_mark)
            return true
          end,
        })
        :find()
    end

    vim.keymap.set("n", "<leader>hx", function()
      harpoon:list():add()
    end, { desc = "Harpoon: Add File" })

    vim.keymap.set("n", "<leader>hm", function()
      toggle_telescope(harpoon:list())
    end, { desc = "Harpoon: Add File" })

    vim.keymap.set("n", "<leader>hn", function()
      harpoon:list():next()
    end, { desc = "Harpoon: Next File" })

    vim.keymap.set("n", "<leader>hp", function()
      harpoon:list():prev()
    end, { desc = "Harpoon: Previous File" })

    vim.keymap.set("n", "<leader>ha", function()
      harpoon:list():select(1)
    end, { desc = "Harpoon: Select first file" })

    vim.keymap.set("n", "<leader>hs", function()
      harpoon:list():select(2)
    end, { desc = "Harpoon: Select second file" })

    vim.keymap.set("n", "<leader>hq", function()
      harpoon:list():select(3)
    end, { desc = "Harpoon: Select third file" })

    vim.keymap.set("n", "<leader>hw", function()
      harpoon:list():select(4)
    end, { desc = "Harpoon: Select fourth file" })
  end,
}
