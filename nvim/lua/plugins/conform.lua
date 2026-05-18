return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    { "<leader>cf", function() require("conform").format({ async = true }) end, mode = { "n", "v" }, desc = "Format buffer" },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format", "ruff_organize_imports" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      vue = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      c = { "clang-format" },
      cpp = { "clang-format" },
      cs = { "csharpier" },
      php = { "pint" },
    },
    format_on_save = {
      lsp_format = "fallback",
      timeout_ms = 1000,
    },
  },
}
