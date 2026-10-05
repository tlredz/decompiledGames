local TestEnum = require(script.Parent.TestEnum)
local TestResults = require(script.Parent.TestResults)
local Context = require(script.Parent.Context)
local ExpectationContext = require(script.Parent.ExpectationContext)
local TestSession = {}
TestSession.__index = TestSession

function TestSession.new(p)
	local v = {
		results = TestResults.new(p),
		nodeStack = {},
		contextStack = {},
		expectationContextStack = {},
		hasFocusNodes = false
	}
	setmetatable(v, TestSession)
	return v
end

function TestSession:calculateTotals()
	local results = self.results
	results.successCount = 0
	results.failureCount = 0
	results.skippedCount = 0
	results:visitAllNodes(function(p2)
		local status = p2.status

		if p2.planNode.type == TestEnum.NodeType.It then
			if status == TestEnum.TestStatus.Success then
				results.successCount += 1
			elseif status == TestEnum.TestStatus.Failure then
				results.failureCount += 1
			elseif status == TestEnum.TestStatus.Skipped then
				results.skippedCount += 1
			end
		end
	end)
end

function TestSession:gatherErrors()
	local results = self.results
	results.errors = {}
	results:visitAllNodes(function(p2)
		if #p2.errors > 0 then
			for _, error2 in ipairs(p2.errors) do
				table.insert(results.errors, error2)
			end
		end
	end)
end

function TestSession:finalize()
	if #self.nodeStack ~= 0 then
		error("Cannot finalize TestResults with nodes still on the stack!", 2)
	end

	self:calculateTotals()
	self:gatherErrors()
	return self.results
end

function TestSession:pushNode(p)
	local node = TestResults.createNode(p)
	table.insert((self.nodeStack[#self.nodeStack] or self.results).children, node)
	table.insert(self.nodeStack, node)
	local v = self.contextStack[#self.contextStack]
	local v2 = Context.new(v)
	table.insert(self.contextStack, v2)
	local v3 = self.expectationContextStack[#self.expectationContextStack]
	local v4 = ExpectationContext.new(v3)
	table.insert(self.expectationContextStack, v4)
end

function TestSession:popNode()
	assert(#self.nodeStack > 0, "Tried to pop from an empty node stack!")
	table.remove(self.nodeStack, #self.nodeStack)
	table.remove(self.contextStack, #self.contextStack)
	table.remove(self.expectationContextStack, #self.expectationContextStack)
end

function TestSession.getContext(p)
	assert(#p.contextStack > 0, "Tried to get context from an empty stack!")
	return p.contextStack[#p.contextStack]
end

function TestSession.getExpectationContext(p)
	assert(#p.expectationContextStack > 0, "Tried to get expectationContext from an empty stack!")
	return p.expectationContextStack[#p.expectationContextStack]
end

function TestSession.shouldSkip(p)
	if p.hasFocusNodes then
		for i = #p.nodeStack, 1, -1 do
			local v = p.nodeStack[i]

			if v.planNode.modifier == TestEnum.NodeModifier.Skip then
				return true
			end

			if v.planNode.modifier == TestEnum.NodeModifier.Focus then
				return false
			end
		end

		return true
	else
		for i = #p.nodeStack, 1, -1 do
			if p.nodeStack[i].planNode.modifier == TestEnum.NodeModifier.Skip then
				return true
			end
		end

		return false
	end
end

function TestSession.setSuccess(p)
	assert(#p.nodeStack > 0, "Attempting to set success status on empty stack")
	p.nodeStack[#p.nodeStack].status = TestEnum.TestStatus.Success
end

function TestSession.setSkipped(p)
	assert(#p.nodeStack > 0, "Attempting to set skipped status on empty stack")
	p.nodeStack[#p.nodeStack].status = TestEnum.TestStatus.Skipped
end

function TestSession:setError(p2)
	assert(#self.nodeStack > 0, "Attempting to set error status on empty stack")
	local v = self.nodeStack[#self.nodeStack]
	v.status = TestEnum.TestStatus.Failure
	table.insert(v.errors, p2)
end

function TestSession:addDummyError(phrase, p2)
	self:pushNode({
		type = TestEnum.NodeType.It,
		phrase = phrase
	})
	self:setError(p2)
	self:popNode()
	self.nodeStack[#self.nodeStack].status = TestEnum.TestStatus.Failure
end

function TestSession.setStatusFromChildren(p)
	assert(#p.nodeStack > 0, "Attempting to set status from children on empty stack")
	local v = p.nodeStack[#p.nodeStack]
	local success = TestEnum.TestStatus.Success
	local flag = true

	for _, v2 in ipairs(v.children) do
		if v2.status == TestEnum.TestStatus.Skipped then
			continue
		end

		flag = false

		if v2.status == TestEnum.TestStatus.Failure then
			success = TestEnum.TestStatus.Failure
		end
	end

	if flag then
		success = TestEnum.TestStatus.Skipped
	end

	v.status = success
end

return TestSession