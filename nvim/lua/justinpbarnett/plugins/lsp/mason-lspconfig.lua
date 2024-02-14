-- Specifies which LSPs Mason should install always
return {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    config = function()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "html",
                "cssls",
                "tsserver",
                "eslint",
                "angularls",
                "csharp_ls",
                -- "omnisharp",
                "pyright",
                "gopls",
                "tailwindcss",
            },
        })
    end,
}
