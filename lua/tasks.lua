local ui = require("tasks.ui")
local core = require("tasks.core")

local M = {}

---@param root_dir? string
---@return Task[]
M.get_tasks = function (root_dir)
  -- Get a table with all tasks found in the given directory. Defaults to project
  -- root directory if not specified
  root_dir = root_dir or "."
  return core.get_tasks(root_dir)
end

---@param root_dir? string
M.open_tasks = function (root_dir)
  -- Open a window and show all found tasks in the given directory. Defaults to
  -- project root directory if not specified
  root_dir = root_dir or "."
  local task_window = ui.open()
  ui._fill(task_window, root_dir)
end

return M

