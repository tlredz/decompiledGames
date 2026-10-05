local Expectation = require(script.Expectation)
local TestBootstrap = require(script.TestBootstrap)
local TestEnum = require(script.TestEnum)
local TestPlan = require(script.TestPlan)
local TestPlanner = require(script.TestPlanner)
local TestResults = require(script.TestResults)
local TestRunner = require(script.TestRunner)
return {
	run = function(p, callback)
		local modules = TestBootstrap:getModules(p)
		local plan = TestPlanner.createPlan(modules)
		callback((TestRunner.runPlan(plan)))
	end,
	Expectation = Expectation,
	TestBootstrap = TestBootstrap,
	TestEnum = TestEnum,
	TestPlan = TestPlan,
	TestPlanner = TestPlanner,
	TestResults = TestResults,
	TestRunner = TestRunner,
	TestSession = require(script.TestSession),
	Reporters = {
		TextReporter = require(script.Reporters.TextReporter),
		TextReporterQuiet = require(script.Reporters.TextReporterQuiet),
		TeamCityReporter = require(script.Reporters.TeamCityReporter)
	}
}