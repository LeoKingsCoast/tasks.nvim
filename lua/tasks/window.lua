-- This handles the creation and manipulation of task windows

local M = {}

---@param opts table: { [buf], [config] }
---@return table: { [buf], [win] } Returns the window buffer and window number
function M.create_floating_window (opts)
  opts = opts or { buf = -1, config = {
    relative = "editor",
    width = 50,
    height = 20,
    row = 10,
    col = 30,
    style = "minimal",
    border = "rounded"
  } }

  -- Create a buffer
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    -- `listed = false` makes it not a file
    -- `scratch = true` makes it a throwaway buffer
    buf = vim.api.nvim_create_buf(false, true)
  end

  -- Create the window
  local win = vim.api.nvim_open_win(buf, true, opts.config)

  return { buf = buf, win = win }
end

return M
