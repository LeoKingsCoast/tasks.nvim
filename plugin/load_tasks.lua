vim.api.nvim_create_user_command("TasksOpen", function ()
  require("tasks").open_tasks()
end, {})

vim.api.nvim_create_user_command("TasksWrite", function ()
  require("tasks.core").write_state()
end, {})
