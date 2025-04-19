---@class Task
---@field description string
---@field done boolean
---@field path string

M = {}

---@param desc string
---@param path string
---@return Task
M.new = function (desc, path)
  local new_task = {
    description = desc,
    done = false,
    path = path
  }

  return new_task
end

return M
