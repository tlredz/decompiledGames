local Expectation = require(script.Parent.Expectation)
local checkMatcherNameCollisions = Expectation.checkMatcherNameCollisions

local function copy(items)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

local ExpectationContext = {}
ExpectationContext.__index = ExpectationContext

function ExpectationContext:new()
	local v = {
		_extensions = 0
	}
	local _extensions

	if self then
		local _extensions2 = self._extensions
		_extensions = {}

		for k, _extension in pairs(_extensions2) do
			_extensions[k] = _extension
		end

		if not _extensions then
			_extensions = {}
		end
	else
		_extensions = {}
	end

	v._extensions = _extensions
	return (setmetatable(v, ExpectationContext))
end

function ExpectationContext:startExpectationChain(...)
	return Expectation.new(...):extend(self._extensions)
end

function ExpectationContext:extend(items)
	for k, item in pairs(items) do
		assert(self._extensions[k] == nil, string.format("Cannot reassign %q in expect.extend", k))
		assert(checkMatcherNameCollisions(k), string.format("Cannot overwrite matcher %q; it already exists", k))
		self._extensions[k] = item
	end
end

return ExpectationContext