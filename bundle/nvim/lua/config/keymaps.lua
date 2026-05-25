-- Keymaps configuration
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Folding - toggle with space (leader)
keymap("n", "<leader>z", "za", { noremap = true, desc = "Toggle fold" })

-- File Explorer (nvim-tree) - replaces NERDTree
keymap("n", "<C-n>", ":NvimTreeToggle<CR>", opts)

-- Telescope (fuzzy finder) - replaces ctrlp
keymap("n", "<C-p>", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", opts)
keymap("n", "<leader>fr", ":Telescope oldfiles<CR>", opts)

-- LSP keybindings (will be set in lsp.lua when LSP attaches)
-- Using leader key for LSP commands
keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
keymap("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Set diagnostic loclist" })

-- Buffer navigation
keymap("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Better indenting in visual mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move selected lines up/down
keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Keep cursor centered when scrolling
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- Git (fugitive)
keymap("n", "<leader>gs", ":Git<CR>", { desc = "Git status" })
keymap("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
keymap("n", "<leader>gp", ":Git push<CR>", { desc = "Git push" })
keymap("n", "<leader>gl", ":Git pull<CR>", { desc = "Git pull" })
