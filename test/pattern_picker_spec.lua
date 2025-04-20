local Path = require("plenary.path")
local search = require("tasks.search")
local handler = require("tasks.handler")

local sorted = function (t)
  local copy = vim.deepcopy(t)
  table.sort(copy)
  return copy
end

describe("tasks.search", function ()
  before_each(function ()
    files = {
      a = Path:new("test/test_files/dir1/a"),
      b = Path:new("test/test_files/dir1/b"),
      c = Path:new("test/test_files/dir2/c"),
    }

    files.a:parent():mkdir({ parents = true })
    files.b:parent():mkdir({ parents = true })
    files.c:parent():mkdir({ parents = true })

    -- Doesn't work, don't know why
    -- for _, file in ipairs(files) do
    --   file:parent():mkdir({ parents = true })
    -- end

    files.a:write("Hello, Lua!", "w")
    files.b:write([[
#include <stdio.h>

-- TODO: Make sure to return 0
int main(){
        printf("Hello, World!");
}
    ]], "w")

    files.c:write([[
# Heading

Hello, I am a markdown file :)
Nothing to see here

- [ ] Buy milk
    ]], "w")

  end)

  after_each(function()
    for _, file in ipairs(files) do
      if file:exists() then
        file:rm()
      end
    end
  end)

  it("looks for a string that appears in 2 files", function ()
    local lines_found = search.search("Hello", "./test/test_files/dir1")
    assert.are.same(sorted({
      "./test/test_files/dir1/b:5:17:        printf(\"Hello, World!\");",
      "./test/test_files/dir1/a:1:1:Hello, Lua!",
    }), sorted(lines_found))
  end)

  it("looks for a string that appears in diverging paths", function ()
    local lines_found = search.search("Hello", "./test/test_files")
    assert.are.same(sorted({
      "./test/test_files/dir1/b:5:17:        printf(\"Hello, World!\");",
      "./test/test_files/dir1/a:1:1:Hello, Lua!",
      "./test/test_files/dir2/c:3:1:Hello, I am a markdown file :)",
    }), sorted(lines_found))
  end)

  it("looks for a string that doesn't appear in any file", function ()
    local lines_found = search.search("Lua", "./test/test_files/dir2")
    assert.are.same({}, lines_found)
  end)

  it("search tasks generates a list of tasks based on the search results", function ()
    local task_list = handler.search_tasks("./test/test_files")
    assert.are.same({
      { description = "Make sure to return 0", done = false, path = { file_path = "test/test_files/dir1/b", row = 3, col = 4 } },
      { description = "Buy milk", done = false, path = { file_path = "test/test_files/dir2/c", row = 6, col = 1 } },
    },
    task_list)
  end)
end)
