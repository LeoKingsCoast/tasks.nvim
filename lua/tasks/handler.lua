local M = {}

-- This is the best parser, but lua is not fully compatible with regex. Find solution later.
-- local parser = "./(.*):(%d):(%d):(?:-- |# |// |/* |<!--+ )TODO:s?(.*?)(?:s:?-+->)?$"
-- ./lua/tasks/window.lua:1:4:-- TODO: Make the tasks window
-- ./lua/tasks/window.lua:1:4:# TODO: Make the tasks window
-- ./lua/tasks/window.lua:1:4:// TODO: Make the tasks window
-- ./lua/tasks/window.lua:1:4:// TODO: Make the tasks window
-- ./lua/tasks/window.lua:1:4:<!----- TODO: Make the tasks window --->

local search = require("tasks.search")

---@param string
---@return table
M.format_task = function (grepped_string)
  -- grepped_string = "./search.sh:21:1:   # TODO: Test this"
  local path_parser = "./(.*):(%d*):(%d*):(.*)"
  local path, row, col, content = grepped_string:match(path_parser)

  local lua_parser = "^%s*--%s*TODO:%s*(.*)"
  local c_parser = "^%s*//%s*TODO:%s*(.*)"
  local hash_parser = "^%s*#%s*TODO:%s*(.*)"
  local mkdown_parser = "^%s*-%s*%[.%]%s*(.*)"

  local desc = content:match(lua_parser) or content:match(c_parser) or content:match(hash_parser) or content:match(mkdown_parser)

  local task_info = {
    file_path = path,
    row = tonumber(row),
    col = tonumber(col),
    description = desc,
  }

  return task_info
end

M.search_tasks = function ()
  local results = search.search("TODO:", ".")
  for _, result in ipairs(results) do
    
  end
end

local str = "I am a string"
local pattern = "(.*) am a (.*)"
local gotten1, gotten2 = str:match(pattern)
print(gotten1)
print(gotten2)

return M
