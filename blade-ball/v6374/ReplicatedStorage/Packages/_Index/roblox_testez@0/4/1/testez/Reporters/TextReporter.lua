local TestService = game:GetService("TestService")
local TestEnum = require(script.Parent.Parent.TestEnum)
local v = (" "):rep(3)
local v2 = {
	[TestEnum.TestStatus.Success] = "+",
	[TestEnum.TestStatus.Failure] = "-",
	[TestEnum.TestStatus.Skipped] = "~"
}
local TextReporter = {}

local function compareNodes(p, p2)
	return p.planNode.phrase:lower() < p2.planNode.phrase:lower()
end

local reportNode

reportNode = function(data, options, value)
	local v3 = options or {}
	local v4 = value or 0

	if data.status == TestEnum.TestStatus.Skipped then
		return v3
	end

	local v5

	if data.status then
		local v6 = v2[data.status] or "?"
		v5 = ("%s[%s] %s"):format(v:rep(v4), v6, data.planNode.phrase)
	else
		v5 = ("%s%s"):format(v:rep(v4), data.planNode.phrase)
	end

	table.insert(v3, v5)
	table.sort(data.children, compareNodes)

	for _, v6 in ipairs(data.children) do
		reportNode(v6, v3, v4 + 1)
	end

	return v3
end

local function reportRoot(p)
	table.sort(p.children, compareNodes)
	local v3 = {}

	for _, v4 in ipairs(p.children) do
		reportNode(v4, v3, 0)
	end

	return v3
end

local function report(p)
	local v3 = reportRoot(p)
	return table.concat(v3, "\n")
end

function TextReporter.report(data)
	local v3 = reportRoot(data)
	local v4 = {
		"Test results:",
		table.concat(v3, "\n"),
		("%d passed, %d failed, %d skipped"):format(data.successCount, data.failureCount, data.skippedCount)
	}
	print(table.concat(v4, "\n"))

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

return TextReporter