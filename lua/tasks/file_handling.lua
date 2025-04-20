local M = {}

---@class Path
---@field file_path string
---@field row number
---@field col number

---@param path Path 
M.jump_to = function (window, path)
  vim.cmd("edit " .. vim.fn.fnameescape(path.file_path))
  vim.api.nvim_win_set_cursor(window, { path.row, path.col })
end

-- Probably more efficient to use lua's io library, but I'm trying to learn nvim api
---@param path Path
M.delete_line = function (path)
  local dummy_buffer = vim.fn.bufadd(path.file_path)
  vim.fn.bufload(dummy_buffer)

  local line_count = vim.api.nvim_buf_line_count(dummy_buffer)
  if path.row < 1 or path.row > line_count then
    vim.notify("tasks.nvim: Could not find line " .. path.row .. " in " .. path.file_path, vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_buf_set_lines(dummy_buffer, path.row - 1, path.row, false, {})

  vim.api.nvim_buf_call(dummy_buffer, function()
    vim.cmd("write")
  end)
end

return M
