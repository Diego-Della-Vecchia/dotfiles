vim.g.mapleader = " "

local keymap = vim.keymap -- For conciceseness

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Save files 

-- Normal mode
keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

-- Insert mode (so you don't have to exit insert mode)
keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })

-- Visual mode (optional)
keymap.set("v", "<C-s>", "<Esc><cmd>w<CR>gv", { desc = "Save file" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- Bufferline buffer navigation
keymap.set("n", "<leader>hn", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>hp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
keymap.set("n", "<leader>hx", "<cmd>BufferLinePickClose<CR>", { desc = "Chose buffer to close" })


