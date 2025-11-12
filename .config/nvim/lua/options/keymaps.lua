vim.g.mapleader = " "

local keymap = vim.keymap -- For conciceseness

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights", silent = true })

-- Save files

keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })
keymap.set("v", "<C-s>", "<Esc><cmd>w<CR>gv", { desc = "Save file" })

-- Remap ctrl+d and ctrl+u to keep cursor in the middle
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- Resize with alt + arrows
keymap.set("n", "<A-Up>", ":resize +2<CR>", { desc = "Increase window height", silent = true })
keymap.set("n", "<A-Down>", ":resize -2<CR>", {
  desc = "Decrease window height",
  silent = true,
})
keymap.set(
  "n",
  "<A-Right>",
  ":vertical resize -2<CR>",
  { desc = "Decrease window width", silent = true }
)
keymap.set(
  "n",
  "<A-Left>",
  ":vertical resize +2<CR>",
  { desc = "Increase window width", silent = true }
)
