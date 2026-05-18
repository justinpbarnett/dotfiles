return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    harpoon:extend({
      UI_CREATE = function(cx)
        vim.keymap.set("n", "<C-c>", function()
          harpoon.ui:close_menu()
        end, { buffer = cx.bufnr, desc = "Close harpoon menu" })
      end,
    })

    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add file" })
    vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })

    for i = 1, 4 do
      vim.keymap.set("n", "<leader>" .. i, function() harpoon:list():select(i) end, { desc = "Harpoon slot " .. i })
    end
  end,
}
