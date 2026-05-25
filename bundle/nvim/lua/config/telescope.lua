-- Telescope configuration
local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<esc>"] = actions.close,
      },
      n = {
        ["q"] = actions.close,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
      },
    },
    file_ignore_patterns = {
      "node_modules",
      ".git/",
      "dist/",
      "build/",
      "target/",
      "%.lock",
    },
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        preview_width = 0.55,
        results_width = 0.8,
      },
      vertical = {
        mirror = false,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    path_display = { "truncate" },
    winblend = 0,
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    color_devicons = true,
    set_env = { ["COLORTERM"] = "truecolor" },
  },
  pickers = {
    find_files = {
      theme = "dropdown",
      previewer = false,
      hidden = true,
    },
    buffers = {
      theme = "dropdown",
      previewer = false,
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})

-- Load extensions
pcall(telescope.load_extension, "fzf")
