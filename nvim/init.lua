-- ==================== LIGHTWEIGHT NEOVIM CONFIG ====================
-- Optimized for: 4GB RAM + Intel Celeron N4020
-- Focus: Fullstack Development (Go, PHP, Python + React, Svelte)
-- Performance: Minimal plugins, lazy loading, low resource usage

-- ==================== LEADER KEY ====================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ==================== PERFORMANCE SETTINGS ====================
vim.opt.updatetime = 300        -- Balanced update time
vim.opt.timeoutlen = 400        -- Slightly longer timeout
vim.opt.lazyredraw = true       -- Don't redraw during macros
vim.opt.ttyfast = true          -- Fast terminal
vim.opt.synmaxcol = 200         -- Don't syntax highlight super long lines
vim.opt.regexpengine = 1        -- Use old regex engine (faster)

-- ==================== UI SETTINGS ====================
vim.opt.number = true           -- Line numbers
vim.opt.relativenumber = false  -- Disabled for performance
vim.opt.signcolumn = "yes"      -- Always show sign column
vim.opt.cursorline = true       -- Highlight current line
vim.opt.scrolloff = 4           -- Keep 4 lines above/below cursor
vim.opt.sidescrolloff = 4       -- Keep 4 columns left/right
vim.opt.colorcolumn = "80"      -- Single column marker

-- ==================== EDITING ====================
vim.opt.expandtab = true        -- Use spaces
vim.opt.shiftwidth = 4          -- Indent size (backend default)
vim.opt.tabstop = 4             -- Tab display size
vim.opt.softtabstop = 4         -- Tab in insert mode
vim.opt.smartindent = true      -- Auto indent
vim.opt.wrap = false            -- No line wrap

-- ==================== SEARCH ====================
vim.opt.ignorecase = true       -- Case insensitive
vim.opt.smartcase = true        -- Unless capital used
vim.opt.hlsearch = true         -- Highlight search
vim.opt.incsearch = true        -- Incremental search

-- ==================== SYSTEM ====================
vim.opt.clipboard = "unnamedplus"  -- System clipboard
vim.opt.undofile = true            -- Persistent undo
vim.opt.undolevels = 5000          -- Reduced for memory
vim.opt.swapfile = false           -- No swap files
vim.opt.backup = false             -- No backup files

-- ==================== SPLITS ====================
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ==================== COMPLETION ====================
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.pumheight = 10             -- Smaller popup menu

-- ==================== PLUGIN MANAGER (lazy.nvim) ====================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==================== PLUGINS (MINIMAL & ESSENTIAL) ====================
require("lazy").setup({
  -- LSP (Essential)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- Autocompletion (Lightweight)
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- Fuzzy Finder (Essential)
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          prompt_prefix = " > ",
          selection_caret = " ",
          layout_config = { height = 0.8, width = 0.8 },
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "vendor/",
            "%.lock",
            "__pycache__",
          },
        },
      })
    end,
  },

  -- File Explorer (Lightweight alternative)
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = {
          root_folder_label = false,
          icons = {
            show = { git = true, folder = true, file = true },
            glyphs = {
              default = "",
              folder = {
                default = "",
                open = "",
                empty = "",
                empty_open = "",
              },
            },
          },
        },
        filters = {
          dotfiles = false,
          custom = { "^.git$" },
        },
        git = { enable = true },
        update_focused_file = { enable = false },
      })
    end,
  },

  -- Treesitter (Syntax - Only essential languages)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = {
          -- Backend (Primary)
          "go", "python", "php",
          -- Frontend (Secondary)
          "javascript", "typescript", "tsx", "svelte",
          "html", "css",
          -- Essential
          "json", "markdown", "bash",
        },
        sync_install = false,
        auto_install = false,  -- Disabled for performance
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Git signs (Lightweight)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "-" },
        },
        current_line_blame = false,
      })
    end,
  },

  -- Comment
  {
    "numToStr/Comment.nvim",
    keys = { "gcc", "gbc", { "gc", mode = "v" } },
    config = true,
  },

  -- Auto pairs (Lightweight)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = false })
    end,
  },

  -- Auto close tags (Only for web files)
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" },
    config = true,
  },

  -- Tailwind colorizer (Only for CSS files)
  {
    "NvChad/nvim-colorizer.lua",
    ft = { "css", "scss", "html", "javascript", "typescript", "typescriptreact", "javascriptreact", "svelte" },
    config = function()
      require("colorizer").setup({
        filetypes = { "css", "scss", "html", "javascript", "typescript", "typescriptreact", "javascriptreact", "svelte" },
        user_default_options = {
          tailwind = true,
          mode = "background",
        },
      })
    end,
  },

  -- Colorscheme (Lightweight)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        integrations = {
          treesitter = true,
          cmp = true,
          gitsigns = true,
          telescope = false,
          native_lsp = { enabled = true },
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
})

-- ==================== LSP SETUP ====================
require("mason").setup({
  ui = { border = "rounded" },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    -- Backend (Primary)
    "gopls",        -- Go
    "pyright",      -- Python
    "intelephense", -- PHP
    -- Frontend (Secondary)
    "ts_ls",        -- TypeScript/JavaScript
    "svelte",       -- Svelte
    "tailwindcss",  -- Tailwind
    "html",         -- HTML
    "cssls",        -- CSS
  },
  automatic_installation = true,
})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- LSP keymaps
local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
end

-- Setup LSP servers
local servers = {
  gopls = {},
  pyright = {},
  intelephense = {},
  ts_ls = {},
  svelte = {},
  tailwindcss = {},
  html = {},
  cssls = {},
}

for server, config in pairs(servers) do
  config.on_attach = on_attach
  config.capabilities = capabilities
  lspconfig[server].setup(config)
end

-- Diagnostic config
vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Diagnostic signs
local signs = { Error = "✗", Warn = "!", Hint = "»", Info = "i" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

-- ==================== AUTOCOMPLETION ====================
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer", keyword_length = 3 },
    { name = "path" },
  },
})

-- ==================== KEYMAPS ====================

-- General
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true })
vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a")
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")

-- Window splits
vim.keymap.set("n", "<leader>v", ":vsplit<CR>")
vim.keymap.set("n", "<leader>h", ":split<CR>")
vim.keymap.set("n", "<leader>x", ":close<CR>")

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Buffer management
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>")
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>")

-- File explorer
vim.keymap.set("n", "-", ":NvimTreeToggle<CR>")

-- Telescope
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope.find_files)
vim.keymap.set("n", "<leader>fg", telescope.live_grep)
vim.keymap.set("n", "<leader>fb", telescope.buffers)
vim.keymap.set("n", "<leader>fr", telescope.oldfiles)

-- Git
vim.keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>")
vim.keymap.set("n", "]c", ":Gitsigns next_hunk<CR>")
vim.keymap.set("n", "[c", ":Gitsigns prev_hunk<CR>")

-- Visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Copy/Paste (System clipboard)
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>y", '"+yy')
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')

-- Better paste
vim.keymap.set("v", "p", '"_dP')

-- Center on navigation
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- ==================== AUTOCOMMANDS ====================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

-- Remove trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto format on save (backend files only)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.go", "*.py", "*.php" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Set 2-space indent for frontend files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "typescriptreact", "javascriptreact", "svelte", "html", "css" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

print("⚡ Lightweight Neovim Config Loaded!")
