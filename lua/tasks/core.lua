local handler = require("tasks.handler")

---@type Task[]
local task_list = {}

local M = {}

---@param root_dir string
---@return Task[]
M.get_tasks = function (root_dir)
  if #task_list == 0 then
    task_list = handler.search_tasks(root_dir)
  end
  return task_list
end

return M
