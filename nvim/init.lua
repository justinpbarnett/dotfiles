-- ~/ config/nvim/init.lua

-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup
require("lazy").setup({
    -- Mason and LSP
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },

    -- Async HTTP requests
    { "nvim-lua/plenary.nvim" },

    -- Fuzzy finding
    { "junegunn/fzf",                     build = "./install --all" },
    { "junegunn/fzf.vim" },
    { "nvim-telescope/telescope.nvim",    dependencies = { "nvim-lua/plenary.nvim" } },

    -- Syntax highlighting and code parsing
    { "nvim-treesitter/nvim-treesitter",  build = ":TSUpdate" },

    -- File explorer
    { "nvim-tree/nvim-tree.lua",          dependencies = { "nvim-tree/nvim-web-devicons" } },

    -- Statusline
    { "nvim-lualine/lualine.nvim",        dependencies = { "nvim-tree/nvim-web-devicons" } },

    -- Colorscheme
    { "catppuccin/nvim",                  name = "catppuccin" },

    -- Git integration
    { "lewis6991/gitsigns.nvim" },

    -- Commenting
    { "numToStr/Comment.nvim" },

    -- Autocompletion
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },

    -- Auto-formatting
    { "stevearc/conform.nvim" },
    { "hrsh7th/vim-vsnip" },

    -- Cursor AI equivalent
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
        opts = {
            -- add any opts here
            -- for example
            provider = "claude",
            claude = {
                endpoint = "https://api.anthropic.com/",
                model = "claude-3-7-sonnet-latest", -- your desired model (or use gpt-4o, etc.)
                timeout = 30000,                    -- timeout in milliseconds
                temperature = 0,                    -- adjust if needed
                max_tokens = 4096,
                disable_tools = true,
                -- reasoning_effort = "high" -- only supported for reasoning models (o1, etc.)
            },
        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "echasnovski/mini.pick",         -- for file_selector provider mini.pick
            "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
            "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
            "ibhagwan/fzf-lua",              -- for file_selector provider fzf
            "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua",        -- for providers='copilot'
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    }
}, {
    performance = {
        rtp = {
            disabled_plugins = { "netrw", "netrwPlugin" },
        },
    },
})

-- Plugin configurations
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",    -- Lua
        "pyright",   -- Python
        "ts_ls",     -- JavaScript/TypeScript
        "omnisharp", -- C#
        "sqlls",     -- SQL
        "bashls"     -- Bash
    },
    automatic_installation = true,
})

-- LSP setup
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local servers = { "lua_ls", "pyright", "ts_ls", "omnisharp", "sqlls", "bashls" }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup({
        capabilities = capabilities,
    })
end

lspconfig.omnisharp.setup({
    capabilities = capabilities,
    cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
    root_dir = lspconfig.util.root_pattern("*.csproj", "*.sln"),
})

require("nvim-treesitter.configs").setup({
    ensure_installed = { "lua", "python", "javascript", "typescript", "c_sharp", "sql", "bash" },
    highlight = { enable = true },
    incremental_selection = { enable = true },
    indent = { enable = true },
})

require("nvim-tree").setup({
    view = { width = 30 },
    filters = { dotfiles = false },
})

require("lualine").setup({
    options = { theme = "catppuccin-macchiato" },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
})

require("catppuccin").setup({
    flavour = "macchiato",
    term_colors = true,
    transparent_background = false,
    integrations = {
        mason = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
        gitsigns = true,
        cmp = true,
    },
})
vim.cmd("colorscheme catppuccin")

require("gitsigns").setup({
    signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
    },
})

require("Comment").setup()

-- Autocompletion setup
local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- Requires vim-vsnip (optional)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-y>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
    }),
})
cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "cmdline" },
    },
})

-- Auto-formatting setup with conform.nvim
-- Auto-formatting setup with conform.nvim
require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        csharp = { "csharpier" },
        sql = { "sql-formatter" },
        bash = { "shfmt" },
    },
    formatters = {
        stylua = { prepend_args = { "--column-width", "120" } },
        black = { prepend_args = { "--line-length", "120" } },
        prettier = { prepend_args = { "--print-width", "120" } },
        csharpier = { prepend_args = { "--write-stdout", "--max-line-length", "120" } },                          -- Note: csharpier’s max-line-length is experimental
        shfmt = { prepend_args = { "-l", "-w", "-i", "2", "-p", "-bn", "-ci", "-sr", "-kp", "-maxlen", "120" } },
        ["sql-formatter"] = { prepend_args = { "--config", vim.fn.stdpath("config") .. "/sql-formatter.json" } }, -- Custom config file needed
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
    },
})

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.isfname:append("@-@")

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 20
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "120"

vim.opt.laststatus = 3 -- views can only be fully collapsed with the global statusline
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo')

vim.opt.updatetime = 50
vim.opt.spell = true

-- Clipboard setup for WSL
if vim.fn.has("wsl") == 1 then
    local win32yank = "/usr/local/bin/win32yank.exe"
    if vim.fn.executable(win32yank) == 1 then
        vim.g.clipboard = {
            name = "win32yank-wsl",
            copy = {
                ["+"] = { win32yank, "-i", "--crlf" },
                ["*"] = { win32yank, "-i", "--crlf" },
            },
            paste = {
                ["+"] = { win32yank, "-o", "--lf" },
                ["*"] = { win32yank, "-o", "--lf" },
            },
            cache_enabled = 0,
        }
    else
        vim.notify("win32yank.exe not found or not executable at " .. win32yank, vim.log.levels.WARN)
    end
end
vim.opt.clipboard:append("unnamedplus")

-- Keymaps
vim.keymap.set("n", "<leader>m", ":Mason<CR>", { desc = "Open Mason" })
vim.keymap.set("n", "<leader>f", ":Files<CR>", { noremap = true, silent = true, desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>g", "<cmd>Telescope live_grep<CR>", { noremap = true, silent = true, desc = "Grep files" })
vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<CR>", { noremap = true, silent = true, desc = "Find buffers" })
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>",
    { noremap = true, silent = true, desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>h", "<cmd>Telescope help_tags<CR>", { noremap = true, silent = true, desc = "Search help" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { noremap = true, silent = true, desc = "Rename symbol" })
vim.keymap.set("n", "<leader>n", ":nohlsearch<CR>", { noremap = true, silent = true, desc = "Clear highlight" })
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- Replace word
vim.keymap.set("v", "<", "<gv", opts)                                                    -- Indent
vim.keymap.set("v", ">", ">gv", opts)
vim.keymap.set("i", "<C-c>", "<ESC>", opts)                                              -- Escape insert mode
vim.keymap.set("n", "J", "mzJ`z")                                                        -- Join lines without moving cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz")                                                  -- Center view when scrolling or searching
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
