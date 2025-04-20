---@class Task
---@field description string
---@field done boolean
---@field path table

M = {}

---@param desc string
---@param path table
---@return Task|nil
M.new = function (desc, path)
  if desc == nil or path == nil then
    return nil
  end

  local task_path = {
    file_path = path.file_path,
    row = tonumber(path.row) or 1,
    col = tonumber(path.col) or 1,
  }
  local new_task = {
    description = desc,
    done = false,
    path = task_path
  }

  return new_task
end

M.finish = function (task)
  if not task.done then
    task.done = true
  end
end

M.toggle = function (task)
  if not task.done then
    task.done = true
  else
    task.done = false
  end
end

return M
