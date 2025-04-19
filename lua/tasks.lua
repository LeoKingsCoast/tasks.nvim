local ui = require("tasks.ui")

local open_tasks = function (opts)
  ui.create_floating_window()
end

vim.api.nvim_create_user_command("OpenTasks", open_tasks, {})
