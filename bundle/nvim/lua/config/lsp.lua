-- LSP Configuration using Neovim 0.11+ native vim.lsp.config API
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- LSP keymaps to attach when LSP server starts
local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }

  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)
end

-- Mason setup for automatic LSP server installation
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "pyright",
    "bashls",
    "yamlls",
    "jsonls",
  },
  automatic_installation = true,
})

-- Configure LSP servers using the new vim.lsp.config API
-- Lua Language Server
vim.lsp.config("lua_ls", {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/lua-language-server" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

-- Python (Pyright)
vim.lsp.config("pyright", {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/pyright-langserver", "--stdio" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" },
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- Bash
vim.lsp.config("bashls", {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/bash-language-server", "start" },
  root_markers = { ".git" },
  capabilities = capabilities,
  on_attach = on_attach,
})

-- YAML
vim.lsp.config("yamlls", {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/yaml-language-server", "--stdio" },
  root_markers = { ".git" },
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    yaml = {
      schemas = {
        kubernetes = "/*.yaml",
      },
    },
  },
})

-- JSON
vim.lsp.config("jsonls", {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/vscode-json-language-server", "--stdio" },
  root_markers = { ".git" },
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Enable LSP servers for their respective filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function(args)
    vim.lsp.enable("lua_ls")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(args)
    vim.lsp.enable("pyright")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sh", "bash" },
  callback = function(args)
    vim.lsp.enable("bashls")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function(args)
    vim.lsp.enable("yamlls")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function(args)
    vim.lsp.enable("jsonls")
  end,
})

-- Configure diagnostic signs
local signs = { Error = "✘", Warn = "⚠", Hint = "➤", Info = "ℹ" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
  },
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- Fidget (LSP progress indicator)
require("fidget").setup({})
