local TestService = game:GetService("TestService")
local TestEnum = require(script.Parent.Parent.TestEnum)
local TeamCityReporter = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function teamCityEscape(value)
	local v = string.gsub(value, "([]|'[])", "|%1")
	local v2 = string.gsub(v, "\r", "|r")
	return (string.gsub(v2, "\n", "|n"))
end

local function teamCityEnterSuite(phrase)
	return string.format("##teamcity[testSuiteStarted name='%s']", teamCityEscape(phrase))
end

local function teamCityLeaveSuite(phrase)
	return string.format("##teamcity[testSuiteFinished name='%s']", teamCityEscape(phrase))
end

local function teamCityEnterCase(phrase)
	return string.format("##teamcity[testStarted name='%s']", teamCityEscape(phrase))
end

local function teamCityLeaveCase(phrase)
	return string.format("##teamcity[testFinished name='%s']", teamCityEscape(phrase))
end

local function teamCityFailCase(phrase, joined)
	local v = teamCityEscape(phrase) -- equivalent call inferred; original call site unknown
	return string.format("##teamcity[testFailed name='%s' message='%s']", v, teamCityEscape(joined))
end

local reportNode

reportNode = function(data, options, value)
	local selected = options or {}
	local v2 = value or 0

	if data.status == TestEnum.TestStatus.Skipped then
		return selected
	end

	if data.planNode.type == TestEnum.NodeType.Describe then
		table.insert(selected, teamCityEnterSuite(data.planNode.phrase))

		for _, v3 in ipairs(data.children) do
			reportNode(v3, selected, v2 + 1)
		end

		table.insert(selected, teamCityLeaveSuite(data.planNode.phrase))
	else
		table.insert(selected, teamCityEnterCase(data.planNode.phrase))

		if data.status == TestEnum.TestStatus.Failure then
			table.insert(selected, teamCityFailCase(data.planNode.phrase, table.concat(data.errors, "\n")))
		end

		table.insert(selected, teamCityLeaveCase(data.planNode.phrase))
	end
end

local function reportRoot(p)
	local v = {}

	for _, v2 in ipairs(p.children) do
		reportNode(v2, v, 0)
	end

	return v
end

local function report(p)
	local v = reportRoot(p)
	return table.concat(v, "\n")
end

function TeamCityReporter.report(data)
	local v = reportRoot(data)
	local v2 = {
		"Test results:",
		table.concat(v, "\n"),
		("%d passed, %d failed, %d skipped"):format(data.successCount, data.failureCount, data.skippedCount)
	}
	print(table.concat(v2, "\n"))

	if data.failureCount > 0 then
		print(("%d test nodes reported failures."):format(data.failureCount))
	end

	if #data.errors > 0 then
		print("Errors reported by tests:")
		print("")

		for _, error in ipairs(data.errors) do
			TestService:Error(error)
			print("")
		end
	end
end

return TeamCityReporter