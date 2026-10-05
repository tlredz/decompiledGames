local Deque = {}
Deque.__index = Deque
Deque.ClassName = "Deque"

function Deque.new(p)
	return Deque.raw(table.clone(p))
end

function Deque.raw(elements)
	local self = setmetatable({}, Deque)
	self.index = 1
	self.length = #elements
	self.elements = elements
	return self
end

function Deque:getElement(p: number)
	local v

	if p > 0 then
		v = p <= self.length
	else
		v = false
	end

	assert(v, "Index out of range.")
	return self.elements[self.index + p - 1]
end

function Deque:getElements()
	local v = table.create(self.length, nil)
	table.move(self.elements, self.index, self.index + self.length - 1, 1, v)
	return v
end

function Deque.getLength(p)
	return p.length
end

function Deque.find(data, p)
	for i = 1, data.length do
		local v = data.index + (i - 1)

		if data.elements[v] == p then
			return v
		end
	end

	return nil
end

function Deque:drain(p: number, p2: number)
	local v

	if p > 0 and p <= self.length and p2 > 0 then
		v = p + p2 - 1 <= self.length
	else
		v = false
	end

	assert(v, "Index out of range.")
	local elements = {}

	for i = p, p + p2 - 1 do
		local v2 = self.index + i - 1
		local element = self.elements[v2]
		self.elements[v2] = nil
		table.insert(elements, element)
	end

	local v2 = p - 1
	local v3 = self.length - (p + p2 - 1)

	if v2 < v3 then
		local v4 = self.index + p + p2 - 1 - v2

		for i = v2, 1, -1 do
			local v5 = self.index + i - 1
			self.elements[v4 + i - 1] = self.elements[v5]
			self.elements[v5] = nil
		end

		self.index = v4
	else
		local v4 = self.index + p - 1
		local v5 = self.index + p + p2 - 1

		for i = 1, v3 do
			local v6 = v5 + i - 1
			self.elements[v4 + i - 1] = self.elements[v6]
			self.elements[v6] = nil
		end
	end

	self.length -= p2
	return elements
end

function Deque:insert(p: number, p2)
	local v

	if p > 0 then
		v = p <= self.length + 1
	else
		v = false
	end

	assert(v, "Index out of range.")

	if p < math.floor(self.length / 2) then
		for i = 1, p - 1 do
			local v2 = self.index + i - 1
			self.elements[v2 - 1] = self.elements[v2]
		end

		self.index -= 1
	else
		for i = self.length, p, -1 do
			local v2 = self.index + i - 1
			self.elements[v2 + 1] = self.elements[v2]
		end
	end

	self.elements[self.index + p - 1] = p2
	self.length += 1
end

function Deque:remove(p: number)
	return self:drain(p, 1)[1]
end

function Deque:popBack()
	return self:drain(self.length, 1)[1]
end

function Deque:pushBack(p)
	self:insert(self.length + 1, p)
end

function Deque:popFront()
	return self:drain(1, 1)[1]
end

function Deque:pushFront(p)
	self:insert(1, p)
end

function Deque:replace(p: number, p2)
	local v

	if p > 0 then
		v = p <= self.length + 1
	else
		v = false
	end

	assert(v, "Index out of range.")
	self.elements[self.index + p - 1] = p2
end

function Deque:swap(p: number, p2: number)
	local element = self:getElement(p)
	self:replace(p, (self:getElement(p2)))
	self:replace(p2, element)
end

function Deque:rotate(p: number)
	if p > 0 then
		for _ = 1, p do
			self:pushFront(self:popBack())
		end
	elseif p < 0 then
		for _ = 1, math.abs(p) do
			self:pushBack(self:popFront())
		end
	end
end

function Deque.reverse(data)
	local v = math.floor(data.length / 2)
	local v2 = data.index + data.length - 1

	for i = 1, v do
		local v3 = data.index + i - 1
		local v4 = v2 - i + 1
		local elements = data.elements
		local elements2 = data.elements
		local element = data.elements[v4]
		local element2 = data.elements[v3]
		elements[v3] = element
		elements2[v4] = element2
	end
end

function Deque:clone()
	local elements = self:getElements()
	return Deque.raw(elements)
end

function Deque:clear()
	self.index = 1
	self.length = 0
	self.elements = {}
end

return Deque