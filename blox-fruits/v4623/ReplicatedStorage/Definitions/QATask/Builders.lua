local ExpectationBuilder = require(script.ExpectationBuilder)
local StepBuilder = require(script.StepBuilder)
local TaskBuilder = require(script.TaskBuilder)
require(game.ReplicatedStorage.Definitions.QATask.Types)
return {
	Step = StepBuilder,
	Expectation = ExpectationBuilder,
	Task = TaskBuilder
}