local result = require(script.Parent:WaitForChild("result"))
local option = require(script.Parent:WaitForChild("option"))
local error = require(script.Parent:WaitForChild("error"))
local vec = require(script.Parent:WaitForChild("vec"))

function newEntry(p, p2)
	local v = {
		key = p,
		value = p2
	}
	table.freeze(v)
	return v
end

local class = {}
class.__index = class

function class:len()
	local count = 0

	for _ in pairs(self._map) do
		count += 1
	end

	return count
end

function class:display()
	return (`HashMap({error.displayAsJson(self:drain())})`)
end

function class:__tostring()
	return self:display()
end

function class:__len()
	return self:len()
end

function class:__iter()
	return next, self._map
end

function class:drain()
	return self._map
end

function class:containsKey(p2)
	return self._map[p2] ~= nil
end

function class:get(p2)
	local v = self._map[p2]

	if v == nil then
		return option.none()
	end

	return option.some(v)
end

function class:getKeyValue(p2)
	local v = self._map[p2]

	if v == nil then
		return option.none()
	end

	return option.some(newEntry(p2, v))
end

function class.intoKeys(items)
	local v = {}

	for k, _ in items do
		table.insert(v, k)
	end

	return vec.from(v)
end

function class.intoValues(items)
	local v = {}

	for _, item in items do
		table.insert(v, item)
	end

	return vec.from(v)
end

function class:isEmpty()
	return next(self._map) == nil
end

function class:isMut()
	return not table.isfrozen(self._map)
end

function class:forEachValue(callback)
	for _, v in pairs(self._map) do
		callback(v)
	end
end

function class:forEachKey(callback)
	for k, _ in pairs(self._map) do
		callback(k)
	end
end

function class:forEachPair(callback)
	for k, v in pairs(self._map) do
		callback(k, v)
	end
end

function class:matchPair(callback)
	for k, v in pairs(self._map) do
		local v2 = callback(k, v)

		if v2:isSome() then
			return v2
		end
	end

	return option.none()
end

local class2 = {}
class2.__index = class2
setmetatable(class2, class)

function class:asMut()
	local object = setmetatable({
		_map = table.clone(self._map)
	}, class2)
	table.freeze(object)
	return object
end

function class2:display()
	return (`MutHashMap({error.displayAsJson(self:drain())})`)
end

function class2:__tostring()
	return self:display()
end

function class2:__iter()
	return next, self._map
end

function class2.__len(value)
	return value:len()
end

function class2:clear()
	table.clear(self._map)
end

function class2:insert(p2, p3)
	local v = self._map[p2]
	self._map[p2] = p3

	if v == nil then
		return option.none()
	end

	return option.some(v)
end

function class2:tryInsert(p2, p3)
	if self._map[p2] ~= nil then
		return result.err(error.new("OccupiedError"):title("Occupied Key"):description((`Key "{tostring(p2)}" already exists in the HashMap`)):body({
			entry = newEntry(p2, self._map[p2]),
			value = p3
		}):build())
	end

	self._map[p2] = p3
	return result.ok(p3)
end

function class2:remove(p2)
	local v = self._map[p2]

	if v == nil then
		return option.none()
	end

	self._map[p2] = nil
	return option.some(v)
end

function class2:removeEntry(p2)
	local v = self._map[p2]

	if v == nil then
		return option.none()
	end

	self._map[p2] = nil
	return option.some(newEntry(p2, v))
end

function class2:retain(callback)
	for k, v in self._map do
		if not callback(newEntry(k, v)) then
			self._map[k] = nil
		end
	end
end

function class2:freeze()
	local clone = table.clone(self._map)
	table.freeze(clone)
	local object = setmetatable({
		_map = clone
	}, class)
	table.freeze(object)
	return object
end

local HashMap = {}

function HashMap.emptyMut()
	local self = setmetatable({
		_map = {}
	}, class2)
	table.freeze(self)
	return self
end

function HashMap.empty()
	local self = setmetatable({
		_map = table.freeze({})
	}, class)
	table.freeze(self)
	return self
end

function HashMap.from(clone)
	if not table.isfrozen(clone) then
		clone = table.clone(clone)
	end

	if not table.isfrozen(clone) then
		table.freeze(clone)
	end

	local self = setmetatable({
		_map = clone
	}, class)
	table.freeze(self)
	return self
end

function HashMap.fromMut(p)
	local self = setmetatable({
		_map = table.clone(p)
	}, class2)
	table.freeze(self)
	return self
end

function HashMap.isHashMap(p)
	return typeof(p) == "table" and getmetatable(p) == class
end

function HashMap.isMutHashMap(p)
	return typeof(p) == "table" and getmetatable(p) == class2
end

return HashMap