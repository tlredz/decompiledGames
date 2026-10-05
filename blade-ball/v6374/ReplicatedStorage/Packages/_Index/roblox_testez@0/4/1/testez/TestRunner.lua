local TestEnum = require(script.Parent.TestEnum)
local TestSession = require(script.Parent.TestSession)
local LifecycleHooks = require(script.Parent.LifecycleHooks)
local TestRunner = {
	environment = {}
}

local function wrapExpectContextWithPublicApi(object)
	return (setmetatable({
		extend = function(...)
			object:extend(...)
		end
	}, {
		__call = function(_, ...)
			return object:startExpectationChain(...)
		end
	}))
end

function TestRunner.runPlan(object)
	local v = TestSession.new(object)
	local v2 = LifecycleHooks.new()
	v.hasFocusNodes = #object:findNodes(function(p)
		return p.modifier == TestEnum.NodeModifier.Focus
	end) > 0
	TestRunner.runPlanNode(v, object, v2)
	return v:finalize()
end

function TestRunner.runPlanNode(object, p, object2)
	local function runCallback(callback, value)
		_G.__TESTEZ_RUNNING_TEST__ = true
		local v = getfenv(callback)
		local v2 = true
		local v3 = nil
		local v4 = value or ""

		for k, v5 in pairs(TestRunner.environment) do
			v[k] = v5
		end

		function v.fail(p2)
			local v5 = p2 == nil and "fail() was called." or p2
			v2 = false
			v3 = v4 .. debug.traceback(tostring(v5), 2)
		end

		v.expect = wrapExpectContextWithPublicApi(object:getExpectationContext())
		local context = object:getContext()
		local v5, v6 = xpcall(function()
			callback(context)
		end, function(p2)
			return v4 .. debug.traceback(tostring(p2), 2)
		end)

		if not v5 then
			v2 = false
			v3 = v6
		end

		_G.__TESTEZ_RUNNING_TEST__ = nil
		return v2, v3
	end

	local function runNode(p2)
		for _, v in ipairs(object2:getBeforeEachHooks()) do
			local v2, v3 = runCallback(v, "beforeEach hook: ")

			if not v2 then
				return false, v3
			end
		end

		local v, v2 = runCallback(p2.callback)

		for _, v3 in ipairs(object2:getAfterEachHooks()) do
			local v4, v5 = runCallback(v3, "afterEach hook: ")

			if v4 then
				continue
			end

			if v then
				return false, v5
			end

			return false, v2 .. [[

While cleaning up the failed test another error was found:
]] .. v5
		end

		if v then
			return true, nil
		end

		return false, v2
	end

	object2:pushHooksFrom(p)
	local v = false

	for _, v2 in ipairs(object2:getBeforeAllHooks()) do
		local v3, v4 = runCallback(v2, "beforeAll hook: ")

		if v3 then
			continue
		end

		object:addDummyError("beforeAll", v4)
		v = true
	end

	if not v then
		for _, v2 in ipairs(p.children) do
			if v2.type == TestEnum.NodeType.It then
				object:pushNode(v2)

				if object:shouldSkip() then
					object:setSkipped()
				else
					local v3, v4 = runNode(v2)

					if v3 then
						object:setSuccess()
					else
						object:setError(v4)
					end
				end

				object:popNode()
			elseif v2.type == TestEnum.NodeType.Describe then
				object:pushNode(v2)
				TestRunner.runPlanNode(object, v2, object2)

				if v2.loadError then
					object:setError("Error during planning: " .. v2.loadError)
				else
					object:setStatusFromChildren()
				end

				object:popNode()
			end
		end
	end

	for _, v2 in ipairs(object2:getAfterAllHooks()) do
		local v3, v4 = runCallback(v2, "afterAll hook: ")

		if not v3 then
			object:addDummyError("afterAll", v4)
		end
	end

	object2:popHooks()
end

return TestRunner