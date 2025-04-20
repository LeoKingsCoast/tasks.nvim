local window = require("tasks.window")
local handler = require("tasks.handler")

local win_width = math.floor(vim.o.columns * 0.7)
local win_height = math.floor(vim.o.lines * 0.7)

local x_pos = math.floor((vim.o.columns - win_width) / 2)
local y_pos = math.floor((vim.o.lines - win_height) / 2)

---@type vim.api.keyset.win_config[]
local win_config = {
  background = {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = y_pos,
    col = x_pos,
    style = "minimal",
    border = "rounded",
    zindex = 1
  },
  title = {
    relative = "editor",
    width = win_width,
    height = 3,
    row = y_pos,
    col = x_pos,
    style = "minimal",
    border = "rounded",
    zindex = 2
  },
  body = {
    relative = "editor",
    width = win_width,
    height = win_height - 5,
    row = y_pos + 5,
    col = x_pos,
    style = "minimal",
    border = "rounded",
    zindex = 2
  }
}

local M = {}

---@class TaskWindow
---@field background table: { [buf], [win] }
---@field title table: { [buf], [win] }
---@field body table: { [buf], [win] }

---@param task_window TaskWindow
local configure_task_window = function (task_window)
  vim.bo[task_window.body.buf].filetype = "markdown"
  vim.api.nvim_win_set_cursor(task_window.body.win, {1, 1})

  vim.keymap.set("n", "q", function ()
    vim.api.nvim_win_close(task_window.body.win, true)
  end, {
      buffer = task_window.body.buf,
    })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = task_window.body.buf,
    callback = function()
      pcall(vim.api.nvim_win_close, task_window.title.win, true)
      pcall(vim.api.nvim_win_close, task_window.background.win, true)
    end
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    buffer = task_window.body.buf,
    callback = function()
      vim.cmd("stopinsert")
    end,
  })

  -- vim.api.nvim_buf_set_option(task_window.body.buf, 'buftype', 'nofile')
  -- vim.api.nvim_buf_set_option(task_window.body.buf, 'bufhidden', 'wipe')
  -- vim.api.nvim_buf_set_option(task_window.body.buf, 'swapfile', false)
end

---@param task_window TaskWindow
local lock_window = function (task_window)
  vim.api.nvim_buf_set_option(task_window.body.buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(task_window.background.buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(task_window.title.buf, 'modifiable', false)
end

---@param task_window TaskWindow
local unlock_window = function (task_window)
  vim.api.nvim_buf_set_option(task_window.body.buf, 'modifiable', true)
  vim.api.nvim_buf_set_option(task_window.background.buf, 'modifiable', true)
  vim.api.nvim_buf_set_option(task_window.title.buf, 'modifiable', true)
end

---@param task_window TaskWindow
local fill_title = function (task_window)
  local title_win_width = vim.api.nvim_win_get_width(task_window.title.win)
  local title_win_height = vim.api.nvim_win_get_height(task_window.title.win)

  local text = "TODOs for the current project"
  local text_pos = {
    x = math.floor((title_win_width - string.len(text)) / 2),
    y = math.floor(title_win_height / 2)
  }

  local padding = string.rep(" ", text_pos.x)
  local line_breaks = string.rep("\n", text_pos.y)

  local content = line_breaks .. padding .. text

  vim.api.nvim_buf_set_lines(task_window.title.buf, 0, -1, false, vim.split(content, "\n"))
end

---@param task_window TaskWindow
local fill_tasks = function (task_window, root_dir)
  local tasks = handler.search_tasks(root_dir)
  local content = {}
  for _, task in ipairs(tasks) do
    local item = "- [ ] " .. task.description
    local location = "  -> In file " .. task.path.file_path .. ":" .. task.path.row .. ":" .. task.path.col
    table.insert(content, item)
    table.insert(content, location)
  end

  vim.api.nvim_buf_set_lines(task_window.body.buf, 0, -1, false, content)
end

M.open = function ()
  ---@type TaskWindow
  local task_window = {
    background = window.create_floating_window({ buf = -1, config = win_config.background }),
    title = window.create_floating_window({ buf = -1, config = win_config.title }),
    body = window.create_floating_window({ buf = -1, config = win_config.body }),
  }

  configure_task_window(task_window)

  return task_window
end

---@param task_window TaskWindow
---@param root_dir string
M._fill = function (task_window, root_dir)
  fill_title(task_window)
  fill_tasks(task_window, root_dir)
  lock_window(task_window)
end

---@param task_window TaskWindow
M.fill = function (task_window)
  M._fill(task_window, ".")
end

return M
