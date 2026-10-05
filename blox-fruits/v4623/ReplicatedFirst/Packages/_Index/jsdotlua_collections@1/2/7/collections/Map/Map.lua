local __DEV__ = _G.__DEV__
local forEach = require(script.Parent.Parent:WaitForChild("Array"):WaitForChild("forEach"))
local map = require(script.Parent.Parent:WaitForChild("Array"):WaitForChild("map"))
local isArray = require(script.Parent.Parent:WaitForChild("Array"):WaitForChild("isArray"))
local instanceof = require(script.Parent.Parent.Parent:WaitForChild("instance-of"))
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
local Map = {}

function Map:new()
	local clone = nil
	local clone2 = nil

	if self == nil then
		clone = {}
		clone2 = {}
	elseif isArray(self) then
		if __DEV__ and #self > 0 and typeof(self[1]) ~= "table" then
			error("Value `" .. typeof(self[1]) .. [[
` is not an entry object.
 Cannot create Map from {K, V} form, it must be { {K, V}... }]])
		end

		clone = table.create(#self)
		clone2 = {}

		for _, v in self do
			local v2 = v[1]

			if __DEV__ and v2 == nil then
				error("cannot create Map from a table that isn't an array.")
			end

			local v3 = v[2]

			if clone2[v2] == nil then
				table.insert(clone, v2)
			end

			clone2[v2] = v3
		end
	elseif instanceof(self, Map) then
		clone = table.clone(self._array)
		clone2 = table.clone(self._map)
	else
		error(("`%s` `%s` is not iterable, cannot make Map using it"):format(typeof(self), (tostring(self))))
	end

	return (setmetatable({
		size = #clone,
		_map = clone2,
		_array = clone
	}, Map))
end

function Map:set(p, p2)
	if self._map[p] == nil then
		self.size += 1
		table.insert(self._array, p)
	end

	self._map[p] = p2
	return self
end

function Map:get(p2)
	return self._map[p2]
end

function Map:clear()
	local table2 = table
	self.size = 0
	table2.clear(self._map)
	table2.clear(self._array)
end

function Map:delete(p)
	if self._map[p] == nil then
		return false
	end

	self.size -= 1
	self._map[p] = nil
	local index = table.find(self._array, p)

	if index then
		table.remove(self._array, index)
	end

	return true
end

function Map:forEach(callback, p2)
	if __DEV__ and typeof(callback) ~= "function" then
		error("callback is not a function")
	end

	forEach(self._array, function(p3)
		local v = self._map[p3]

		if p2 == nil then
			callback(v, p3, self)
		else
			callback(p2, v, p3, self)
		end
	end)
end

function Map:has(p2)
	return self._map[p2] ~= nil
end

function Map:keys()
	return self._array
end

function Map:values()
	return map(self._array, function(p2)
		return self._map[p2]
	end)
end

function Map:entries()
	return map(self._array, function(p2)
		return { p2, self._map[p2] }
	end)
end

function Map:ipairs()
	if __DEV__ then
		warn(debug.traceback([[
`for _,_ in myMap:ipairs() do` is deprecated and will be removed in a future release, please use `for _,_ in myMap do` instead
]], 2))
	end

	return ipairs(self:entries())
end

function Map:__iter()
	return next, self:entries()
end

function Map.__index(p, p2)
	local v = rawget(Map, p2)

	if v ~= nil then
		return v
	end

	if __DEV__ then
		assert(
			rawget(p, "_map"),
			"Map has been corrupted, and is missing private state! Did you accidentally call table.clear() instead of map:clear()?"
		)
	end

	return Map.get(p, p2)
end

function Map:__newindex(p, p2)
	self:set(p, p2)
end

return Map