---@class Task
---@field description string
---@field done boolean
---@field path string

M = {}

---@param desc string
---@param path table
---@return Task
M.new = function (desc, path_str)
  local path = {
    file_path = path_str,
    row = 1,
    col = 1,
  }
  local new_task = {
    description = desc,
    done = false,
    path = path
  }

  return new_task
end

M.finish = function (task)
  if not task.done then
    task.done = true
  end
end

return M
