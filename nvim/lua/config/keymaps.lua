local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Write buffer" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split vertical" })

local function push_divider(axis, sign)
  local probe = axis == "h" and "l" or "j"
  local has_next = vim.fn.winnr() ~= vim.fn.winnr(probe)
  local delta = has_next and sign or -sign
  local cmd = axis == "h" and "vertical resize " or "resize "
  vim.cmd(cmd .. (delta > 0 and "+" or "") .. delta * 2)
end

map("n", "<C-Right>", function() push_divider("h", 1) end, { desc = "Push split divider right" })
map("n", "<C-Left>", function() push_divider("h", -1) end, { desc = "Push split divider left" })
map("n", "<C-Down>", function() push_divider("v", 1) end, { desc = "Push split divider down" })
map("n", "<C-Up>", function() push_divider("v", -1) end, { desc = "Push split divider up" })
map("n", "<C-x>", "<cmd>close<cr>", { desc = "Close split" })

map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
map("n", "[e", function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end, { desc = "Previous error" })
map("n", "]e", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end, { desc = "Next error" })

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
