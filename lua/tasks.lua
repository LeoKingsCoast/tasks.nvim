local ui = require("tasks.ui")
local core = require("tasks.core")

local M = {}

local options = {
  todo_comments_search = true,
  md_files_search = true,
}

M.setup = function (opts)
  options = vim.tbl_deep_extend("force", options, opts or {})
end

---@param root_dir? string
---@return Task[]
M.get_tasks = function (root_dir, opts)
  -- Get a table with all tasks found in the given directory. Defaults to project
  -- root directory if not specified
  root_dir = root_dir or "."
  opts = opts or options

  return core.get_tasks(root_dir, opts.todo_comments_search, opts.md_files_search)
end

---@param root_dir? string
M.open_tasks = function (root_dir, opts)
  -- Open a window and show all found tasks in the given directory. Defaults to
  -- project root directory if not specified
  root_dir = root_dir or "."
  opts = opts or options

  local task_window = ui.open()
  ui._fill(task_window, opts.todo_comments_search, opts.md_files_search, root_dir)
end

return M

