-- Plugin specifications for lazy.nvim
return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
    },
    config = function()
      require("config.lsp")
    end,
  },

  -- Mason for LSP/DAP/Linter installer
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("config.cmp")
    end,
  },

  -- Snippet Engine
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("config.treesitter")
    end,
  },

  -- Fuzzy Finder (Telescope)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    config = function()
      require("config.telescope")
    end,
  },

  -- File Explorer (modern alternative to NERDTree)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      })
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "material",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Bufferline (tabs)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "slant",
          diagnostics = "nvim_lsp",
        },
      })
    end,
  },

  -- Git integration
  {
    "tpope/vim-fugitive",
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Linting & Formatting
  {
    "dense-analysis/ale",
    config = function()
      vim.g.ale_echo_msg_format = "[%linter%] %s [%severity%]"
      vim.g.ale_sign_error = "✘"
      vim.g.ale_sign_warning = "⚠"
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
          char = "⦙",
        },
      })
    end,
  },

  -- Colorscheme
  {
    "marko-cerovac/material.nvim",
    priority = 1000,
    config = function()
      vim.g.material_style = "darker"
      require("material").setup({
        contrast = {
          terminal = false,
          sidebars = false,
          floating_windows = false,
          cursor_line = false,
          non_current_windows = false,
          filetypes = {},
        },
        styles = {
          comments = { italic = true },
          strings = { italic = false },
          keywords = { italic = false },
          functions = { bold = false },
          variables = {},
          operators = {},
          types = {},
        },
        plugins = {
          "telescope",
          "nvim-tree",
          "gitsigns",
          "nvim-cmp",
        },
      })
      vim.cmd("colorscheme material")
    end,
  },

  -- Language-specific plugins
  {
    "dag/vim-fish",
    ft = "fish",
  },

  {
    "rodjek/vim-puppet",
    ft = "puppet",
  },

  -- Python folding
  {
    "tmhedberg/SimpylFold",
    ft = "python",
    config = function()
      vim.g.SimpylFold_docstring_preview = 1
    end,
  },

  -- Python indentation
  {
    "vim-scripts/indentpython.vim",
    ft = "python",
  },

  -- PlantUML
  {
    "aklt/plantuml-syntax",
    ft = "plantuml",
  },

  {
    "weirongxu/plantuml-previewer.vim",
    ft = "plantuml",
    dependencies = {
      "tyru/open-browser.vim",
    },
  },

  -- Password store integration
  {
    "cz8s/password-store",
  },

  -- Tmux integration
  {
    "edkolev/tmuxline.vim",
  },

  -- Comment support
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Which-key for keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end,
  },
}
