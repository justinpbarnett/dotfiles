return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    on_attach = function(buf)
      local gs = require("gitsigns")
      local function bmap(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
      end
      bmap("n", "]g", function() gs.nav_hunk("next") end, "Next hunk")
      bmap("n", "[g", function() gs.nav_hunk("prev") end, "Prev hunk")
      bmap("n", "<leader>gh", gs.stage_hunk, "Stage hunk")
      bmap("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
      bmap("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
      bmap("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
      bmap("n", "<leader>gd", gs.diffthis, "Diff this")
    end,
  },
}
