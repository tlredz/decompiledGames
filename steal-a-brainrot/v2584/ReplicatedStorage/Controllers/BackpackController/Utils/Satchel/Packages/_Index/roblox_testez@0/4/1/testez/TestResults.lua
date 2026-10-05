local TestEnum = require(script.Parent.TestEnum)
local v = {
	[TestEnum.TestStatus.Success] = "+",
	[TestEnum.TestStatus.Failure] = "-",
	[TestEnum.TestStatus.Skipped] = "~"
}
local TestResults = {}
TestResults.__index = TestResults

function TestResults.new(planNode)
	local v2 = {
		successCount = 0,
		failureCount = 0,
		skippedCount = 0,
		planNode = planNode,
		children = {},
		errors = {}
	}
	setmetatable(v2, TestResults)
	return v2
end

function TestResults.createNode(planNode)
	return {
		planNode = planNode,
		children = {},
		errors = {},
		status = nil
	}
end

function TestResults:visitAllNodes(callback, p)
	for _, v2 in ipairs((p or self).children) do
		callback(v2)
		self:visitAllNodes(callback, v2)
	end
end

function TestResults:visualize(p, value)
	local v2 = value or 0
	local v3 = {}

	for _, v4 in ipairs((p or self).children) do
		if v4.planNode.type == TestEnum.NodeType.It then
			local v5 = v[v4.status] or "?"
			local formatted = ("%s[%s] %s"):format((" "):rep(3 * v2), v5, v4.planNode.phrase)

			if v4.messages and #v4.messages > 0 then
				formatted ..= "\n " .. (" "):rep(3 * v2) .. table.concat(v4.messages, "\n " .. (" "):rep(3 * v2))
			end

			table.insert(v3, formatted)
		else
			local formatted = ("%s%s"):format((" "):rep(3 * v2), v4.planNode.phrase or "")

			if v4.status then
				formatted ..= (" (%s)"):format(v4.status)
			end

			table.insert(v3, formatted)

			if #v4.children > 0 then
				table.insert(v3, (self:visualize(v4, v2 + 1)))
			end
		end
	end

	return table.concat(v3, "\n")
end

return TestResults