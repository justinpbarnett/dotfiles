return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = { globals = { "vim" } },
            format = { enable = false },
          },
        },
      })

      vim.lsp.config("volar", {
        init_options = {
          vue = { hybridMode = false },
        },
      })

      vim.lsp.enable({
        "lua_ls",
        "basedpyright",
        "ruff",
        "clangd",
        "vtsls",
        "volar",
        "intelephense",
        "bashls",
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buf = args.buf
          local function bmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
          end

          bmap("n", "gd", vim.lsp.buf.definition, "Goto definition")
          bmap("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
          bmap("n", "gi", vim.lsp.buf.implementation, "Goto implementation")
          bmap("n", "gr", vim.lsp.buf.references, "References")
          bmap("n", "gt", vim.lsp.buf.type_definition, "Goto type definition")
          bmap("n", "K", vim.lsp.buf.hover, "Hover")
          bmap("n", "<leader>rn", vim.lsp.buf.rename, "LSP rename")
          bmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          bmap("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          bmap("n", "<leader>cs", vim.lsp.buf.signature_help, "Signature help")
        end,
      })
    end,
  },
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    opts = {},
  },
}
