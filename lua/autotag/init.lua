local M = {}

M.print_message = function()
  print("Neoroma being founded")
end

local function findLastTag(text)
  local lastTag = nil
  for tag in text:gmatch("<(%w+([%.%w+]*))[^>]*") do
    lastTag = tag
  end
  return lastTag
end

local function extract_last_html_tag()
  local text = vim.api.nvimMet_current_line()

  local tag = findLastTag(text)
  if tag then
    -- Get the current cursor position
    local row, col = unpack(vim.api.nvim_winMet_cursor(0))

    local insert_text = "></" .. tag .. ">"
    vim.schedule(function()
      vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { insert_text })
      vim.api.nvim_win_set_cursor(0, { row, col + 1 })
    end)
    return ""
  else
    return ">"
  end
end

M.setupAutoTag = function()
  print("it triggers")
  vim.api.nvim_buf_set_keymap(0, "i", ">", "v:lua.extract_last_html_tag()", { noremap = true, expr = true })
end

function M.setup()
  vim.api.nvim_create_augroup("test", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = "test",
    pattern = "typescriptreact",
    callback = function()
      vim.api.nvim_buf_set_keymap(0, "n", "<leader>tt", "lua require('autotag').print_message()<CR>", {})
    end,
  })
end

-- vim.cmd([[
--         augroup jsx_tsx_mappings
--           autocmd!
--           autocmd FileType typescriptreact,javascriptreact,html lua M.setupAutoTag()
--         augroup END
--       ]])
--
return M
