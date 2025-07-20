return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          php = { "php-cs-fixer" }, -- or pint for Laravel
          -- cs = { "csharpier" }, -- Disabled, using LSP formatting instead
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
      vim.keymap.set("n", "<leader>fm", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Format file" })
    end,
  },
}
