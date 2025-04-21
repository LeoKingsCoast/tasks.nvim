local window = require("tasks.window")
local core = require("tasks.core")

local original_win
local original_buf

local win_width = math.floor(vim.o.columns * 0.7)
local win_height = math.floor(vim.o.lines * 0.7)

local x_pos = math.floor((vim.o.columns - win_width) / 2)
local y_pos = math.floor((vim.o.lines - win_height) / 2)

local cursor_pos = {1, 1}
local selection_pos = 1

local task_list_empty = true

local root_dir = "."

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
  -- vim.api.nvim_buf_set_option(task_window.body.buf, 'buftype', 'nofile')
  -- vim.api.nvim_buf_set_option(task_window.body.buf, 'bufhidden', 'wipe')
  -- vim.api.nvim_buf_set_option(task_window.body.buf, 'swapfile', false)
end

---@param task_window TaskWindow
local configure_cursor = function (task_window)
  vim.api.nvim_set_hl(0, "TaskWindowCursorHighlight", { blend = 100, bg = "#333333" })

  -- vim.wo[task_window.body.win].cursorline = true
  -- vim.wo[task_window.body.win].wrap = false

  local ns = vim.api.nvim_create_namespace("my_selector")
  -- Setup selection logic
  local function highlight_line(line)
    vim.api.nvim_buf_clear_namespace(task_window.body.buf, ns, 0, -1)
    vim.api.nvim_buf_set_extmark(task_window.body.buf, ns, line, 0, {
      end_row = line + 2,
      hl_group = "TaskWindowCursorHighlight",
      hl_eol = true,
    })
  end

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = task_window.body.buf,
    callback = function ()
      if cursor_pos[1] % 2 == 0 then
        cursor_pos[1] = cursor_pos[1] - 1
      end
      if cursor_pos[1] < 1 then
        cursor_pos[1] = 1
      end

      if not task_list_empty then
        selection_pos = math.ceil(cursor_pos[1] / 2)
        highlight_line(cursor_pos[1] - 1)
        vim.print("Task number: " .. selection_pos)
      end
    end
  })

  vim.keymap.set("n", "j", function ()
    local current_pos = vim.api.nvim_win_get_cursor(task_window.body.win)
    cursor_pos = { current_pos[1] + 2, current_pos[2] }

    local body_lines = vim.api.nvim_buf_line_count(task_window.body.buf)
    if cursor_pos[1] > body_lines then
      cursor_pos[1] = body_lines - 1
    end
    if cursor_pos[1] < 1 then
      cursor_pos[1] = 1
    end

    vim.api.nvim_win_set_cursor(task_window.body.win, cursor_pos)
  end, {
      buffer = task_window.body.buf,
    })

  vim.keymap.set("n", "k", function ()
    local current_pos = vim.api.nvim_win_get_cursor(task_window.body.win)
    cursor_pos = { current_pos[1] - 2, current_pos[2] }

    if cursor_pos[1] < 1 then
      cursor_pos[1] = 1
    end

    vim.api.nvim_win_set_cursor(task_window.body.win, cursor_pos)
  end, {
      buffer = task_window.body.buf,
    })
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
---@param tasks Task[]
local fill_tasks = function (task_window, tasks)
  local content = {}
  local completion_marker

  if #tasks == 0 then
    task_list_empty = true
  else
    task_list_empty = false
  end

  for _, task in ipairs(tasks) do
    if task.done then
      completion_marker = 'x'
    else
      completion_marker = ' '
    end
    local item = "- [" .. completion_marker .. "] " .. task.description
    local location = "  -> In file " .. task.path.file_path .. ":" .. task.path.row .. ":" .. task.path.col
    table.insert(content, item)
    table.insert(content, location)
  end

  vim.api.nvim_buf_set_lines(task_window.body.buf, 0, -1, false, content)
end

---@param task_window TaskWindow
local configure_commands = function (task_window)
  vim.keymap.set("n", "<CR>", function ()
    core.task_toggle(selection_pos)
    unlock_window(task_window)
    fill_tasks(task_window, core.get_tasks(root_dir))
    lock_window(task_window)
  end, {
      buffer = task_window.body.buf
    })

  vim.keymap.set("n", "gd", function ()
    core.jump_to_task(original_win, selection_pos)
  end, {
      buffer = task_window.body.buf
    })

  vim.api.nvim_buf_create_user_command(task_window.body.buf, "W", function ()
    core.write_state()
    -- unlock_window(task_window)
    -- fill_tasks(task_window, core.get_tasks(root_dir))
    -- lock_window(task_window)
  end, { force = true })
end

M.open = function ()
  original_win = vim.api.nvim_get_current_win()
  original_buf = vim.api.nvim_get_current_buf()
  ---@type TaskWindow
  local task_window = {
    background = window.create_floating_window({ buf = -1, config = win_config.background }),
    title = window.create_floating_window({ buf = -1, config = win_config.title }),
    body = window.create_floating_window({ buf = -1, config = win_config.body }),
  }

  configure_task_window(task_window)
  configure_cursor(task_window)
  configure_commands(task_window)

  return task_window
end

---@param task_window TaskWindow
---@param dir string
M._fill = function (task_window, dir)
  if dir then
    root_dir = dir
  end
  fill_title(task_window)
  fill_tasks(task_window, core.get_tasks(root_dir))
  lock_window(task_window)
end

---@param task_window TaskWindow
M.fill = function (task_window)
  M._fill(task_window, ".")
end

return M
