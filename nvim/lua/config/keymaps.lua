local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Write buffer" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })

map("n", "<leader>o", function()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end
  vim.ui.open(file)
end, { desc = "Open current file in browser" })

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

local function nvim_log_path()
  return vim.env.NVIM_LOG_FILE or (vim.fn.stdpath("log") .. "/log")
end

local function is_log_header(line)
  return line:match("^%u%u%u %d%d%d%d%-") ~= nil
end

local function yank_to_clipboard(text, label, n)
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)
  vim.notify("Copied " .. label .. " (" .. n .. " lines) to clipboard")
end

map("n", "<leader>ll", function()
  local path = nvim_log_path()
  if vim.fn.filereadable(path) == 0 then
    vim.notify("nvim log not found at " .. path, vim.log.levels.WARN)
    return
  end
  vim.cmd("split " .. vim.fn.fnameescape(path))
  vim.cmd("normal! G")
end, { desc = "Open nvim error log" })

local function yank_latest_log_entry(match_fn, label)
  local path = nvim_log_path()
  if vim.fn.filereadable(path) == 0 then
    vim.notify("nvim log not found at " .. path, vim.log.levels.WARN)
    return
  end
  local lines = vim.fn.readfile(path)
  local start
  for i = #lines, 1, -1 do
    if match_fn(lines[i]) then
      start = i
      break
    end
  end
  if not start then
    vim.notify("No " .. label .. " entries in nvim log", vim.log.levels.INFO)
    return
  end
  local block = { lines[start] }
  for j = start + 1, #lines do
    if is_log_header(lines[j]) then break end
    table.insert(block, lines[j])
  end
  yank_to_clipboard(table.concat(block, "\n"), "latest " .. label, #block)
end

local function is_err(line) return line:match("^ERR ") ~= nil end
local function is_warn(line) return line:match("^WRN ") ~= nil end

map("n", "<leader>le", function() yank_latest_log_entry(is_err, "error") end, { desc = "Yank latest nvim error" })
map("n", "<leader>lw", function() yank_latest_log_entry(is_warn, "warning") end, { desc = "Yank latest nvim warning" })
local function looks_problematic(line)
  if line:match("^E%d+:") or line:match("^W%d+:") then return true end
  local l = line:lower()
  return l:find("error", 1, true)
    or l:find("warn", 1, true)
    or l:find("fail", 1, true)
    or l:find("not found", 1, true)
    or l:find("not on path", 1, true)
end

map("n", "<leader>ly", function()
  local out = vim.api.nvim_exec2("messages", { output = true }).output
  if out == "" then
    vim.notify("No :messages output", vim.log.levels.INFO)
    return
  end
  local lines = vim.split(out, "\n", { plain = true })
  local start
  for i = #lines, 1, -1 do
    if looks_problematic(lines[i]) then
      start = i
      break
    end
  end
  if not start then
    vim.notify("No error/warning found in :messages", vim.log.levels.INFO)
    return
  end
  local block = {}
  for j = start, #lines do
    table.insert(block, lines[j])
  end
  yank_to_clipboard(table.concat(block, "\n"), "latest message error/warning", #block)
end, { desc = "Yank latest error/warning from :messages" })

map("n", "<leader>lm", "<cmd>messages<cr>", { desc = "Show :messages" })

map("n", "<leader>lM", function()
  local out = vim.api.nvim_exec2("messages", { output = true }).output
  if out == "" then
    vim.notify("No :messages output", vim.log.levels.INFO)
    return
  end
  yank_to_clipboard(out, ":messages", #vim.split(out, "\n", { plain = true }))
end, { desc = "Yank :messages to clipboard" })

map("n", "<leader>lL", function()
  local path = vim.fn.stdpath("state") .. "/lsp.log"
  if vim.fn.filereadable(path) == 0 then
    vim.notify("LSP log not found at " .. path, vim.log.levels.WARN)
    return
  end
  vim.cmd("split " .. vim.fn.fnameescape(path))
  vim.cmd("normal! G")
end, { desc = "Open LSP log" })

map("n", "<leader>za", "za", { desc = "Toggle fold" })
map("n", "<leader>zc", "zc", { desc = "Close fold" })
map("n", "<leader>zo", "zo", { desc = "Open fold" })
map("n", "<leader>zA", "zA", { desc = "Toggle fold recursively" })
map("n", "<leader>zM", "zM", { desc = "Fold all" })
map("n", "<leader>zR", "zR", { desc = "Unfold all" })
map("v", "<leader>zf", "zf", { desc = "Create fold from selection" })
map("v", "<leader>zd", "zd", { desc = "Delete fold from selection" })
map("n", "[z", "[z", { desc = "Previous fold" })
map("n", "]z", "]z", { desc = "Next fold" })
