return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()
        local keymap = vim.keymap.set
        keymap("n", "<leader>a", function()
            harpoon:list():append()
        end)
        keymap("n", "<C-h>", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end)
        keymap("n", "<C-1>", function()
            harpoon:list():select(1)
        end)
        keymap("n", "<C-2>", function()
            harpoon:list():select(2)
        end)
        keymap("n", "<C-3>", function()
            harpoon:list():select(3)
        end)
        keymap("n", "<C-4>", function()
            harpoon:list():select(4)
        end)
        -- Toggle previous & next buffers stored within Harpoon list
        keymap("n", "<C-S-P>", function()
            harpoon:list():prev()
        end)
        keymap("n", "<C-S-N>", function()
            harpoon:list():next()
        end)
    end,
}
