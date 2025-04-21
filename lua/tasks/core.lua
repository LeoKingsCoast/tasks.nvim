local handler = require("tasks.handler")
local task = require("tasks.task")
local files = require("tasks.file_handling")

---@type Task[]
local task_list = {}

local root_dir_g

local table_contains = function (tbl, searched_value)
  for _, value in ipairs(tbl) do
    if value == searched_value then
      return true
    end
  end
  return false
end

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

M.jump_to_task = function (window, task_index)
  files.jump_to(window, task_list[task_index].path)
end

M.write_state = function ()
  local deleted = {}
  for idx, task_item in ipairs(task_list) do
    if task_item.done then
      if task_item.markdown then
        files.markdown_task_check(task_item.path)
      else
        files.delete_line(task_item.path)
      end

      -- Store the deleted tasks' indexes
      table.insert(deleted, idx)
    end
  end

  -- Create a new task list excluding the done (deleted) tasks
  local new_task_list = {}
  for idx, task_item in ipairs(task_list) do
    if not table_contains(deleted, idx) then
      table.insert(new_task_list, task_list[idx])
    end
  end

  task_list = new_task_list
end

return M
