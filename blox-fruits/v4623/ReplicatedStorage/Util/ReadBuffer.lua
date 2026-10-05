local ReadBuffer = {}
ReadBuffer.__index = ReadBuffer

function ReadBuffer.new(buf: buffer)
	return (setmetatable({
		offset = 0,
		buf = buf
	}, ReadBuffer))
end

function ReadBuffer:ResetReadPos()
	self.offset = 0
end

function ReadBuffer:ReadU8()
	local v = buffer.readu8(self.buf, self.offset)
	self.offset += 1
	return v
end

function ReadBuffer:ReadI16()
	local v = buffer.readu16(self.buf, self.offset)
	self.offset += 2
	return v
end

function ReadBuffer:ReadVector3()
	local v = buffer.readf32(self.buf, self.offset)
	self.offset += 4
	local v2 = buffer.readf32(self.buf, self.offset)
	self.offset += 4
	local v3 = buffer.readf32(self.buf, self.offset)
	self.offset += 4
	return (Vector3.new(v, v2, v3))
end

function ReadBuffer:ReadFloat16()
	local v = buffer.readu8(self.buf, self.offset)
	self.offset += 1
	local v2 = buffer.readu8(self.buf, self.offset)
	self.offset += 1
	local v3 = bit32.btest(v, 128)
	local v4 = bit32.rshift(bit32.band(v, 127), 2)
	local v5 = bit32.lshift(bit32.band(v, 3), 8) + v2

	if v4 == 31 then
		if v5 ~= 0 then
			return (0 / 0)
		end

		if v3 then
			return -1e999
		end

		return 1e999
	else
		if v4 ~= 0 then
			local v6 = v5 / 1024 + 1
			return v3 and -math.ldexp(v6, v4 - 15) or math.ldexp(v6, v4 - 15)
		end

		if v5 == 0 then
			return 0
		end

		return v3 and -math.ldexp(v5 / 1024, -14) or math.ldexp(v5 / 1024, -14)
	end
end

return ReadBuffer