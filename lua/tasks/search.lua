local M = {}

local picker_search = function (pattern, path)
  path = path or '.'
  local cmd = { 'rg', '--vimgrep', pattern, path }
  local output = {}

  local search_job = vim.fn.jobstart(cmd, {
    on_stdout = function (_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= '' then
            table.insert(output, line)
          end
        end
      end
    end,
    on_stderr = function (_, data, _)
      if data then
        for _, err in ipairs(data) do
          if err ~= '' then
            vim.api.nvim_echo({ { err, 'ErrorMsg' } }, true, { err = true })
          end
        end
      end
    end,
  })

  local result = vim.fn.jobwait( { search_job }, -1)

  if result[1] == 0 then
    return output
  else
    vim.api.nvim_echo({ { 'Search for task failed or timed out', 'ErrorMsg' } }, true, { err = true })
    return {}
  end
end

---@return string[]
M.search = function (pattern, path)
  local found = picker_search(pattern, path)
  return found
end

return M
