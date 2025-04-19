local task = require("tasks.task")
local handler = require("tasks.handler")

describe("tasks.tasks", function ()
  it("new should create a task", function ()
    assert.are.same({
      description = "Run benchmarks",
      done = false,
      path = {
        file_path = "path/to/file",
        row = 1,
        col = 1,
      }
    }, task.new("Run benchmarks", "path/to/file"))
  end)

  it("new should create an empty task", function ()
    assert.are.same({
      description = nil,
      done = false,
      path = {
        file_path = nil,
        row = 1,
        col = 1
      },
    }, task.new())
  end)

  it("finish should mark a task as done", function ()
    local my_task = task.new("Run benchmarks", "path/to/file")
    task.finish(my_task)
    assert.are.same(true, my_task.done)

    task.finish(my_task)
    assert.are.same(true, my_task.done)
  end)

  it("format_task should make a task from a TODO lua comment", function ()
    local grepped_task = "./lua/tasks/window.lua:1:4:-- TODO: Make the tasks window"
    assert.are.same({
      file_path = "lua/tasks/window.lua",
      row = 1,
      col = 4,
      description = "Make the tasks window"
    }, handler.format_task(grepped_task))
  end)

  it("format_task should make a task from a TODO C style comment", function ()
    local grepped_task = "./utils/str.c:53:1://TODO: Run valgrind"
    assert.are.same({
      file_path = "utils/str.c",
      row = 53,
      col = 1,
      description = "Run valgrind"
    }, handler.format_task(grepped_task))
  end)

  it("format_task should make a task from a TODO hash comment", function ()
    local grepped_task = "./search.sh:21:1:   # TODO: Test this"
    assert.are.same({
      file_path = "search.sh",
      row = 21,
      col = 1,
      description = "Test this"
    }, handler.format_task(grepped_task))
  end)

  it("format_task should make a task from a markdown checklist item", function ()
    local grepped_task = "./Documents/notes.md:10:8:- [ ] Buy milk"
    assert.are.same({
      file_path = "Documents/notes.md",
      row = 10,
      col = 8,
      description = "Buy milk"
    }, handler.format_task(grepped_task))
  end)
end)
