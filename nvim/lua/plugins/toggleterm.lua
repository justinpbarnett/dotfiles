return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<leader>t]],
        direction = "float",
        float_opts = {
          border = "rounded",
          width = function() return math.floor(vim.o.columns * 0.8) end,
          height = function() return math.floor(vim.o.lines * 0.8) end,
        },
      })
      vim.keymap.set("t", "<Esc>", "<C-\\><C-n>:ToggleTerm<CR>", { desc = "Close floating terminal" })
    end,
  },
}
