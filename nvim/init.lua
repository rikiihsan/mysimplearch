-- ==================== NEOVIM LIGHTWEIGHT FULLSTACK CONFIG ====================
-- Optimized for low-resource systems (Celeron N4020, 4GB RAM)
-- Primary: Backend (Go, PHP, Python)
-- Secondary: Frontend (React, Svelte with TypeScript + Tailwind)
-- Last Updated: 2026

-- ==================== PERFORMANCE FIRST ====================
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.updatetime = 500        -- Reduced redraw frequency
vim.opt.timeoutlen = 500        -- Less aggressive which-key
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 200         -- Limit syntax highlighting width
vim.opt.redrawtime = 1500       -- Prevent slow redraw hangs

-- ==================== ESSENTIAL UI ====================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes:1"    -- Fixed width to prevent jumps
vim.opt.cursorline = false      -- Disabled for performance
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
vim.opt.colorcolumn = ""        -- Disabled (heavy on low-end CPUs)

-- ==================== EDITING ====================
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.breakindent = true      -- Lighter than linebreak

-- ==================== SEARCH & SYSTEM ====================
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false        -- Disabled (heavy on large files)
vim.opt.incsearch = true
vim.opt.clipboard = "unnamedplus"
vim.opt.hidden = true           -- Required for buffer management

-- ==================== SPLITS & NAVIGATION ====================
vim.opt.splitright = true
vim.opt.splitbelow = true

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

-- ==================== ESSENTIAL PLUGINS (LAZY-LOADED) ====================
require("lazy").setup({
  -- Core LSP (lazy-loaded on filetype)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mason").setup({ ui = { border = "single" } })
      
      -- ONLY install essential servers manually to avoid RAM bloat
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls", "pyright", "intelephense", "lua_ls",
          "ts_ls", "svelte", "tailwindcss", "emmet_ls"
        },
        automatic_installation = false,  -- Critical for low RAM
      })
    end,
  },

  -- Lightweight completion (no AI to save RAM/CPU)
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
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", keyword_length = 5, priority = 500 }, -- Higher threshold
          { name = "path", priority = 250 },
        }),
        formatting = { format = function(_, item) return item end },
        experimental = { ghost_text = false }, -- Disabled (heavy)
      })
      
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
  },

  -- Fuzzy finder (lazy-loaded, minimal config)
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = "➜ ",
          layout_strategy = "horizontal",
          layout_config = { width = 0.8, height = 0.7, preview_width = 0.5 },
          file_ignore_patterns = {
            "node_modules", ".git/", "vendor/", "__pycache__", "%.lock",
            "dist/", "build/", "%.min%.js", "%.min%.css"
          },
          sorting_strategy = "ascending",
          winblend = 0,  -- Disabled transparency (faster rendering)
        },
        pickers = {
          find_files = { hidden = true, no_ignore = false },
          live_grep = { additional_args = { "--hidden", "--no-ignore" } },
        },
      })
    end,
  },

  -- Minimal file explorer (lighter than neo-tree)
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30, side = "left" },
        renderer = {
          indent_markers = { enable = false }, -- Disabled (heavy)
          icons = { show = { file = true, folder = true } },
        },
        filters = { dotfiles = false, custom = { "node_modules" } },
        actions = { open_file = { resize_window = true } },
        git = { enable = true, ignore = false },
        diagnostics = { enable = true },
        update_focused_file = { enable = true },
        system_open = { cmd = nil },
      })
    end,
  },

  -- Essential syntax highlighting (selective parsers)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          -- Backend essentials
          "go", "python", "php", "lua",
          -- Frontend essentials
          "typescript", "tsx", "svelte", "html", "css",
          -- Configs
          "json", "yaml", "toml", "dockerfile",
        },
        sync_install = false,
        auto_install = false,  -- Prevent automatic installs
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
        incremental_selection = { enable = false }, -- Disabled (heavy)
        textobjects = { select = { enable = false } }, -- Disabled
      })
    end,
  },

  -- Lightweight git integration
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" }, change = { text = "│" }, delete = { text = "_" },
        },
        current_line_blame = false,  -- Disabled by default (toggle manually)
        sign_priority = 10,
        update_debounce = 1000,      -- Reduced update frequency
        status_formatter = nil,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          vim.keymap.set("n", "]c", function() gs.next_hunk() end, { buffer = bufnr })
          vim.keymap.set("n", "[c", function() gs.prev_hunk() end, { buffer = bufnr })
          vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { buffer = bufnr })
          vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { buffer = bufnr })
        end,
      })
    end,
  },

  -- Essential editing helpers
  {
    "numToStr/Comment.nvim",
    event = "BufRead",
    config = function() require("Comment").setup() end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = true, disable_filetype = { "TelescopePrompt" } })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript", "svelte" },
    config = function() require("nvim-ts-autotag").setup() end,
  },

  -- Minimal statusline (no bufferline to save RAM)
  {
    "nvim-lualine/lualine.nvim",
    event = "UIEnter",
    config = function()
      require("lualine").setup({
        options = { theme = "catppuccin", section_separators = "", component_separators = "" },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        extensions = { "nvim-tree" },
      })
    end,
  },

  -- Colorscheme (lightweight setup)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,  -- Reduces redraw overhead
        integrations = { treesitter = true, native_lsp = true },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Essential key discovery
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        plugins = { spelling = { enabled = false } },
        window = { border = "single" },
      })
    end,
  },
}, {
  -- CRITICAL PERFORMANCE SETTINGS FOR LAZY.NVIM
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "zipPlugin", "tarPlugin", "tohtml", "tutor", "optwin",
        "matchit", "matchparen", "netrwPlugin", "rplugin",
      },
    },
    reset_packpath = true,
    cache = {
      enabled = true,
      path = vim.fn.stdpath("cache") .. "/lazy",
    },
  },
  defaults = { lazy = true },  -- Default all plugins to lazy loading
})

