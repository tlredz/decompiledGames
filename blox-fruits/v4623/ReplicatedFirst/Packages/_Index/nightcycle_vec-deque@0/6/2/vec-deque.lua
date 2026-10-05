local option = require(script.Parent:WaitForChild("option"))
local error = require(script.Parent:WaitForChild("error"))
local class = {}
class.__index = class

function class:__tostring()
	return self:display()
end

function class:__len()
	return self:len()
end

function class:__iter()
	return ipairs, self._queue
end

function class:display()
	return "VecDeque(" .. error.displayAsJson(self._queue) .. ")"
end

function class:len()
	return #self._queue
end

function class:forEach(callback)
	for _, v in ipairs(self._queue) do
		callback(v)
	end
end

function class:forEachPair(callback)
	for i, v in ipairs(self._queue) do
		callback(i, v)
	end
end

function class:drain()
	return self._queue
end

function class:contains(p2)
	return table.find(self._queue, p2) ~= nil
end

function class:isEmpty()
	return #self._queue == 0
end

function class:append(items)
	for _, item in items do
		table.insert(self._queue, item)
	end
end

function class:extend(list)
	for _, v in ipairs(list) do
		table.insert(self._queue, v)
	end
end

function class:clear()
	table.clear(self._queue)
end

function class:insert(p2: number, p3)
	local v

	if p2 >= 1 then
		v = p2 <= #self._queue + 1
	else
		v = false
	end

	assert(v, (`insert index {p2} out of bounds for vector of size {#self._queue}`))
	table.insert(self._queue, p2, p3)
end

function class:remove(p2: number)
	local v

	if p2 >= 1 then
		v = p2 <= #self._queue
	else
		v = false
	end

	assert(v, (`remove index {p2} out of bounds for vector of size {#self._queue}`))
	return table.remove(self._queue, p2)
end

function class:retain(callback)
	local v = 1

	while v <= #self._queue do
		if callback(self._queue[v]) then
			v += 1
		else
			table.remove(self._queue, v)
		end
	end
end

function class:pushBack(p2)
	table.insert(self._queue, p2)
end

function class:pushFront(p2)
	table.insert(self._queue, 1, p2)
end

function class:popBack()
	return option.from(table.remove(self._queue, #self._queue))
end

function class:popFront()
	return option.from(table.remove(self._queue, 1))
end

function class:back()
	return option.from(self._queue[#self._queue])
end

function class:front()
	return option.from(self._queue[1])
end

function class:sort(callback)
	if callback then
		table.sort(self._queue, callback)
	else
		table.sort(self._queue)
	end
end

local VecDeque = {}

function VecDeque.empty()
	local self = setmetatable({
		_queue = {}
	}, class)
	table.freeze(self)
	return self
end

function VecDeque.from(p)
	local self = setmetatable({
		_queue = table.clone(p)
	}, class)
	table.freeze(self)
	return self
end

function VecDeque.isVecDeque(p)
	return typeof(p) == "table" and getmetatable(p) == class
end

return VecDeque