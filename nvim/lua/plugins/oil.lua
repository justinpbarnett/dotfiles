return {
  "stevearc/oil.nvim",
  lazy = false,
  opts = {
    default_file_explorer = true,
    view_options = { show_hidden = true },
    keymaps = {
      ["q"] = "actions.close",
      ["<C-h>"] = false,
      ["<C-l>"] = false,
    },
  },
  keys = {
    { "-", function() require("oil").open() end, desc = "Open parent dir (oil)" },
    { "<leader>e", function() require("oil").open() end, desc = "Open parent dir (oil)" },
  },
}
