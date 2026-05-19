return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<C-/>", "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Toggle terminal" },
    { "<C-_>", "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Toggle terminal" },
  },
  opts = {
    direction = "horizontal",
    size = 15,
    shade_terminals = false,
    start_in_insert = true,
    persist_mode = true,
    on_open = function(term)
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { buffer = term.bufnr, desc = "Terminal normal mode" })
    end,
  },
}
