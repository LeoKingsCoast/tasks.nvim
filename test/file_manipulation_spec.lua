local Path = require("plenary.path")
local file = require("tasks.file_handling")

describe("tasks.file_handling", function ()
  before_each(function ()
    files = {
      a = Path:new("test/test_files/dir1/a"),
      b = Path:new("test/test_files/dir1/b"),
      c = Path:new("test/test_files/dir2/c"),
    }

    files.a:parent():mkdir({ parents = true })
    files.b:parent():mkdir({ parents = true })
    files.c:parent():mkdir({ parents = true })

    files.a:write("Hello, Lua!", "w")
    files.b:write([[
#include <stdio.h>

-- TODO: Make sure to return 0
int main(){
        printf("Hello, World!");
}]], "w")

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

  it("deletes the TODO line from file b", function ()
    file.delete_line({ file_path = "test/test_files/dir1/b", row = 3, col = 1})

    local passed_lines = {}
    local file_after = io.open("test/test_files/dir1/b", "r")
    if not file_after then
      vim.notify("Could not open file: test/test_files/dir1/b", vim.log.levels.ERROR)
      return
    end

    for line in file_after:lines() do
      table.insert(passed_lines, line)
    end

    assert.are.same({
      "#include <stdio.h>",
      "",
      "int main(){",
      "        printf(\"Hello, World!\");",
      "}"
    }, passed_lines)
  end)

  it("Marks a markdown task as done", function ()
    file.markdown_task_check({ file_path = "test/test_files/dir2/c", row = 3, col = 1})

    local passed_lines = {}
    local file_after = io.open("test/test_files/dir2/c", "r")
    if not file_after then
      vim.notify("Could not open file: test/test_files/dir1/b", vim.log.levels.ERROR)
      return
    end

    for line in file_after:lines() do
      table.insert(passed_lines, line)
    end

    assert.are.same({
      "# Heading",
      "",
      "Hello, I am a markdown file :)",
      "Nothing to see here",
      "",
      "- [x] Buy milk",
    }, passed_lines)
  end)
end)
