return {
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local luasnip = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()

            -- HTML snippets (for both HTML and Blade files)
            local html_doc_snippet = luasnip.snippet("doc", {
                luasnip.text_node({ "<!DOCTYPE html>", "<html lang=\"" }),
                luasnip.insert_node(1, "en"),
                luasnip.text_node({ "\">", "<head>", "    <meta charset=\"UTF-8\">",
                    "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">", "    <title>" }),
                luasnip.insert_node(2, "Document"),
                luasnip.text_node({ "</title>", "</head>", "<body>", "    " }),
                luasnip.insert_node(0),
                luasnip.text_node({ "", "</body>", "</html>" }),
            })

            luasnip.add_snippets("html", { html_doc_snippet })
            luasnip.add_snippets("blade", { html_doc_snippet })

            -- Laravel snippets
            luasnip.add_snippets("php", {
                luasnip.snippet("route", {
                    luasnip.text_node("Route::"),
                    luasnip.choice_node(1, {
                        luasnip.text_node("get"),
                        luasnip.text_node("post"),
                        luasnip.text_node("put"),
                        luasnip.text_node("patch"),
                        luasnip.text_node("delete"),
                    }),
                    luasnip.text_node("('"),
                    luasnip.insert_node(2, "uri"),
                    luasnip.text_node("', "),
                    luasnip.insert_node(3, "callback"),
                    luasnip.text_node(");"),
                }),

                luasnip.snippet("controller", {
                    luasnip.text_node({ "<?php", "", "namespace App\\Http\\Controllers;", "",
                        "use Illuminate\\Http\\Request;", "", "class " }),
                    luasnip.insert_node(1, "Controller"),
                    luasnip.text_node({ " extends Controller", "{", "    " }),
                    luasnip.insert_node(0),
                    luasnip.text_node({ "", "}" }),
                }),

                luasnip.snippet("model", {
                    luasnip.text_node({ "<?php", "", "namespace App\\Models;", "",
                        "use Illuminate\\Database\\Eloquent\\Model;", "", "class " }),
                    luasnip.insert_node(1, "Model"),
                    luasnip.text_node({ " extends Model", "{", "    protected $fillable = [" }),
                    luasnip.insert_node(2),
                    luasnip.text_node({ "];", "", "    " }),
                    luasnip.insert_node(0),
                    luasnip.text_node({ "", "}" }),
                }),

                luasnip.snippet("migration", {
                    luasnip.text_node({ "<?php", "", "use Illuminate\\Database\\Migrations\\Migration;",
                        "use Illuminate\\Database\\Schema\\Blueprint;", "use Illuminate\\Support\\Facades\\Schema;", "",
                        "return new class extends Migration", "{", "    public function up()", "    {",
                        "        Schema::create('" }),
                    luasnip.insert_node(1, "table_name"),
                    luasnip.text_node({ "', function (Blueprint $table) {", "            $table->id();", "            " }),
                    luasnip.insert_node(2),
                    luasnip.text_node({ "", "            $table->timestamps();", "        });", "    }", "",
                        "    public function down()", "    {", "        Schema::dropIfExists('" }),
                    luasnip.dynamic_node(3,
                        function(args) return luasnip.snippet_node(nil, { luasnip.text_node(args[1][1]) }) end, { 1 }),
                    luasnip.text_node({ "');", "    }", "};" }),
                }),

                luasnip.snippet("blade", {
                    luasnip.text_node("@extends('"),
                    luasnip.insert_node(1, "layout"),
                    luasnip.text_node({ "')", "", "@section('" }),
                    luasnip.insert_node(2, "content"),
                    luasnip.text_node({ "')", "    " }),
                    luasnip.insert_node(0),
                    luasnip.text_node({ "", "@endsection" }),
                }),

                luasnip.snippet("artisan", {
                    luasnip.text_node("php artisan "),
                    luasnip.insert_node(0),
                }),

                luasnip.snippet("dd", {
                    luasnip.text_node("dd("),
                    luasnip.insert_node(1),
                    luasnip.text_node(");"),
                }),

                luasnip.snippet("request", {
                    luasnip.text_node("$request->"),
                    luasnip.choice_node(1, {
                        luasnip.text_node("get('"),
                        luasnip.text_node("input('"),
                        luasnip.text_node("validate(["),
                        luasnip.text_node("all()"),
                    }),
                    luasnip.insert_node(2),
                    luasnip.choice_node(3, {
                        luasnip.text_node("')"),
                        luasnip.text_node("'])"),
                        luasnip.text_node(""),
                    }),
                }),
            })
        end,
    },
    {
        "Saghen/blink.cmp",
        version = "1.*", -- Stick to stable
        opts = function(_, opts)
            opts.sources = opts.sources or {}
            opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }

            -- Set manual selection for more control (no auto-insert)
            opts.completion = opts.completion or {}
            opts.completion.list = opts.completion.list or {}
            opts.completion.list.selection = opts.completion.list.selection or {}
            opts.completion.list.selection.auto_insert = false -- Manual accept for awareness/control

            opts.completion.ghost_text = opts.completion.ghost_text or {}
            opts.completion.ghost_text.enabled = true

            return opts
        end,
        dependencies = {
            {
                "Saghen/blink.compat",
                version = "2.*",          -- For blink.cmp v1.*
                lazy = true,
                opts = { debug = false }, -- Quiet; set true if you need logs for issues
            },
        },
    },
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "intelephense", -- PHP/Laravel
                    "ts_ls",        -- JS/TS/React
                    "html",         -- HTML
                    "cssls",        -- CSS
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")

            lspconfig.intelephense.setup({
                filetypes = { "php", "blade" },
                settings = {
                    intelephense = {
                        files = {
                            maxSize = 5000000,
                            associations = { "*.php", "*.blade.php" },
                        },
                    },
                },
            })

            lspconfig.ts_ls.setup({
                init_options = {
                    preferences = {
                        includeCompletionsWithSnippetText = true,
                        includeCompletionsForImportStatements = true,
                    },
                },
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            })

            lspconfig.html.setup({
                filetypes = { "html" },
                init_options = {
                    configurationSection = { "html", "css", "javascript" },
                    embeddedLanguages = {
                        css = true,
                        javascript = true
                    },
                    provideFormatter = true
                },
                settings = {},
                single_file_support = true,
            })

            lspconfig.cssls.setup({
                filetypes = { "css", "scss", "less" },
                settings = {
                    css = {
                        validate = true
                    },
                    less = {
                        validate = true
                    },
                    scss = {
                        validate = true
                    }
                }
            })

            -- Global LSP keymaps (merged with original)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
            vim.keymap.set("n", "gs", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
            vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Goto References" })
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
            vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
            vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
            vim.keymap.set("n", "]e",
                function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end,
                { desc = "Next Error" })
            vim.keymap.set("n", "[e",
                function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end,
                { desc = "Prev Error" })
            vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open Diagnostic" })
            vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic Loclist" })

            -- Diagnostic config from original
            vim.diagnostic.config({
                virtual_text = { prefix = '●' },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "✖",
                        [vim.diagnostic.severity.WARN] = "⚠",
                        [vim.diagnostic.severity.INFO] = "ℹ",
                        [vim.diagnostic.severity.HINT] = "💡",
                    }
                },
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })
        end,
    },
}
