local task = require("tasks.task")
describe("tasks.tasks", function ()
  it("should create a task", function ()
    assert.are.same({
      description = "Run benchmarks",
      done = false,
      path = "path/to/file"
    }, task.new("Run benchmarks", "path/to/file"))
  end)

  it("should create an empty task", function ()
    assert.are.same({
      description = nil,
      done = false,
      path = nil,
    }, task.new())
  end)
end)
