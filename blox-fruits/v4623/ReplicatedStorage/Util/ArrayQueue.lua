local ArrayQueue = {}
ArrayQueue.__index = ArrayQueue

function ArrayQueue.new(capacity)
	local v = {
		capacity = capacity,
		front = 1,
		rear = 1,
		count = 0,
		queue = table.create(capacity)
	}
	setmetatable(v, ArrayQueue)
	return v
end

function ArrayQueue:enqueue(p)
	if self:isFull() then
		print("Queue is full")
		return
	end

	self.queue[self.rear] = p
	self.rear = self.rear % self.capacity + 1
	self.count += 1
end

function ArrayQueue:dequeue()
	if self:isEmpty() then
		print("Queue is empty")
		return nil
	end

	local v = self.queue[self.front]
	self.queue[self.front] = nil
	self.front = self.front % self.capacity + 1
	self.count -= 1
	return v
end

function ArrayQueue:isEmpty()
	return self.count == 0
end

function ArrayQueue:isFull()
	return self.count == self.capacity
end

function ArrayQueue:peekFront()
	if not self:isEmpty() then
		return self.queue[self.front]
	end

	print("Queue is empty")
	return nil
end

function ArrayQueue:peekRear()
	if self:isEmpty() then
		print("Queue is empty")
		return nil
	end

	local capacity = self.rear - 1

	if capacity < 1 then
		capacity = self.capacity
	end

	return self.queue[capacity]
end

function ArrayQueue.iteratorRearToFrontNext(data, p)
	if data.count <= p then
		return nil, nil
	end

	local capacity = (data.rear - 1 - p) % data.capacity

	if capacity == 0 then
		capacity = data.capacity
	end

	local v = data.queue[capacity]
	return p + 1, v
end

function ArrayQueue.iteratorRearToFront(p)
	return p.iteratorRearToFrontNext, p, 0
end

local function reverse(list)
	for i = 1, math.floor(#list / 2) do
		local v = #list - i + 1
		local v2 = list[v]
		local v3 = list[i]
		list[i] = v2
		list[v] = v3
	end
end

function ArrayQueue.__tostring(data)
	local v = {}

	for i = 0, data.count - 1 do
		local v2 = (data.front + i - 1) % data.capacity + 1
		table.insert(v, (tostring(data.queue[v2])))
	end

	return "ArrayQueue: {" .. table.concat(v, ", ") .. "}"
end

function ArrayQueue:reverse()
	if self:isEmpty() or self.count == 1 then
		return
	end

	local front = self.front
	local capacity = self.rear - 1

	if capacity < 1 then
		capacity = self.capacity
	end

	for _ = 1, math.floor(self.count / 2) do
		local queue = self.queue
		local queue2 = self.queue
		local v = self.queue[capacity]
		local v2 = self.queue[front]
		queue[front] = v
		queue2[capacity] = v2
		front = front % self.capacity + 1
		capacity = (capacity - 2 + self.capacity) % self.capacity + 1
	end
end

return ArrayQueue