-- ==================== LSP SETUP (OPTIMIZED) ====================
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Disable heavy LSP features
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.foldingRange = nil  -- Disable folding (heavy)
capabilities.textDocument.documentSymbol = nil -- Disable symbols (heavy)

local on_attach = function(client, bufnr)
  -- Disable heavy features per server
  if client.name == "ts_ls" or client.name == "svelte" then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end

  local opts = { buffer = bufnr, silent = true }
  
  -- Essential keymaps only
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
end

-- Minimal server configs (disable heavy features)
local servers = {
  gopls = { settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true } } },
  pyright = { settings = { python = { analysis = { typeCheckingMode = "off" } } } }, -- Disabled type checking
  intelephense = { settings = { intelephense = { files = { maxSize = 1000000 } } } },
  lua_ls = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
  ts_ls = { settings = { typescript = { inlayHints = { includeInlayParameterNameHints = "none" } } } }, -- Disabled hints
  tailwindcss = {},
  emmet_ls = { filetypes = { "html", "css", "javascript", "typescript", "svelte" } },
}

for name, config in pairs(servers) do
  config.on_attach = on_attach
  config.capabilities = capabilities
  lspconfig[name].setup(config)
end

-- Minimal diagnostics
vim.diagnostic.config({
  virtual_text = false,  -- CRITICAL: Disabled virtual text (heavy on low RAM)
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- ==================== KEYMAPS (OPTIMIZED) ====================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Essential navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Down window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Up window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Right window" })

-- File operations
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Buffers" })

-- Buffer management (lightweight alternative to bufferline)
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Close buffer" })

-- Git
vim.keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle blame" })

-- Save/quit
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- ==================== AUTOCOMMANDS (PERFORMANCE OPTIMIZED) ====================
-- Remove trailing whitespace ONLY on save (not continuously)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Restore cursor position (lightweight version)
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- Format on save ONLY for backend files (frontend formatting is slow)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.go", "*.py", "*.php" },
  callback = function() vim.lsp.buf.format({ async = true }) end,
})

-- Disable syntax sync for large files (>5000 lines)
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    if vim.api.nvim_buf_line_count(0) > 5000 then
      vim.opt_local.synmaxcol = 100
      vim.opt_local.syntax = "off"
    end
  end,
})

-- ==================== FILETYPE OVERRIDES ====================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "svelte", "css" },
  callback = function() 
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

print("⚡ Neovim Lightweight Config Loaded (Optimized for 4GB RAM)")