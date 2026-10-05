local BufferWriter = require(script.Parent.BufferWriter)
local DataTypeBuffer = require(script.Parent.DataTypeBuffer)
require(script.Parent.Types)
local BufferReader = {}
BufferReader.__index = BufferReader

function BufferReader:new()
	if typeof(self) == "string" then
		return BufferReader.fromString(self)
	end

	if typeof(self) == "buffer" then
		return BufferReader.fromBuffer(self)
	end

	if typeof(self) == "table" and getmetatable(self) == BufferWriter then
		return BufferReader.fromBuffer(self:GetBuffer())
	end

	error((`expected string or buffer; got {typeof(self)}`))
end

function BufferReader.fromBuffer(buf: buffer)
	return (setmetatable({
		_buffer = buf,
		_size = buffer.len(buf),
		_cursor = 0
	}, BufferReader))
end

function BufferReader.fromString(str: string)
	return BufferReader.fromBuffer(buffer.fromstring(str))
end

function BufferReader:_assertSize(p2: number)
	if self._size < p2 then
		error("cursor out of bounds", 3)
	end
end

function BufferReader:ReadInt8()
	self:_assertSize(self._cursor + 1)
	local v = buffer.readi8(self._buffer, self._cursor)
	self._cursor += 1
	return v
end

function BufferReader:ReadUInt8()
	self:_assertSize(self._cursor + 1)
	local v = buffer.readu8(self._buffer, self._cursor)
	self._cursor += 1
	return v
end

function BufferReader:ReadInt16()
	self:_assertSize(self._cursor + 2)
	local v = buffer.readi16(self._buffer, self._cursor)
	self._cursor += 2
	return v
end

function BufferReader:ReadUInt16()
	self:_assertSize(self._cursor + 2)
	local v = buffer.readu16(self._buffer, self._cursor)
	self._cursor += 2
	return v
end

function BufferReader:ReadInt32()
	self:_assertSize(self._cursor + 4)
	local v = buffer.readi32(self._buffer, self._cursor)
	self._cursor += 4
	return v
end

function BufferReader:ReadUInt32()
	self:_assertSize(self._cursor + 4)
	local v = buffer.readu32(self._buffer, self._cursor)
	self._cursor += 4
	return v
end

function BufferReader:ReadFloat16()
	self:_assertSize(self._cursor + 2)
	local v = buffer.readu8(self._buffer, self._cursor)
	self._cursor += 1
	local v2 = buffer.readu8(self._buffer, self._cursor)
	self._cursor += 1
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

function BufferReader:ReadFloat32()
	self:_assertSize(self._cursor + 4)
	local v = buffer.readf32(self._buffer, self._cursor)
	self._cursor += 4
	return v
end

function BufferReader:ReadFloat64()
	self:_assertSize(self._cursor + 8)
	local v = buffer.readf64(self._buffer, self._cursor)
	self._cursor += 8
	return v
end

function BufferReader:ReadBool()
	return self:ReadUInt8() == 1
end

function BufferReader:ReadPackedBools(p: number)
	local v = math.max(0, (math.floor(p)))

	if v == 0 then
		return
	end

	local v2 = math.ceil(v / 8)
	self:_assertSize(self._cursor + v2)
	local v3 = table.create(v)

	for i = 0, v2 - 1 do
		local v4 = buffer.readu8(self._buffer, self._cursor + i)
		local v5 = i * 8

		for i2 = 0, math.min(8, v - v5) - 1 do
			v3[v5 + i2 + 1] = bit32.btest(v4, (bit32.lshift(1, i2)))
		end
	end

	self._cursor += v2
	return table.unpack(v3)
end

function BufferReader:ReadString()
	local uInt32 = self:ReadUInt32()
	self:_assertSize(self._cursor + uInt32)
	local v = buffer.readstring(self._buffer, self._cursor, uInt32)
	self._cursor += uInt32
	return v
end

function BufferReader:ReadStringRaw(p: number)
	local v = math.max(0, (math.floor(p)))
	self:_assertSize(self._cursor + v)
	local v2 = buffer.readstring(self._buffer, self._cursor, v)
	self._cursor += v
	return v2
end

function BufferReader.ReadDataType(p, p2)
	local v = DataTypeBuffer.DataTypesToString[p2]

	if not v then
		error("unsupported data type", 2)
	end

	return DataTypeBuffer.ReadWrite[v].read(p)
end

function BufferReader:SetCursor(p2: number)
	local cursor = math.floor(p2)

	if cursor < 0 or self._size < cursor then
		error(`cursor position {cursor} out of range [0, {self._size}]`, 3)
	end

	self._cursor = cursor
end

function BufferReader:GetCursor()
	return self._cursor
end

function BufferReader:ResetCursor()
	self._cursor = 0
end

function BufferReader:GetSize()
	return self._size
end

function BufferReader:GetBuffer()
	return self._buffer
end

function BufferReader.__tostring(_)
	return "BufferReader"
end

return BufferReader