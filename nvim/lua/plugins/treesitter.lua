return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "php", "blade", "javascript", "typescript", "c_sharp" },
                highlight = { 
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                fold = { enable = true },
                incremental_selection = { enable = false },
                indent = { enable = false },
            })
        end,
    },
}
