local Queue = {}
Queue.__index = Queue

function Queue.new()
	local self = setmetatable({}, Queue)
	self.IsSorted = false
	self._Registry = {}
	self._Queue = {}
	return self
end

function Queue:IsEmpty()
	return #self._Queue == 0
end

function Queue:Has(p2)
	return self._Registry[p2] ~= nil
end

function Queue:GetLength()
	return #self._Queue
end

function Queue:Remove(p2)
	local index = table.find(self._Queue, p2)

	if index then
		table.remove(self._Queue, index)
		self._Registry[p2] = nil
	end
end

function Queue:Sort()
	assert(self.IsSorted, "you can only sort queues with IsSorted = true")
	table.sort(self._Queue, function(a, b)
		local v = self._Registry[a] or 0
		local v2 = self._Registry[b] or 0
		assert(v and v2)
		return v2 < v
	end)
end

function Queue:CheckPosition(p2)
	return table.find(self._Queue, p2)
end

function Queue:CheckPriority(p2)
	return self._Registry[p2]
end

function Queue:Add(p, value: number?)
	if self:Has(p) then
		return
	end

	if value and not self.IsSorted then
		error("priority passed to unsorted queue, enabled sorting with queue.IsSorted = true")
	end

	local v = value or 0
	assert(v ~= nil)
	self._Registry[p] = v
	local v2 = nil

	if self.IsSorted then
		for i, v4 in ipairs(self._Queue) do
			local v5 = self._Queue[i + 1]

			if v5 then
				local v6 = self._Registry[v5]

				if v6 and v <= v6 then
					v2 = i
					break
				end
			else
				local v6 = self._Registry[v4]

				if v6 and v6 < v then
					v2 = i
					break
				end
			end
		end
	end

	if v2 then
		table.insert(self._Queue, v2, p)
	else
		table.insert(self._Queue, 1, p)
	end
end

function Queue:Get()
	if self:IsEmpty() then
		return nil
	end

	local v = self._Queue[1]
	table.remove(self._Queue, 1)
	self._Registry[v] = nil
	return v
end

function Queue:Peek()
	return self._Queue[1]
end

function Queue:Step(p: number, callback)
	local lastTime = tick()

	repeat
		local v = self:Get()

		if v ~= nil then
			callback(v)
		end
	until p <= tick() - lastTime or self:IsEmpty()
end

return Queue