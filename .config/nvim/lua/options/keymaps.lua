vim.g.mapleader = " "

local keymap = vim.keymap

-- General
keymap.set("n", "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })
keymap.set("v", "<C-s>", "<Esc><cmd>w<CR>gv", { desc = "Save file" })
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Resize with Alt + Arrows
keymap.set("n", "<A-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
keymap.set("n", "<A-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
keymap.set("n", "<A-Right>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
keymap.set("n", "<A-Left>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabnext<CR>", { desc = "Next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
