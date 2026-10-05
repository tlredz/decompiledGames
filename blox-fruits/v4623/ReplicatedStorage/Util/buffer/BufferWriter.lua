local DataTypeBuffer = require(script.Parent.DataTypeBuffer)
require(script.Parent.Types)
local BufferWriter = {}
BufferWriter.__index = BufferWriter

function BufferWriter.new(value: number?)
	local v = typeof(value) ~= "number" and 0 or math.clamp(value, 0, 1073741824)
	return (setmetatable({
		_buffer = buffer.create(v),
		_cursor = 0,
		_size = 0
	}, BufferWriter))
end

function BufferWriter:_resizeUpTo(size: number)
	if size > 1073741824 then
		error(`cannot resize buffer to {size} bytes (max size: {1073741824} bytes)`, 3)
	end

	self._size = math.max(self._size, size)

	if size < buffer.len(self._buffer) then
		return
	end

	local v = math.log(size, 2)

	if math.floor(v) ~= v then
		size = 2 ^ (math.floor(v) + 1)
	end

	local _buffer = self._buffer
	local buf = buffer.create(size)
	buffer.copy(buf, 0, _buffer, 0)
	self._buffer = buf
end

function BufferWriter:WriteInt8(value: number)
	self:_resizeUpTo(self._cursor + 1)
	buffer.writei8(self._buffer, self._cursor, value)
	self._cursor += 1
end

function BufferWriter:WriteUInt8(value: number)
	self:_resizeUpTo(self._cursor + 1)
	buffer.writeu8(self._buffer, self._cursor, value)
	self._cursor += 1
end

function BufferWriter:WriteInt16(value: number)
	self:_resizeUpTo(self._cursor + 2)
	buffer.writei16(self._buffer, self._cursor, value)
	self._cursor += 2
end

function BufferWriter:WriteUInt16(value: number)
	self:_resizeUpTo(self._cursor + 2)
	buffer.writeu16(self._buffer, self._cursor, value)
	self._cursor += 2
end

function BufferWriter:WriteInt32(value: number)
	self:_resizeUpTo(self._cursor + 4)
	buffer.writei32(self._buffer, self._cursor, value)
	self._cursor += 4
end

function BufferWriter:WriteUInt32(value: number)
	self:_resizeUpTo(self._cursor + 4)
	buffer.writeu32(self._buffer, self._cursor, value)
	self._cursor += 4
end

function BufferWriter:WriteUInt32s(...)
	for _, v in { ... } do
		self:WriteUInt32(v)
	end
end

function BufferWriter:WriteFloat32(value: number)
	self:_resizeUpTo(self._cursor + 4)
	buffer.writef32(self._buffer, self._cursor, value)
	self._cursor += 4
end

function BufferWriter:WriteFloat64(value: number)
	self:_resizeUpTo(self._cursor + 8)
	buffer.writef64(self._buffer, self._cursor, value)
	self._cursor += 8
end

function BufferWriter:WriteFloat64s(...)
	for _, v in { ... } do
		self:WriteFloat64(v)
	end
end

function BufferWriter:WriteFloat16(p: number)
	self:_resizeUpTo(self._cursor + 2)
	local v = p < 0
	local v2 = math.abs(p)
	local v3, v4 = math.frexp(v2)

	if v2 == 1e999 then
		if v then
			buffer.writeu8(self._buffer, self._cursor, 252)
		else
			buffer.writeu8(self._buffer, self._cursor, 124)
		end

		self._cursor += 1
		buffer.writeu8(self._buffer, self._cursor, 0)
		self._cursor += 1
	elseif v2 == v2 and v2 ~= 0 then
		if v4 + 15 <= 1 then
			local v5 = math.floor(v3 * 1024 + 0.5)

			if v then
				buffer.writeu8(self._buffer, self._cursor, bit32.rshift(v5, 8) + 128)
			else
				buffer.writeu8(self._buffer, self._cursor, (bit32.rshift(v5, 8)))
			end

			self._cursor += 1
			buffer.writeu8(self._buffer, self._cursor, (bit32.band(v5, 255)))
			self._cursor += 1
		else
			local v5 = math.floor((v3 - 0.5) * 2048 + 0.5)

			if v then
				buffer.writeu8(self._buffer, self._cursor, bit32.lshift(v4 + 14, 2) + 128 + bit32.rshift(v5, 8))
			else
				buffer.writeu8(self._buffer, self._cursor, bit32.lshift(v4 + 14, 2) + bit32.rshift(v5, 8))
			end

			self._cursor += 1
			buffer.writeu8(self._buffer, self._cursor, (bit32.band(v5, 255)))
			self._cursor += 1
		end
	else
		buffer.writeu8(self._buffer, self._cursor, 0)
		self._cursor += 1
		buffer.writeu8(self._buffer, self._cursor, 0)
		self._cursor += 1
	end
end

function BufferWriter:WriteBool(flag: boolean)
	self:WriteUInt8(flag and 1 or 0)
end

function BufferWriter:WritePackedBools(...)
	local v = select("#", ...)

	if v == 0 then
		return
	end

	local v2 = math.ceil(v / 8)
	self:_resizeUpTo(self._cursor + v2)

	for i = 0, v2 - 1 do
		local v3 = i * 8
		local v4 = 0

		for i2 = 0, math.min(8, v - v3) - 1 do
			if select(v3 + i2 + 1, ...) then
				v4 = bit32.bor(v4, (bit32.lshift(1, i2)))
			end
		end

		buffer.writeu8(self._buffer, self._cursor + i, v4)
	end

	self._cursor += v2
end

function BufferWriter:WriteString(str: string, count: number?)
	local v

	if count then
		v = math.min(#str, count)
	else
		v = #str
	end

	local v2 = v + 4
	self:_resizeUpTo(self._cursor + v2)
	buffer.writeu32(self._buffer, self._cursor, v)
	buffer.writestring(self._buffer, self._cursor + 4, str, count)
	self._cursor += v2
end

function BufferWriter:WriteStringRaw(str: string, count: number?)
	local v

	if count then
		v = math.min(#str, count)
	else
		v = #str
	end

	self:_resizeUpTo(self._cursor + v)
	buffer.writestring(self._buffer, self._cursor, str, count)
	self._cursor += v
end

function BufferWriter.WriteDataType(p, p2)
	local typeName = typeof(p2)
	local v = DataTypeBuffer.ReadWrite[typeName]

	if not v then
		error(`unsupported data type "{typeName}"`, 2)
	end

	v.write(p, p2)
end

function BufferWriter:Shrink()
	if self._size == buffer.len(self._buffer) then
		return
	end

	local _buffer = self._buffer
	local buf = buffer.create(self._size)
	buffer.copy(buf, 0, _buffer, 0, self._size)
	self._buffer = buf
end

function BufferWriter:GetSize()
	return self._size
end

function BufferWriter:GetCapacity()
	return buffer.len(self._buffer)
end

function BufferWriter:SetCursor(p2: number)
	local cursor = math.floor(p2)

	if cursor < 0 or self._size < cursor then
		error(`cursor position {cursor} out of range [0, {self._size}]`, 3)
	end

	self._cursor = cursor
end

function BufferWriter:GetCursor()
	return self._cursor
end

function BufferWriter:ResetCursor()
	self._cursor = 0
end

function BufferWriter:GetBuffer()
	return self._buffer
end

function BufferWriter:ToString()
	return buffer.tostring(self._buffer)
end

function BufferWriter.__tostring(_)
	return "BufferWriter"
end

return BufferWriter