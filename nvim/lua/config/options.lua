local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.smartindent = true

opt.wrap = false
opt.linebreak = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = false

opt.splitright = true
opt.splitbelow = true

opt.clipboard = "unnamedplus"

opt.undofile = true
opt.swapfile = false
opt.backup = false

opt.termguicolors = true
opt.background = "dark"

opt.updatetime = 250
opt.timeoutlen = 400

opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 12

opt.mouse = "a"
opt.confirm = true

opt.belloff = "all"
opt.visualbell = false
opt.errorbells = false

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  float = { border = "rounded", source = "if_many" },
})
