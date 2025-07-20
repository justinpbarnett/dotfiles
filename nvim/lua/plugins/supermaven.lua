return {
    "supermaven-inc/supermaven-nvim",
    config = function()
        require("supermaven-nvim").setup({
            keymaps = {
                accept_suggestion = "<Tab>",     -- Like Copilot: Tab for full accept
                clear_suggestion = "<C-]>",      -- Dismiss
                accept_word = "<C-j>",           -- Grab next word for partials (helps build paragraphs)
            },
            ignore_filetypes = { "markdown", "text" }, -- Skip non-code
            color = { suggestion_color = "#808080" }, -- Ghost text color (tweak for theme)
            disable_inline_completion = false,   -- Enable inline mode
            disable_keymaps = false,             -- Keep built-ins
            log_level = "warn",                  -- Less noise
        })
    end,
}
