return {
  "saghen/blink.cmp",
  version = "*",
  event = "InsertEnter",
  keys = {
    {
      "<leader>tc",
      function()
        vim.g.blink_cmp_disabled = not vim.g.blink_cmp_disabled
        vim.notify("Autocomplete " .. (vim.g.blink_cmp_disabled and "disabled" or "enabled"))
      end,
      desc = "Toggle autocomplete",
    },
  },
  opts = {
    enabled = function()
      return not vim.g.blink_cmp_disabled
    end,
    keymap = { preset = "default" },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      ghost_text = { enabled = false },
    },
    signature = { enabled = true },
  },
}
