return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    spec = {
      { "<leader>c", group = "code" },
      { "<leader>g", group = "git" },
      { "<leader>r", group = "rename / resume" },
    },
  },
}
