return {
    "tpope/vim-dadbod",
    opt = true,
    dependencies = {
        "kristijanhusak/vim-dadbod-ui",
        "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
        require("justinpbarnett.config.dadbod").setup()
        local opts = { noremap = true, silent = true }
        local keymap = vim.keymap.set
        keymap("n", "<leader>db", "<cmd>DBUIToggle<cr>", opts)
        keymap("n", "<leader>df", "<cmd>DBUIFindBuffer<cr>", opts)
        keymap("n", "<leader>dr", "<cmd>DBUIRenameBuffer<cr>", opts)
        keymap("n", "<leader>dq", "<cmd>DBUIQueryHistory<cr>", opts)
    end,
}
