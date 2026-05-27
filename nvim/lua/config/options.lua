local opt = vim.opt

-- Always use the OS clipboard provider for +/* registers. Without this, Neovim
-- can fall back to OSC52, which writes to the terminal clipboard instead of the
-- machine clipboard in some terminal/tmux setups.
if vim.fn.executable("pbcopy") == 1 and vim.fn.executable("pbpaste") == 1 then
  vim.g.clipboard = {
    name = "macOS clipboard",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 0,
  }
elseif vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
  vim.g.clipboard = {
    name = "wayland clipboard",
    copy = {
      ["+"] = { "wl-copy", "--foreground", "--type", "text/plain" },
      ["*"] = { "wl-copy", "--foreground", "--primary", "--type", "text/plain" },
    },
    paste = {
      ["+"] = { "wl-paste", "--no-newline" },
      ["*"] = { "wl-paste", "--no-newline", "--primary" },
    },
    cache_enabled = 0,
  }
elseif vim.fn.executable("xclip") == 1 then
  vim.g.clipboard = {
    name = "xclip clipboard",
    copy = {
      ["+"] = { "xclip", "-selection", "clipboard" },
      ["*"] = { "xclip", "-selection", "primary" },
    },
    paste = {
      ["+"] = { "xclip", "-selection", "clipboard", "-o" },
      ["*"] = { "xclip", "-selection", "primary", "-o" },
    },
    cache_enabled = 0,
  }
end

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.colorcolumn = "80"
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

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "1"

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
