local M = {}

-- Create a namespace for virtual text
local ns_id = vim.api.nvim_create_namespace('claude_autocomplete')

-- Define a highlight group for greyed-out suggestions
vim.api.nvim_set_hl(0, 'ClaudeSuggestion', { fg = '#808080', italic = true })

-- Timer for debouncing API requests
local timer = vim.loop.new_timer()

-- State variables
local enabled = true
local suggestion = nil

-- Function to clear the current suggestion
local function clear_suggestion()
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  suggestion = nil
end

-- Function to handle text changes in insert mode
local function on_text_changed()
  if not enabled then return end

  clear_suggestion()

  if timer then timer:stop() end

  timer:start(500, 0, vim.schedule_wrap(function()
    local lnum = vim.fn.line('.') - 1
    local col = vim.fn.col('.') - 1
    local lines = vim.api.nvim_buf_get_lines(0, 0, lnum, false)
    local current_line = vim.api.nvim_get_current_line()
    local prefix = table.concat(lines, '\n') .. '\n' .. string.sub(current_line, 1, col + 1)

    local api_key = os.getenv('ANTHROPIC_API_KEY')
    if not api_key then
      vim.schedule(function() vim.notify('ANTHROPIC_API_KEY not set', vim.log.levels.ERROR) end)
      return
    end

    local curl = require('plenary.curl')
    curl.post('https://api.anthropic.com/v1/messages', {
      headers = {
        ['Content-Type'] = 'application/json',
        ['x-api-key'] = api_key,
        ['anthropic-version'] = '2023-06-01',
      },
      body = vim.fn.json_encode({
        model = 'claude-3-5-sonnet-20241022',
        messages = {{ role = 'user', content = 'Continue this code with 1-2 lines of pure code, no comments or text:\n' .. prefix }},
        max_tokens = 50,
      }),
      callback = function(response)
        vim.schedule(function()
          if response.status == 200 then
            local data = vim.fn.json_decode(response.body)
            local full_suggestion = data.content and data.content[1].text or data.choices[1].message.content
            -- Truncate at first null character (%z) and clean
            local clean_suggestion = full_suggestion:match('^[^%z]*') or full_suggestion
            clean_suggestion = clean_suggestion:gsub('^%s+', ''):gsub('%s+$', ''):gsub('[^%w%s%p]', '')

            local log = io.open(vim.fn.stdpath('config') .. '/claude_autocomplete.log', 'a')
            if log then
              log:write("Raw: " .. full_suggestion .. "\nCleaned: " .. clean_suggestion .. "\n")
              log:close()
            end

            local first_line = clean_suggestion:match('[^\n]*') or clean_suggestion
            suggestion = clean_suggestion

            -- Validate col against current line length
            local current_lines = vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)
            if #current_lines > 0 then
              local line_length = #current_lines[1]
              if col >= 0 and col <= line_length then
                vim.api.nvim_buf_set_extmark(0, ns_id, lnum, col, {
                  virt_text = {{ first_line, 'ClaudeSuggestion' }},
                  virt_text_pos = 'overlay',
                })
              end
            end
          end
        end)
      end,
    })
  end))
end

-- Set up autocommands
vim.api.nvim_create_autocmd('TextChangedI', {
  callback = on_text_changed,
  desc = 'Trigger Claude autocomplete on text change',
})

require("telescope").setup()
require("telescope").load_extension("fzf")

vim.api.nvim_create_autocmd('CursorMovedI', {
  callback = clear_suggestion,
  desc = 'Clear suggestion when cursor moves',
})

vim.api.nvim_create_autocmd('InsertLeave', {
  callback = clear_suggestion,
  desc = 'Clear suggestion when leaving insert mode',
})

-- Keymap to accept the suggestion with Ctrl+Y
vim.keymap.set('i', '<C-y>', function()
  if suggestion then
    local text = suggestion
    clear_suggestion()
    vim.api.nvim_put({ text }, 'c', true, true)
  end
end, { silent = true, desc = 'Accept Claude suggestion' })

-- Command to toggle the feature
vim.api.nvim_create_user_command('ClaudeAutocompleteToggle', function()
  enabled = not enabled
  if not enabled then
    clear_suggestion()
  end
  vim.notify('Claude Autocomplete ' .. (enabled and 'enabled' or 'disabled'))
end, { desc = 'Toggle Claude autocomplete' })

return M
