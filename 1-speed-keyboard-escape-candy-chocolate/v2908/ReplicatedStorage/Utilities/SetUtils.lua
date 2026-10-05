local SetUtils = {}
SetUtils.__index = SetUtils

-- equivalent calls inferred from this helper; original call sites unknown
local function assertValidValue(p)
	assert(p ~= nil, "Set values cannot be nil")
end

function SetUtils.new(items)
	local self = setmetatable({
		_values = {},
		_size = 0
	}, SetUtils)

	if items then
		for _, item in items do
			self:add(item)
		end
	end

	return self
end

function SetUtils.from(p)
	return SetUtils.new(p)
end

function SetUtils:add(p)
	assertValidValue(p) -- equivalent call inferred; original call site unknown

	if not self._values[p] then
		self._values[p] = true
		self._size += 1
	end

	return self
end

function SetUtils:delete(p)
	assertValidValue(p) -- equivalent call inferred; original call site unknown

	if not self._values[p] then
		return false
	end

	self._values[p] = nil
	self._size -= 1
	return true
end

function SetUtils:has(p2)
	assertValidValue(p2) -- equivalent call inferred; original call site unknown
	return self._values[p2] == true
end

function SetUtils:clear()
	table.clear(self._values)
	self._size = 0
end

function SetUtils:size()
	return self._size
end

function SetUtils:values()
	local v = nil
	return function()
		v = next(self._values, v)
		return v
	end
end

function SetUtils:forEach(callback)
	for k in self:values() do
		callback(k, k, self)
	end
end

function SetUtils:toArray()
	local result = {}

	for k in self:values() do
		table.insert(result, k)
	end

	return result
end

function SetUtils:clone()
	local v = SetUtils.new({})

	for k in self:values() do
		v:add(k)
	end

	return v
end

function SetUtils:union(object2)
	local clone = self:clone()

	for k in object2:values() do
		clone:add(k)
	end

	return clone
end

function SetUtils:intersection(object2)
	local v = SetUtils.new({})

	for k in self:values() do
		if object2:has(k) then
			v:add(k)
		end
	end

	return v
end

function SetUtils:difference(object2)
	local v = SetUtils.new({})

	for k in self:values() do
		if not object2:has(k) then
			v:add(k)
		end
	end

	return v
end

function SetUtils:isSubsetOf(object2)
	for k in self:values() do
		if not object2:has(k) then
			return false
		end
	end

	return true
end

function SetUtils.isSupersetOf(p, object)
	return object:isSubsetOf(p)
end

return SetUtils