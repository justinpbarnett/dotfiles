return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = nil,
        accept_word = "<C-j>",
      },
      color = {
        suggestion_color = "#808080",
        cterm = 244,
      },
      disable_inline_completion = false,
      disable_keymaps = false,
    })

    vim.keymap.set("i", "<Esc>", function()
      local ok, preview = pcall(require, "supermaven-nvim.completion_preview")
      if ok and preview.suggestion_is_on and preview.suggestion_is_on() then
        if preview.on_dispose_inlay then preview.on_dispose_inlay() end
        return ""
      end
      return "<Esc>"
    end, { expr = true, silent = true, desc = "Dismiss supermaven or exit insert" })
  end,
}
