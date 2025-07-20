return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato", -- latte, frappe, macchiato, mocha
        transparent_background = true,
        integrations = {
          telescope = true,
          harpoon = true,
          mason = true,
          treesitter = true,
          lsp_trouble = false,
          which_key = false,
          native_lsp = {
            enabled = true,
          },
          -- Add more if needed
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
