local task = require("tasks.task")

local M = {}

-- This is the best parser, but lua is not fully compatible with regex. Find solution later.
-- local parser = "./(.*):(%d):(%d):(?:-- |# |// |/* |<!--+ )TODO:s?(.*?)(?:s:?-+->)?$"
-- ./lua/tasks/window.lua:1:4:-- TODO: Make the tasks window
-- ./lua/tasks/window.lua:1:4:# TODO: Make the tasks window
-- ./lua/tasks/window.lua:1:4:// TODO: Make the tasks window
-- ./lua/tasks/window.lua:1:4:// TODO: Make the tasks window
-- ./lua/tasks/window.lua:1:4:<!----- TODO: Make the tasks window --->

local search = require("tasks.search")

---@param grepped_string string
---@return Task|nil
M.parse_task = function (grepped_string)
  local path_parser = "./(.*):(%d*):(%d*):(.*)"
  local path, row, col, content = grepped_string:match(path_parser)

  local lua_parser = "^%s*--%s*TODO:%s*(.*)"
  local c_parser = "^%s*//%s*TODO:%s*(.*)"
  local hash_parser = "^%s*#%s*TODO:%s*(.*)"
  local mkdown_parser = "^%s*-%s*%[.%]%s*(.*)"

  local desc = content:match(lua_parser) or content:match(c_parser) or content:match(hash_parser) or content:match(mkdown_parser)

  -- If description or file_path parsing fails, this will return nil
  local new_task = task.new(desc, { file_path = path, row = row, col = col })

  return new_task
end

---@return Task[]
M.search_tasks = function (root_dir)
  local task_list = {}
  local results = search.search("TODO:|- \\[ \\]", root_dir)
  local new_task

  for _, result in ipairs(results) do
    new_task = M.parse_task(result)
    if new_task then
      table.insert(task_list, new_task)
    end
  end

  return task_list
end

return M
