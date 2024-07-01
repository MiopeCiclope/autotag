local M = {}

local function findLastTag(text)
  local lastTag = nil
  for tag in text:gmatch("<(%w+([%.%w+]*))[^>]*") do
    lastTag = tag
  end
  return lastTag
end

local function extract_last_html_tag()
  local text = vim.api.nvim_get_current_line()

  local tag = findLastTag(text)
  if tag then
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    local insert_text = "</" .. tag .. ">"
    vim.schedule(function()
      vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { insert_text })
      vim.api.nvim_win_set_cursor(0, { row, col })
    end)
    return ""
  else
    return ">"
  end
end

function M.setup()
  vim.api.nvim_create_augroup("TagFileTypes", { clear = true })

  vim.api.nvim_create_autocmd({ "TextChangedI", "InsertCharPre" }, {
    group = "TagFileTypes",
    pattern = "*",
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
