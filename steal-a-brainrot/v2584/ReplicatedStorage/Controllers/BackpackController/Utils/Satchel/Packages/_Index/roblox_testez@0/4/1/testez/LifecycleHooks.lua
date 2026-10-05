local TestEnum = require(script.Parent.TestEnum)
local LifecycleHooks = {}
LifecycleHooks.__index = LifecycleHooks

function LifecycleHooks.new()
	return (setmetatable({
		_stack = {}
	}, LifecycleHooks))
end

function LifecycleHooks:getBeforeEachHooks()
	local beforeEach = TestEnum.NodeType.BeforeEach
	local result = {}

	for _, v in ipairs(self._stack) do
		for _, v2 in ipairs(v[beforeEach]) do
			table.insert(result, v2)
		end
	end

	return result
end

function LifecycleHooks:getAfterEachHooks()
	local afterEach = TestEnum.NodeType.AfterEach
	local result = {}

	for _, v in ipairs(self._stack) do
		for _, v2 in ipairs(v[afterEach]) do
			table.insert(result, 1, v2)
		end
	end

	return result
end

function LifecycleHooks:popHooks()
	table.remove(self._stack, #self._stack)
end

function LifecycleHooks:pushHooksFrom(p)
	assert(p ~= nil)
	local _stack = self._stack
	local v = {
		[TestEnum.NodeType.BeforeAll] = self:_getHooksOfType(p.children, TestEnum.NodeType.BeforeAll),
		[TestEnum.NodeType.AfterAll] = self:_getHooksOfType(p.children, TestEnum.NodeType.AfterAll),
		[TestEnum.NodeType.BeforeEach] = self:_getHooksOfType(p.children, TestEnum.NodeType.BeforeEach),
		[TestEnum.NodeType.AfterEach] = self:_getHooksOfType(p.children, TestEnum.NodeType.AfterEach)
	}
	table.insert(_stack, v)
end

function LifecycleHooks:getBeforeAllHooks()
	return self._stack[#self._stack][TestEnum.NodeType.BeforeAll]
end

function LifecycleHooks:getAfterAllHooks()
	return self._stack[#self._stack][TestEnum.NodeType.AfterAll]
end

function LifecycleHooks:_getHooksOfType(list, p)
	local callbacks = {}

	for _, v in ipairs(list) do
		if v.type == p then
			table.insert(callbacks, v.callback)
		end
	end

	return callbacks
end

return LifecycleHooks