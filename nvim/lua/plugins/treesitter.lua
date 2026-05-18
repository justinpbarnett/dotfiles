return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local parsers = {
      "lua", "vim", "vimdoc", "query",
      "c", "cpp", "c_sharp",
      "python",
      "php", "phpdoc",
      "typescript", "javascript", "tsx", "vue",
      "html", "css",
      "json", "yaml", "toml",
      "markdown", "markdown_inline",
      "bash",
      "gitcommit", "gitignore", "diff",
      "regex",
    }

    require("nvim-treesitter").install(parsers)

    local filetypes = {
      "lua", "vim", "help", "query",
      "c", "cpp", "cs",
      "python",
      "php",
      "typescript", "javascript", "tsx", "typescriptreact", "javascriptreact", "vue",
      "html", "css",
      "json", "jsonc", "yaml", "toml",
      "markdown",
      "bash", "sh", "zsh",
      "gitcommit", "gitignore", "diff",
    }

    vim.api.nvim_create_autocmd("FileType", {
      pattern = filetypes,
      callback = function(args)
        pcall(vim.treesitter.start)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
