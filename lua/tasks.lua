local ui = require("tasks.ui")
local search = require("tasks.search")

local open_tasks = function (opts)
  local task_window = ui.open()
  ui.fill(task_window)
end

vim.api.nvim_create_user_command("OpenTasks", open_tasks, {})
