return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
        local harpoon = require("harpoon")

        -- Initialize Harpoon
        harpoon:setup({
            settings = {
                save_on_toggle = false,
                save_on_change = true,
                tmux_autoclose_windows = false,
                excluded_filetypes = { "harpoon", "neo-tree", "Outline" },
                mark_branch = true,
                tabline = false,
            },
            projects = {
                ["$HOME/projects/my-app"] = {
                    term = {
                        cmds = {
                            "npm run dev",
                            "npm test",
                        },
                    },
                },
            },
        })

        -- Basic keybindings
        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: Add file" })
        vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
            { desc = "Harpoon: Toggle menu" })

        vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end,
            { desc = "Harpoon: Go to file 1 (fallback)" })
        vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end,
            { desc = "Harpoon: Go to file 2 (fallback)" })
        vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end,
            { desc = "Harpoon: Go to file 3 (fallback)" })
        vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end,
            { desc = "Harpoon: Go to file 4 (fallback)" })

        -- Cycle through Harpoon list
        vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = "Harpoon: Previous file" })
        vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end, { desc = "Harpoon: Next file" })

        -- Telescope integration for Harpoon menu
        local conf = require("telescope.config").values
        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end
            require("telescope.pickers").new({}, {
                prompt_title = "Harpoon",
                finder = require("telescope.finders").new_table({
                    results = file_paths,
                }),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
            }):find()
        end

        vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end,
            { desc = "Harpoon: Open Telescope menu" })

        -- Optional: Custom list for running commands
        harpoon:setup({
            cmd = {
                add = function(possible_value)
                    local idx = vim.fn.line(".")
                    local cmd = vim.api.nvim_buf_get_lines(0, idx - 1, idx, false)[1]
                    if cmd == nil then return nil end
                    return { value = cmd, context = { row = idx } }
                end,
                select = function(list_item, _, _)
                    if list_item then
                        vim.cmd(list_item.value)
                    end
                end,
            },
        })
    end,
}
