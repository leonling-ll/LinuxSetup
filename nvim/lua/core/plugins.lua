-- Setup lazy.nvim
require("lazy").setup({
  -- spec = {
  --   -- import your plugins
  --   { import = "plugins" },
  -- },
  -- -- Configure any other settings here. See the documentation for more details.
  -- -- colorscheme that will be used when installing plugins.
  -- install = { colorscheme = { "habamax" } },
  -- -- automatically check for plugin updates
  -- checker = { enabled = true },

  -- starup time optimise
  "dstein64/vim-startuptime",
  "lewis6991/impatient.nvim",
  "nathom/filetype.nvim",

  -- themes (disabled other themes to optimize startup time)
  "navarasu/onedark.nvim",
  "rmehri01/onenord.nvim",
  "folke/tokyonight.nvim",
  "AlexvZyl/nordic.nvim",
  "rebelot/kanagawa.nvim",

  -- buffer
  "nvim-tree/nvim-web-devicons",
  "akinsho/bufferline.nvim",
  "moll/vim-bbye", -- for more sensible delete buffer cmd

  -- file tree
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },

  -- language
  "neovim/nvim-lspconfig",
  "glepnir/lspsaga.nvim",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/nvim-cmp",
  "L3MON4D3/LuaSnip",
  "nvim-treesitter/nvim-treesitter",
  "HiPhish/nvim-ts-rainbow2",
  "tell-k/vim-autopep8",

  -- git
  "lewis6991/gitsigns.nvim",
  "apzelos/blamer.nvim",

  -- status line
  "nvim-lualine/lualine.nvim",

  -- tagbar
  "simrat39/symbols-outline.nvim",

  -- floating terminal
  "voldikss/vim-floaterm",

  -- file telescope
  "nvim-lua/plenary.nvim",
  "BurntSushi/ripgrep",
  "nvim-telescope/telescope.nvim",

  -- editor
  "easymotion/vim-easymotion",

  -- Commenter
  "numToStr/Comment.nvim",

  -- english grammar check
  "rhysd/vim-grammarous",
})
