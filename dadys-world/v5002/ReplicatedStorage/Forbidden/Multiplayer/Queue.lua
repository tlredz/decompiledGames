local Queue = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Forbidden"):WaitForChild("Multiplayer")
Queue.Queues = {}

function Queue.Length(p)
	return p.tail - p.head
end

function Queue.is_empty(p)
	return Queue.Length(p) == 0
end

function Queue:AddToBack(p2)
	assert(p2 ~= nil)
	self.tail += 1
	self[self.tail] = p2
end

function Queue:AddToFront(p2)
	assert(p2 ~= nil)
	self[self.head] = p2
	self.head -= 1
end

function Queue.ReadBack(p)
	return p[p.tail]
end

function Queue.ReadFront(p)
	return p[p.head + 1]
end

function Queue:RemoveBack()
	if Queue.is_empty(self) then
		return nil
	end

	local v = self[self.tail]
	self[self.tail] = nil
	self.tail -= 1
	return v
end

function Queue:RemoveFront()
	if Queue.is_empty(self) then
		return nil
	end

	local _ = self[self.head + 1]
	self.head += 1
	local v = self[self.head]
	self[self.head] = nil
	return v
end

function Queue.RotateTowardsBack(p, value)
	if Queue.is_empty(p) then
		return nil
	end

	for _ = 1, value or 1 do
		Queue.AddToFront(p, Queue.RemoveBack(p))
	end
end

function Queue.RotateTowardsFront(p, value)
	if Queue.is_empty(p) then
		return nil
	end

	for _ = 1, value or 1 do
		Queue.AddToBack(p, Queue.RemoveFront(p))
	end
end

function Queue.SendToBack(p, p2)
	for i = p.head + 1, p.tail do
		if p[i] ~= p2 then
			continue
		end

		Queue.RotateTowardsBack(p, p.tail - i)
		return true
	end

	return false
end

function Queue.BringToFront(p, p2)
	for i = p.tail, p.head + 1, -1 do
		if p[i] ~= p2 then
			continue
		end

		Queue.RotateTowardsFront(p, i - 1)
		return true
	end

	return false
end

function Queue:Remove(p2)
	for i = self.head + 1, self.tail do
		if self[i] ~= p2 then
			continue
		end

		for i2 = i, self.tail do
			self[i2] = self[i2 + 1]
		end

		self.tail -= 1
		return true
	end

	return false
end

function Queue.Contents(p)
	local result = {}

	for i = p.head + 1, p.tail do
		result[i - p.head] = p[i]
	end

	return result
end

function Queue.SequentialRemovalFromFront(p)
	local v = p.tail + 1
	return function()
		if v > p.head + 1 then
			v -= 1
			return p[v]
		end
	end
end

function Queue.SequentialRemovalFromBack(p)
	local head = p.head
	return function()
		if head < p.tail then
			head += 1
			return p[head]
		end
	end
end

function Queue.New(_)
	return {
		head = 0,
		tail = 0
	}
end

return Queue