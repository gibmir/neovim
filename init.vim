set encoding=utf-8
set number relativenumber
set scrolloff=7
set colorcolumn=100
set guifont=Hack:14
call plug#begin('~/AppData/Local/nvim/plugged')
" below are some vim plugins for demonstration purpose.
" add the plugin you want to use here.
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
" Don't forget to install the fonts(for example DroidSansMono Nerd Font)
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'
" Debug
Plug 'sebdah/vim-delve'
" Git
Plug 'lewis6991/gitsigns.nvim'
" Autocompletion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'
call plug#end()
" airline
let g:airline_powerline_fonts = 1
" Colorscheme
let g:tokyonight_style = "storm"
colorscheme tokyonight
" Key Mappings
" NERDTree
nnoremap <silent> <Space> :NERDTreeToggle<CR>
" Telescope. Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

lua <<EOF
  require('gitsigns').setup()
  -- LSP
  lspconfig = require "lspconfig"
  util = require "lspconfig/util"
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
  -- Mappings.
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  local opts = { noremap=true, silent=true }
  vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  end

  -- Use a loop to conveniently call 'setup' on multiple servers and
  -- map buffer local keybindings when the language server attaches
  -- default lsp config
  local servers = { 'gopls', 'pyright' }
  for _, lsp in pairs(servers) do
    if string.find(lsp, 'gopls') then
      -- golang
      require'lspconfig'.gopls.setup { 
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
          -- This will be the default in neovim 0.7+
          debounce_text_changes = 150,
        },
        cmd = {"gopls"},
        filetypes = {"go", "gomod", "gotmpl"},
	single_file_support = true,
        root_dir = util.root_pattern("go.work", "go.mod", ".git"),
	docs = {
          description = [[
            https://github.com/golang/tools/tree/master/gopls
            Google's lsp server for golang.
          ]],
	},
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
    }  
    elseif string.find(lsp, 'pyright') then
      -- pyright
      local bin_name = 'pyright-langserver'
      local cmd = { bin_name, '--stdio' }

      if vim.fn.has 'win32' == 1 then
        cmd = { 'cmd.exe', '/C', bin_name, '--stdio' }
      end
      local root_files = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
      }
      require'lspconfig'.pylsp.setup {
        cmd = cmd,
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
          -- This will be the default in neovim 0.7+
          debounce_text_changes = 150,
        },
	filetypes = {"python"},
	single_file_support = true,
	root_dir = util.root_pattern(unpack(root_files)),
	docs = {
          description = [[
            https://github.com/microsoft/pyright

            `pyright`, a static type checker and language server for python
          ]],
        },
	settings = {
		python = {
		  analysis = {
		    autoSearchPaths = true,
		    diagnosticMode = "workspace",
		    useLibraryCodeForTypes = true
	          },
	        },
	},
      }
    end
  end
  -- autocomplete
  local luasnip = require 'luasnip'
  local cmp = require 'cmp'
  cmp.setup {
    on_attach = on_attach,
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    mapping = {
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ['<Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end,
      ['<S-Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end,
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    },
  }
EOF
