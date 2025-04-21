vim.api.nvim_create_user_command("OpenTasks", function ()
  require("tasks").open_tasks()
end, {})
