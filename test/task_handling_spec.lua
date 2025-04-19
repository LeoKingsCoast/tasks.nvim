local task = require("tasks.task")
describe("tasks.tasks", function ()
  it("new should create a task", function ()
    assert.are.same({
      description = "Run benchmarks",
      done = false,
      path = "path/to/file"
    }, task.new("Run benchmarks", "path/to/file"))
  end)

  it("new should create an empty task", function ()
    assert.are.same({
      description = nil,
      done = false,
      path = nil,
    }, task.new())
  end)

  it("finish should mark a task as done", function ()
    local my_task = task.new("Run benchmarks", "path/to/file")
    task.finish(my_task)
    assert.are.same(true, my_task.done)

    task.finish(my_task)
    assert.are.same(true, my_task.done)
  end)
end)
