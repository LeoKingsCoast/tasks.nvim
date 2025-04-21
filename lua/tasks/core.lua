local handler = require("tasks.handler")
local task = require("tasks.task")
local files = require("tasks.file_handling")

---@type Task[]
local task_list = {}

local root_dir_g

local M = {}

---@param str string
---@return boolean
local is_markdown = function (str)
  return string.find(str, "- %[ %]") ~= nil
end

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
  for idx, task_item in ipairs(task_list) do
    if task_item.done then
      if is_markdown(task_item.description) then
        -- files.markdown_task_check(task_item.path)
        print(task_item.description .. "--> Is markdown")
      else
        -- files.delete_line(task_item.path)
        print(task_item.description .. "--> Is not markdown")
      end

      -- table.remove(task_list, idx)
    end
  end
end

return M
