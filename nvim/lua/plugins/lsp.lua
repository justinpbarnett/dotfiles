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

      local function clangd_path()
        for _, p in ipairs({ "/opt/homebrew/opt/llvm/bin/clangd", "/usr/local/opt/llvm/bin/clangd" }) do
          if vim.fn.executable(p) == 1 then return p end
        end
        return "clangd"
      end
      vim.lsp.config("clangd", { cmd = { clangd_path(), "--background-index", "--clang-tidy" } })

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

      local function open_clang_tidy_rule()
        local lnum = vim.fn.line(".") - 1
        for _, d in ipairs(vim.diagnostic.get(0, { lnum = lnum })) do
          local code = type(d.code) == "string" and d.code or nil
          local group, rest = code and code:match("^([^-]+)%-(.+)$")
          if group and rest then
            vim.ui.open(string.format(
              "https://clang.llvm.org/extra/clang-tidy/checks/%s/%s.html",
              group, rest
            ))
            return
          end
        end
        vim.notify("No clang-tidy diagnostic at cursor", vim.log.levels.WARN)
      end

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

          local ft = vim.bo[buf].filetype
          if ft == "c" or ft == "cpp" then
            bmap("n", "<leader>cR", open_clang_tidy_rule, "Open clang-tidy rule docs")
          end
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
