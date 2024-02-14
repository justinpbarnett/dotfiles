-- This file contains global (non plugin-specific) settings.
vim.opt.number = true -- Line and relative line numbering
vim.opt.relativenumber = true

vim.opt.tabstop = 4 -- Configuring tab to 4 space indents
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false -- Line wrapping disabled

vim.opt.swapfile = false -- Disable backup (extremely bothering)
vim.opt.backup = false
vim.opt.undodir = os.getenv("USERPROFILE") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.writebackup = false

vim.opt.hlsearch = true -- Search options
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.isfname:append("@-@")

vim.opt.termguicolors = true -- Use terminal colors

vim.opt.scrolloff = 8 -- Scrolling\Vertical navigation options
vim.opt.sidescrolloff = 20
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 50 -- Fast update time
vim.opt.colorcolumn = "120" -- Set max-line-length column
vim.opt.spell = true
