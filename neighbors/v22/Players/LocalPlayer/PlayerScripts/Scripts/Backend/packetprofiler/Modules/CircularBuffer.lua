local function rotate_indice(p, p2)
	return (p - 1) % p2 + 1
end

local CircularBuffer = {
	filled = function(self)
		return #self.history == self.max_length
	end,
	push = function(self, p)
		if not self:filled() then
			self.history[#self.history + 1] = p
			return
		end

		self.history[self.oldest] = p
		self.oldest = self.oldest == self.max_length and 1 or self.oldest + 1
	end,
	metatable = {}
}

function CircularBuffer.metatable.__index(p, p2)
	local count = #p.history

	if p2 == 0 or count < math.abs(p2) then
		return nil
	end

	if p2 >= 1 then
		local v = (p.oldest - p2 - 1) % count + 1
		return p.history[v]
	end

	if p2 <= -1 then
		local v = (p2 + 1 + p.oldest - 1) % count + 1
		return p.history[v]
	end
end

function CircularBuffer.metatable.__len(p)
	return #p.history
end

function CircularBuffer.new(max_length)
	if type(max_length) ~= "number" or max_length <= 1 then
		error("Buffer length must be a positive integer")
	end

	local v = {
		history = {},
		oldest = 1,
		max_length = max_length,
		push = CircularBuffer.push,
		filled = CircularBuffer.filled
	}
	setmetatable(v, CircularBuffer.metatable)
	return v
end

return CircularBuffer