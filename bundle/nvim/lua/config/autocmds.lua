-- Autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- YAML file settings
local yaml_group = augroup("YAMLSettings", { clear = true })
autocmd("FileType", {
  pattern = "yaml",
  group = yaml_group,
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.indentkeys = ""
  end,
})

-- Highlight on yank
local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = highlight_group,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
})

-- Automatically close nvim-tree when it's the last window
local tree_group = augroup("NvimTreeAutoClose", { clear = true })
autocmd("BufEnter", {
  group = tree_group,
  callback = function()
    if vim.fn.winnr("$") == 1 and vim.bo.filetype == "NvimTree" then
      vim.cmd("quit")
    end
  end,
})
