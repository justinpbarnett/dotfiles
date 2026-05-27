return {
  "ibhagwan/fzf-lua",
  event = "VeryLazy",
  opts = {
    winopts = {
      height = 0.85,
      width = 0.85,
      preview = { default = "bat" },
    },
  },
  keys = {
    { "<leader>f", function() require("fzf-lua").files() end, desc = "Find files" },
    { "<leader>/", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
    { "<leader>g", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
    { "<leader>b", function() require("fzf-lua").buffers() end, desc = "Buffers" },
    { "<leader>s", function() require("fzf-lua").lsp_live_workspace_symbols() end, desc = "Workspace symbols" },
    { "<leader>d", function() require("fzf-lua").diagnostics_workspace() end, desc = "Diagnostics" },
    { "<leader>r", function() require("fzf-lua").resume() end, desc = "Resume picker" },
    { "<leader>'", function() require("fzf-lua").marks() end, desc = "Marks" },
    { "<leader>?", function() require("fzf-lua").help_tags() end, desc = "Help tags" },
  },
}
