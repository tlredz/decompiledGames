local option = require(script.Parent:WaitForChild("option"))
local error = require(script.Parent:WaitForChild("error"))
local class = {}
class.__index = class
local class2 = {}
class2.__index = class2
setmetatable(class2, class)

function class:__tostring()
	return self:display()
end

function class:__len()
	return #self._array
end

function class:display()
	return "Vec(" .. error.displayAsJson(self._array) .. ")"
end

function class:len()
	return #self._array
end

function class:forEach(callback)
	for _, v in ipairs(self._array) do
		callback(v)
	end
end

function class:forEachPair(callback)
	for i, v in ipairs(self._array) do
		callback(i, v)
	end
end

function class:matchPair(callback)
	for i, v in ipairs(self._array) do
		local v2 = callback(i, v)

		if v2:isSome() then
			return v2
		end
	end

	return option.none()
end

function class:__iter()
	return next, self._array
end

function class:get(p2: number)
	return option.from(self._array[p2])
end

function class:drain()
	return self._array
end

function class:contains(p2)
	return table.find(self._array, p2) ~= nil
end

function class:isEmpty()
	return #self._array == 0
end

function class:isMut()
	return not table.isfrozen(self._array)
end

function class:asMut()
	local object = setmetatable({
		_array = table.clone(self._array)
	}, class2)
	table.freeze(object)
	return object
end

function class2:__tostring()
	return self:display()
end

function class2:__len()
	return #self._array
end

function class2:__iter()
	return next, self._array
end

function class2:append(items)
	for _, item in items do
		table.insert(self._array, item)
	end
end

function class2:display()
	return "MutVec(" .. error.displayAsJson(self._array) .. ")"
end

function class2:extend(list)
	for _, v in ipairs(list) do
		table.insert(self._array, v)
	end
end

function class2:clear()
	table.clear(self._array)
end

function class2:dedup()
	local v = 1
	local v2 = nil

	while v <= #self._array do
		local v3 = self._array[v]

		if v3 == v2 then
			table.remove(self._array, v)
		else
			v += 1
			v2 = v3
		end
	end
end

function class2:dedupBy(callback)
	local v = 1
	local v2 = nil

	while v <= #self._array do
		local v3 = self._array[v]

		if v2 == nil or not callback(v2, v3) then
			v += 1
			v2 = v3
		else
			table.remove(self._array, v)
		end
	end
end

function class2:dedupAll()
	local v = 1
	local v2 = {}

	while v <= #self._array do
		local v3 = self._array[v]

		if v2[v3] then
			table.remove(self._array, v)
		else
			v2[v3] = true
			v += 1
		end
	end
end

function class2:drain()
	return table.clone(self._array)
end

function class2:insert(p2: number, p3)
	local v

	if p2 >= 1 then
		v = p2 <= #self._array + 1
	else
		v = false
	end

	assert(v, (`insert index {p2} out of bounds for vector of size {#self._array}`))
	table.insert(self._array, p2, p3)
end

function class2:remove(p2: number)
	local v

	if p2 >= 1 then
		v = p2 <= #self._array
	else
		v = false
	end

	assert(v, (`remove index {p2} out of bounds for vector of size {#self._array}`))
	return table.remove(self._array, p2)
end

function class2:retain(callback)
	local v = 1

	while v <= #self._array do
		if callback(self._array[v]) then
			v += 1
		else
			table.remove(self._array, v)
		end
	end
end

function class2:push(p2)
	table.insert(self._array, p2)
end

function class2:pop()
	return option.from(table.remove(self._array, #self._array))
end

function class2:popIf(callback)
	return option.from(self._array[#self._array]):match(function(p)
		if callback(p) then
			return self:pop()
		end

		return option.none()
	end, function()
		return option.none()
	end)
end

function class2:sort(callback)
	if callback then
		table.sort(self._array, callback)
	else
		table.sort(self._array)
	end
end

function class2:freeze()
	local object = setmetatable({
		_array = table.freeze(table.clone(self._array))
	}, class)
	table.freeze(object)
	return object
end

local Vec = {}

function Vec.emptyMut()
	local self = setmetatable({
		_array = {}
	}, class2)
	table.freeze(self)
	return self
end

function Vec.empty()
	local self = setmetatable({
		_array = table.freeze({})
	}, class)
	table.freeze(self)
	return self
end

function Vec.from(clone)
	if not table.isfrozen(clone) then
		clone = table.clone(clone)
	end

	if not table.isfrozen(clone) then
		table.freeze(clone)
	end

	local self = setmetatable({
		_array = clone
	}, class)
	table.freeze(self)
	return self
end

function Vec.fromMut(p)
	local self = setmetatable({
		_array = table.clone(p)
	}, class2)
	table.freeze(self)
	return self
end

function Vec.isVec(p)
	return typeof(p) == "table" and getmetatable(p) == class
end

function Vec.isMutVec(p)
	return typeof(p) == "table" and getmetatable(p) == class2
end

return Vec