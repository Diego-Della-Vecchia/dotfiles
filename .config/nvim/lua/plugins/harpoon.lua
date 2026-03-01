return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  keys = {
    {
      "<leader>hx",
      function()
        require("harpoon"):list():add()
      end,
      desc = "Harpoon: Add File",
    },
    {
      "<leader>hm",
      function()
        local harpoon = require("harpoon")
        local harpoon_files = harpoon:list()
        local finder = function()
          local paths = {}
          for _, item in ipairs(harpoon_files.items) do
            table.insert(paths, item.value)
          end
          return require("telescope.finders").new_table({ results = paths })
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
      end,
      desc = "Harpoon: Toggle Menu",
    },
    {
      "<leader>hn",
      function()
        require("harpoon"):list():next()
      end,
      desc = "Harpoon: Next File",
    },
    {
      "<leader>hp",
      function()
        require("harpoon"):list():prev()
      end,
      desc = "Harpoon: Previous File",
    },
    {
      "<leader>ha",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "Harpoon: Select 1",
    },
    {
      "<leader>hs",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "Harpoon: Select 2",
    },
    {
      "<leader>hq",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "Harpoon: Select 3",
    },
    {
      "<leader>hw",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "Harpoon: Select 4",
    },
  },
  opts = {},
}
