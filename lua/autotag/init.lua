local M = {}

local function findLastTag(text)
  local lastTag = nil
  for tag in text:gmatch("<(%w+([%.%w+]*))[^>]*") do
    lastTag = tag
  end
  return lastTag
end

local function getchar_before_cursor(row, col)
  col = col - 1

  if col < 0 then
    if row == 1 then
      return nil
    else
      row = row - 1
      local prev_line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
      col = #prev_line
    end
  end

  local char = vim.api.nvim_buf_get_text(0, row - 1, col - 1, row - 1, col, {})[1]
  return char
end

local function extract_last_html_tag()
  local text = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  local insertText = ">"
  local prioChar = getchar_before_cursor(row, col)
  if prioChar == "<" then
    insertText = "</>"
  end

  local tag = findLastTag(text)
  if tag then
    insertText = "</" .. tag .. ">"
  end

  vim.schedule(function()
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { insertText })
    vim.api.nvim_win_set_cursor(0, { row, col })
  end)
end

function M.setup(opts)
  opts = opts or {}
  local patterns = opts.patterns or { "*.tsx", "*.jsx", "*.html" }

  vim.api.nvim_create_augroup("TagFileTypes", { clear = true })

  vim.api.nvim_create_autocmd({ "TextChangedI", "InsertCharPre" }, {
    group = "TagFileTypes",
    pattern = patterns,
    callback = function()
      local char = vim.v.char
      if char == ">" then
        vim.schedule(extract_last_html_tag)
      end
    end,
  })

  vim.api.nvim_create_user_command("ExtractLastHtmlTag", function()
    extract_last_html_tag()
  end, { nargs = 0 })
end

return M
