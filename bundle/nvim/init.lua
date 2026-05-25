--[[
  Modern Neovim Configuration
  Refactored to use Lua and lazy.nvim
  Migrated from VimScript-based init.vim
]]

-- Load core configuration
require("config.options")    -- Core Neovim options
require("config.keymaps")    -- Keybindings
require("config.autocmds")   -- Autocommands

-- Load plugins (lazy.nvim will be bootstrapped automatically)
require("plugins")

-- Additional plugin-specific settings that don't require separate files
vim.g.tmuxline_preset = "nightly_fox"
