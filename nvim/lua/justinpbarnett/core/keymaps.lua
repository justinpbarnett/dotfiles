local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
local keymap = vim.keymap.set

keymap("", "<Space>", "<Nop>", opts) -- Leader key remapping to <Space>
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("n", "<C-p>", vim.cmd.Ex, opts) -- Open file explorer
keymap("n", "J", "mzJ`z") -- Join lines without moving cursor
keymap("n", "<C-d>", "<C-d>zz") -- Center view when scrolling or searching
keymap("n", "<C-u>", "<C-u>zz")
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")
keymap("n", "Q", "<nop>") -- Disable Q key
keymap("n", '"', "<nop>")
keymap("n", "<leader>y", '"+y') -- Copy to system clipboard
keymap("n", "<leader>Y", '"+Y')
keymap("n", "<leader>d", '"_d') -- Delete to void register
keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- Replace word
keymap("n", "<leader>h", ":nohl<CR>", opts) -- Remove highlighting
keymap("n", "<leader>x", "<cmd>!chmod +x %<CR>", term_opts) -- Make current file executable
-- keymap("n", "<C-f>", "<cmd>silent !tmux neww ~/.local/bin/tmux-sessionizer<CR>")

keymap("i", "<C-c>", "<ESC>", opts) -- Escape insert mode

keymap("v", "<", "<gv", opts) -- Indent
keymap("v", ">", ">gv", opts)
keymap("v", "<leader>y", '"+y') -- Copy to system clipboard
keymap("v", "<leader>d", '"_d') -- Delete to void register

keymap("x", "J", ":move '>+1<CR>gv-gv", opts) -- Move text up and down
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<leader>p", [["_dP]], opts) -- Disable bad vim paste behaviour
