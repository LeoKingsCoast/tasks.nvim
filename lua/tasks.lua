local ui = require("tasks.ui")
local search = require("tasks.search")

local open_tasks = function (opts)
  ui.create_floating_window()
end

local search_tasks = function (pattern)
  search.search(pattern, ".")
end

vim.api.nvim_create_user_command("OpenTasks", open_tasks, {})
vim.api.nvim_create_user_command("SearchTasks", function (args)
  search_tasks(args.args)
end, { nargs = 1 })
