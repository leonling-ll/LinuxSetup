local M = {}

function M.config()
  -- Setup nvim-cmp.
  local cmp = require 'cmp'
  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        -- luasnip
        require('luasnip').lsp_expand(args.body)
        -- vsnip
        -- vim.fn["vsnip#anonymous"](args.body)
        -- snippy
        -- require('snippy').expand_snippet(args.body)
        -- ultisnip
        -- vim.fn["UltiSnips#Anon"](args.body)
      end,
    },
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-e>'] = cmp.mapping.abort(),
      -- Accept currently selected item...
      -- Set `select` to `false` to only confirm explicitly selected items:
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, { { name = 'buffer' } })
  })

  -- You can also set special config for specific filetypes:
  --    cmp.setup.filetype('gitcommit', {
  --        sources = cmp.config.sources({
  --            { name = 'cmp_git' },
  --        }, {
  --            { name = 'buffer' },
  --        })
  --    })

  -- nvim-cmp for commands
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local luasnip = require("luasnip")
  local cmp = require("cmp")

  cmp.setup({

    mapping = {

      ["<C-n>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<C-p>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),

      -- ... Your other mappings ...
    },

    -- ... Your other configuration ...
  })

  -- nvim-lspconfig config
  -- List of all pre-configured LSP servers:
  -- github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  vim.lsp.enable({ 'gopls', 'clangd', 'html', 'rust_analyzer', 'pylsp', 'lua_ls' })

  local devicons = require('nvim-web-devicons')
  cmp.register_source('devicons', {
    complete = function(_, _, callback)
      local items = {}
      for _, icon in pairs(devicons.get_icons()) do
        table.insert(items, {
          label = icon.icon .. '  ' .. icon.name,
          insertText = icon.icon,
          filterText = icon.name,
        })
      end
      callback({ items = items })
    end,
  })

  local saga = require 'lspsaga'

  -- change the lsp symbol kind
  --local kind = require('lspsaga.lspkind')
  --kind[type_number][2] = icon -- see lua/lspsaga/lspkind.lua

  saga.setup({
    ui = {
      border = "single",
      code_action = "",
    },
    lightbulb = {
      enable = true,
      sign = true,
      virtual_text = true,
      sign_priority = 20,
    },
    diagnostic = {
      diagnostic_only_current = false,
    },
    finder = {
      max_height = 0.6,
      keys = {
        open = "o",
        vsplit = "s",
        split = "i",
        tabnew = "t",
        quit = "q",
        scroll_down = "<C-f>",
        scroll_up = "<C-b>",
      },
    },
    code_action = {
      num_shortcut = true,
      keys = {
        quit = "q",
        exec = "<CR>",
      },
    },
    rename = {
      keys = {
        quit = "q",
      },
    },
    outline = {
      win_position = "right",
      win_width = 30,
      auto_preview = true,
      jump_key = "o",
      auto_refresh = true,
    },
    symbol_in_winbar = {
      enable = false,
      separator = " ",
      show_file = true,
    },
  })


end

return M
