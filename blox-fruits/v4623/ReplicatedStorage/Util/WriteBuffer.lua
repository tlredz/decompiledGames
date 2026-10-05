local WriteBuffer = {}
WriteBuffer.__index = WriteBuffer

function WriteBuffer.new(p)
	return (setmetatable({
		offset = 0,
		currentSize = 0,
		startSize = p == nil and 0 or math.max(p, 0),
		stepSize = 128,
		buf = nil
	}, WriteBuffer))
end

function WriteBuffer:GetBuffer()
	if buffer.len(self.buf) == self.offset then
		return self.buf
	end

	local buf = buffer.create(self.offset)
	self.currentSize = self.offset
	buffer.copy(buf, 0, self.buf, 0, self.offset)
	self.buf = buf
	return buf
end

function WriteBuffer:CheckSize(p: number)
	local v = self.offset + p

	if self.buf == nil or self.currentSize < v then
		if self.buf == nil then
			self.currentSize = math.max(self.startSize, p)
		else
			self.currentSize += math.max(self.stepSize, p)
		end

		local buf = buffer.create(self.currentSize)

		if self.buf then
			buffer.copy(buf, 0, self.buf, 0, self.offset)
		end

		self.buf = buf
	end
end

function WriteBuffer:WriteU8(value: number)
	self:CheckSize(1)
	buffer.writeu8(self.buf, self.offset, value)
	self.offset += 1
end

function WriteBuffer:WriteI16(value: number)
	self:CheckSize(2)
	buffer.writeu16(self.buf, self.offset, value)
	self.offset += 2
end

function WriteBuffer:WriteVector3(vector: Vector3)
	self:CheckSize(12)
	buffer.writef32(self.buf, self.offset, vector.X)
	self.offset += 4
	buffer.writef32(self.buf, self.offset, vector.Y)
	self.offset += 4
	buffer.writef32(self.buf, self.offset, vector.Z)
	self.offset += 4
end

function WriteBuffer:WriteFloat16(p: number)
	self:CheckSize(2)
	local v = p < 0
	local v2 = math.abs(p)
	local v3, v4 = math.frexp(v2)

	if v2 == 1e999 then
		if v then
			buffer.writeu8(self.buf, self.offset, 252)
		else
			buffer.writeu8(self.buf, self.offset, 124)
		end

		self.offset += 1
		buffer.writeu8(self.buf, self.offset, 0)
		self.offset += 1
	elseif v2 == v2 and v2 ~= 0 then
		if v4 + 15 <= 1 then
			local v5 = math.floor(v3 * 1024 + 0.5)

			if v then
				buffer.writeu8(self.buf, self.offset, bit32.rshift(v5, 8) + 128)
			else
				buffer.writeu8(self.buf, self.offset, (bit32.rshift(v5, 8)))
			end

			self.offset += 1
			buffer.writeu8(self.buf, self.offset, (bit32.band(v5, 255)))
			self.offset += 1
		else
			local v5 = math.floor((v3 - 0.5) * 2048 + 0.5)

			if v then
				buffer.writeu8(self.buf, self.offset, bit32.lshift(v4 + 14, 2) + 128 + bit32.rshift(v5, 8))
			else
				buffer.writeu8(self.buf, self.offset, bit32.lshift(v4 + 14, 2) + bit32.rshift(v5, 8))
			end

			self.offset += 1
			buffer.writeu8(self.buf, self.offset, (bit32.band(v5, 255)))
			self.offset += 1
		end
	else
		buffer.writeu8(self.buf, self.offset, 0)
		self.offset += 1
		buffer.writeu8(self.buf, self.offset, 0)
		self.offset += 1
	end
end

return WriteBuffer