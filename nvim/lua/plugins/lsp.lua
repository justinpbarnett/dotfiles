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

      local function vue_ts_plugin_path()
        local npm_root = vim.trim(vim.fn.system({ "npm", "root", "-g" }))
        if npm_root ~= "" and vim.fn.isdirectory(npm_root .. "/@vue/language-server") == 1 then
          return npm_root .. "/@vue/language-server"
        end
        local exe = vim.fn.exepath("vue-language-server")
        if exe ~= "" then
          local candidate = vim.fs.dirname(vim.fs.dirname(exe)) .. "/lib/node_modules/@vue/language-server"
          if vim.fn.isdirectory(candidate) == 1 then
            return candidate
          end
        end
        return nil
      end

      local vue_plugin_path = vue_ts_plugin_path()
      if not vue_plugin_path then
        vim.notify(
          "vue_ls: install @vue/language-server globally (see install.sh)",
          vim.log.levels.WARN
        )
      end

      -- vue_ls handles template/style; vtsls + @vue/typescript-plugin handles <script>.
      vim.lsp.config("vtsls", {
        settings = vue_plugin_path and {
          vtsls = {
            tsserver = {
              globalPlugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = vue_plugin_path,
                  languages = { "vue" },
                  configNamespace = "typescript",
                },
              },
            },
          },
        } or nil,
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
        },
      })

      local function clangd_path()
        for _, p in ipairs({ "/opt/homebrew/opt/llvm/bin/clangd", "/usr/local/opt/llvm/bin/clangd" }) do
          if vim.fn.executable(p) == 1 then return p end
        end
        return "clangd"
      end
      vim.lsp.config("clangd", { cmd = { clangd_path(), "--background-index", "--clang-tidy" } })

      -- =====================================================================
      -- Roslyn (C#) — best current setup for Unity (2026)
      -- =====================================================================
      -- Server: Microsoft Roslyn Language Server (same one VS Code uses).
      -- Install once (macOS example):
      --   dotnet tool install -g roslyn-language-server --prerelease \
      --     --source https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/index.json
      --   (ensure the tool is on $PATH; `roslyn-language-server --stdio` should work)
      --
      -- Unity-side requirements for reliable intellisense + "gi":
      --   1. Install https://github.com/walcht/com.walcht.ide.neovim (via Unity Package Manager git URL)
      --   2. In Unity: Edit > Preferences > External Tools → set External Script Editor to Neovim
      --      and enable .csproj generation for the assemblies you care about.
      --   3. (Strongly recommended) Add Microsoft.Unity.Analyzers via the walcht package UI.
      --      This eliminates the false "Update/Awake/Start is unused" diagnostics.
      --
      -- Useful commands when things feel stale:
      --   :Roslyn target          (switch solution if you have multiple)
      --   :LspRestart             (or :Roslyn restart in some versions)
      --   :RoslynFilewatch reload (forces resync from the watcher)
      --   :checkhealth roslyn_filewatch
      -- =====================================================================
      -- Explicit cmd for the Roslyn Language Server.
      -- Using full paths makes it reliable when Neovim is launched from Unity
      -- (where PATH can be minimal compared to a normal shell).
      local roslyn_cmd = {
        "/opt/homebrew/bin/dotnet",
        "/Users/justin.barnett/.local/share/roslyn-ls/Microsoft.CodeAnalysis.LanguageServer.dll",
        "--stdio",
        "--logLevel=Information",
        "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
      }

      vim.lsp.config("roslyn", {
        cmd = roslyn_cmd,
        settings = {
          ["csharp|background_analysis"] = {
            -- "openFiles" is recommended for large Unity projects (fullSolution can be heavy).
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles",
          },
          ["csharp|inlay_hints"] = {
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            csharp_enable_inlay_hints_for_types = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
          },
          ["csharp|symbol_search"] = {
            dotnet_search_reference_assemblies = true,
          },
          ["csharp|navigation"] = {
            dotnet_navigate_to_decompiled_sources = true,
          },
          ["csharp|completion"] = {
            dotnet_show_name_completion_suggestions = true,
            dotnet_provide_regex_completions = true,
          },
        },
      })

      vim.lsp.enable({
        "lua_ls",
        "basedpyright",
        "ruff",
        "clangd",
        "vtsls",
        "vue_ls",
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
          bmap("n", "gD", function()
            local clients = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/declaration" })
            if #clients == 0 then
              vim.lsp.buf.definition()
            else
              vim.lsp.buf.declaration()
            end
          end, "Goto declaration (falls back to definition)")
          -- Use fzf-lua's implementation picker when available (much better UX for multiple results).
          -- Falls back to the raw LSP handler. Works great once Roslyn has fully indexed the Unity assemblies.
          bmap("n", "gi", function()
            local ok, fzf = pcall(require, "fzf-lua")
            if ok then
              fzf.lsp_implementations()
            else
              vim.lsp.buf.implementation()
            end
          end, "Goto implementation (fzf picker)")
          -- Use fzf-lua's references picker when available (much nicer than the default quickfix list).
          -- We include the declaration/definition so you get the full picture of usages.
          -- Falls back to the raw LSP handler.
          bmap("n", "gr", function()
            local ok, fzf = pcall(require, "fzf-lua")
            if ok then
              fzf.lsp_references({ includeDeclaration = true })
            else
              vim.lsp.buf.references({ includeDeclaration = true })
            end
          end, "References / Find usages (fzf picker)")
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
    -- Roslyn language server client (replaces the old OmniSharp).
    -- Works best with the dedicated file watcher below for Unity projects.
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
      -- Let the dedicated file watcher (roslyn-filewatch.nvim) drive most FS events for Unity.
      -- "auto" is a safe default; some Unity users prefer "off" here.
      filewatching = "auto",

      -- Unity projects often have the .sln one level above Assets/ or in odd layouts.
      -- broad_search makes it look in parent directories — very helpful.
      broad_search = true,

      -- You can lock a specific solution after first attach if you have multiple.
      lock_target = false,

      -- Optional: custom target selection for Unity (example below).
      -- choose_target = function(targets)
      --   return vim.iter(targets):find(function(t)
      --     return t:match("Assembly%-CSharp") or t:match("%.sln$")
      --   end)
      -- end,
    },
  },

  -- High-performance file watcher + project sync for Roslyn.
  -- This is one of the highest-impact additions for Unity:
  -- - Handles the constant churn from Unity (Library/, reimports, new .cs + .meta, .asmdef changes)
  -- - Automatically applies Unity-optimized ignore patterns + debounce
  -- - Keeps intellisense, go-to-impl, etc. working without constant :LspRestart
  {
    "khoido2003/roslyn-filewatch.nvim",
    -- Builds the optional native Rust backend for very fast scans (highly recommended).
    -- Falls back gracefully if Rust isn't present.
    build = "nvim -l build.lua --",
    ft = { "cs", "razor" },
    dependencies = { "seblyng/roslyn.nvim" },
    config = function()
      require("roslyn_filewatch").setup({
        -- Which LSP client names to attach the watcher to.
        client_names = { "roslyn", "roslyn_ls", "roslyn_lsp" },

        -- "auto" detects Unity (looks for Assets/ + ProjectSettings/), Godot, etc.
        -- You can also force preset = "unity".
        preset = "auto",

        -- Good balance for Unity's bursty file changes.
        diagnostic_throttling = {
          enabled = true,
          debounce_ms = 600,
          visible_only = true,
        },

        -- Extra directories to ignore (in addition to the preset).
        ignore_dirs = {
          "Library", "Temp", "Logs", "Obj", "Bin",
          ".git", ".idea", ".vs", "node_modules",
        },

        -- Enable automatic NuGet restore when .csproj files change.
        enable_autorestore = true,

        log_level = vim.log.levels.WARN,
      })
    end,
  },
}
