local handler = require("tasks.handler")
local task = require("tasks.task")

---@type Task[]
local task_list = {}

local root_dir_g

local M = {}

---@param root_dir string
---@return Task[]
M.get_tasks = function (root_dir)
  if #task_list == 0 or not root_dir_g or root_dir_g ~= root_dir then
    root_dir_g = root_dir
    task_list = handler.search_tasks(root_dir)
  end
  return task_list
end

M.task_toggle = function (task_index)
  task.toggle(task_list[task_index])
end

M.jump_to_task = function ()
end

M.write_state = function ()
  for _, task_item in ipairs(task_list) do
    if task_item.done then
    end
  end
end

return M
