return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local autopairs = require("nvim-autopairs")

            autopairs.setup({
                check_ts = true,
                ts_config = {
                    lua = { "string", "source" },
                    javascript = { "string", "template_string" },
                    java = false,
                },
                disable_filetype = { "TelescopePrompt", "spectre_panel" },
                disable_in_macro = true,
                disable_in_visualblock = false,
                disable_in_replace_mode = true,
                ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
                enable_moveright = true,
                enable_afterquote = true,
                enable_check_bracket_line = true,
                enable_bracket_in_quote = true,
                enable_abbr = false,
                break_undo = true,
                check_comma = true,
                map_cr = true,
                map_bs = true,
                map_c_h = false,
                map_c_w = false,
            })
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter",
        config = function()
            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = false,
                },
                per_filetype = {
                    ["html"] = {
                        enable_close = false,
                    },
                },
            })
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },
}

