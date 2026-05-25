-- Core Neovim options
local opt = vim.opt

-- General settings
vim.cmd("syntax on")
opt.mouse = "a"
opt.number = true
opt.formatoptions:append("o")
opt.textwidth = 0
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.linespace = 0
opt.joinspaces = false

-- Split behavior
opt.splitbelow = true
opt.splitright = true

-- Scrolling
opt.scrolloff = 3
opt.sidescrolloff = 5
opt.startofline = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.gdefault = true
opt.magic = true

-- Folding
opt.foldmethod = "indent"
opt.foldlevel = 99
opt.foldlevelstart = 20

-- Appearance
opt.termguicolors = true
opt.background = "dark"

-- Buffer management
opt.hidden = true

-- Encoding
opt.encoding = "utf-8"

-- Disable compatibility mode
opt.compatible = false

-- Conceal settings (for indentLine)
opt.conceallevel = 0
opt.concealcursor = ""

-- ShaDa (shared data) settings - replaces viminfo in Neovim
opt.shadafile = vim.fn.stdpath("data") .. "/shada/main.shada"
-- Disable viminfo entirely (Neovim uses shada)
vim.opt.viminfo = ""

-- Home dir ACL denies delete, so backups can't be cleaned from `.`; pin to state dir
opt.backupdir = vim.fn.stdpath("state") .. "/backup//"
