local parent = script.Parent
local Guid = require(parent.Guid)
local BufferExtras = require(parent.BufferExtras)
local CrunchTable = {
	Enum = table.freeze({
		IGNORE = 0,
		BOOL = 1,
		BOOLEAN = 1,
		UINT8 = 2,
		BYTE = 2,
		INT8 = 3,
		SBYTE = 3,
		UINT16 = 4,
		USHORT = 4,
		INT16 = 5,
		SHORT = 5,
		UINT32 = 6,
		UINT = 6,
		INT32 = 7,
		INT = 7,
		FLOAT16 = 8,
		HALF = 8,
		FLOAT32 = 9,
		SINGLE = 9,
		FLOAT = 9,
		FLOAT64 = 10,
		DOUBLE = 10,
		INT53 = 11,
		UINT53 = 12,
		Vector2 = 13,
		Vector3 = 14,
		NumberRange = 15,
		STRING8 = 16,
		STRING16 = 17,
		STRING24 = 18,
		STRING32 = 19,
		STRING64 = 20,
		GUID = 21
	})
}
local v = {}
local v2 = {}

local function stringIO(count: number)
	return {
		Size = count,
		Default = "",
		Reader = function(buf: buffer, offset: number)
			return buffer.readstring(buf, offset, count):gsub("\0", "")
		end,
		Writer = function(buf: buffer, p: number, value: string)
			for i = 1, math.min(#value, count) do
				local v3 = value:sub(i, i)
				buffer.writeu8(buf, p + i - 1, (v3:byte()))
			end
		end
	}
end

v2[CrunchTable.Enum.IGNORE] = table.freeze({
	Size = 0,
	Default = nil,
	Reader = function() end,
	Writer = function() end
})
v2[CrunchTable.Enum.BOOL] = table.freeze({
	Size = 1,
	Default = false,
	Reader = function(buf: buffer, offset: number)
		return buffer.readu8(buf, offset) > 0
	end,
	Writer = function(buf: buffer, offset: number, flag: boolean)
		buffer.writeu8(buf, offset, flag and 1 or 0)
	end
})
v2[CrunchTable.Enum.UINT8] = table.freeze({
	Size = 1,
	Default = 0,
	Reader = buffer.readu8,
	Writer = buffer.writeu8
})
v2[CrunchTable.Enum.INT8] = table.freeze({
	Size = 1,
	Default = 0,
	Reader = buffer.readi8,
	Writer = buffer.writei8
})
v2[CrunchTable.Enum.UINT16] = table.freeze({
	Size = 2,
	Default = 0,
	Reader = buffer.readu16,
	Writer = buffer.writeu16
})
v2[CrunchTable.Enum.INT16] = table.freeze({
	Size = 2,
	Default = 0,
	Reader = buffer.readi16,
	Writer = buffer.writei16
})
v2[CrunchTable.Enum.UINT32] = table.freeze({
	Size = 4,
	Default = 0,
	Reader = buffer.readu32,
	Writer = buffer.writeu32
})
v2[CrunchTable.Enum.INT32] = {
	Size = 4,
	Default = 0,
	Reader = buffer.readi32,
	Writer = buffer.writei32
}
v2[CrunchTable.Enum.FLOAT16] = table.freeze({
	Size = 2,
	Default = 0,
	Reader = BufferExtras.ReadFloat16,
	Writer = BufferExtras.WriteFloat16
})
v2[CrunchTable.Enum.FLOAT32] = table.freeze({
	Size = 4,
	Default = 0,
	Reader = buffer.readf32,
	Writer = buffer.writef32
})
v2[CrunchTable.Enum.FLOAT64] = table.freeze({
	Size = 8,
	Default = 0,
	Reader = buffer.readf64,
	Writer = buffer.writef64
})
v2[CrunchTable.Enum.INT53] = table.freeze({
	Size = 8,
	Default = 0,
	Reader = BufferExtras.ReadInt53,
	Writer = BufferExtras.WriteInt53
})
v2[CrunchTable.Enum.UINT53] = table.freeze({
	Size = 8,
	Default = 0,
	Reader = BufferExtras.ReadUInt53,
	Writer = BufferExtras.WriteUInt53
})
v2[CrunchTable.Enum.Vector2] = {
	Size = 8,
	Default = Vector2.zero,
	Reader = function(buf: buffer, offset: number)
		local v3 = buffer.readf32(buf, offset)
		local v4 = buffer.readf32(buf, offset + 4)
		return Vector2.new(v3, v4)
	end,
	Writer = function(buf: buffer, offset: number, point: Vector2)
		buffer.writef32(buf, offset, point.X)
		buffer.writef32(buf, offset + 4, point.Y)
	end
}
v2[CrunchTable.Enum.Vector3] = {
	Size = 12,
	Default = vector.create(0, 0, 0),
	Reader = function(buf: buffer, offset: number)
		return (Vector3.new(
			buffer.readf32(buf, offset),
			buffer.readf32(buf, offset + 4),
			(buffer.readf32(buf, offset + 8))
		))
	end,
	Writer = function(buf: buffer, offset: number, vector2: Vector3)
		buffer.writef32(buf, offset, vector2.X)
		buffer.writef32(buf, offset + 4, vector2.Y)
		buffer.writef32(buf, offset + 8, vector2.Z)
	end
}
v2[CrunchTable.Enum.NumberRange] = {
	Size = 8,
	Default = NumberRange.new(0),
	Reader = function(buf: buffer, offset: number)
		local v3 = buffer.readf32(buf, offset)
		local v4 = buffer.readf32(buf, offset + 4)
		return NumberRange.new(v3, v4)
	end,
	Writer = function(buf: buffer, offset: number, range: NumberRange)
		buffer.writef32(buf, offset, range.Min)
		buffer.writef32(buf, offset + 4, range.Max)
	end
}
v2[CrunchTable.Enum.GUID] = {
	Size = 16,
	Default = "00000000-0000-0000-0000-000000000000",
	Reader = Guid.Decompress,
	Writer = Guid.Compress
}
v2[CrunchTable.Enum.STRING8] = stringIO(8)
v2[CrunchTable.Enum.STRING16] = stringIO(16)
v2[CrunchTable.Enum.STRING24] = stringIO(24)
v2[CrunchTable.Enum.STRING32] = stringIO(32)
v2[CrunchTable.Enum.STRING64] = stringIO(64)
local class = {}
class.__index = class

local function calcSize(p)
	if v[p] then
		return
	end

	local count = #p.Fields
	local contentBytes = nil
	local readu8 = nil
	local writeu8 = nil

	if count <= 8 then
		readu8 = buffer.readu8
		writeu8 = buffer.writeu8
		contentBytes = 1
	elseif count <= 16 then
		readu8 = buffer.readu16
		writeu8 = buffer.writeu16
		contentBytes = 2
	elseif count <= 32 then
		readu8 = buffer.readu32
		writeu8 = buffer.writeu32
		contentBytes = 4
	else
		error("!! FATAL: Exceeded limit of 32 fields in CrunchTable layout!")
	end

	p.ContentBytes = contentBytes
	p.ContentReader = readu8
	p.ContentWriter = writeu8
	local total = 0

	for _, field in p.Fields do
		total += field.Size
	end

	p.FieldBytes = total
	p.TotalBytes = contentBytes + total
end

function class:Begin(flag: boolean?)
	if flag == nil then
		v[self] = true
		return self
	end

	v[self] = flag
	return self
end

function class:End()
	if v[self] ~= nil then
		v[self] = nil
		calcSize(self)
	end
end

function class:Add(name: string, enum: number, required: boolean?)
	local v3 = v2[enum]

	if required == nil then
		required = v[self]
	end

	local frozen = table.freeze({
		Required = required,
		Default = v3.Default,
		Write = v3.Writer,
		Read = v3.Reader,
		Size = v3.Size,
		Name = name,
		Enum = enum
	})
	self.FieldsByName[name] = frozen
	table.insert(self.Fields, frozen)
	calcSize(self)
	return self
end

function class.GetFieldInfo(p, p2: string)
	return p.FieldsByName[p2]
end

function class:WriteToBuffer(p, buf: buffer, value: number?, callback)
	local contentWriter = self.ContentWriter
	local v3 = (value or 0) + self.ContentBytes
	local total = 0
	local total2 = 1

	for _, field in self.Fields do
		local name = field.Name
		local v4 = p[name]

		if v4 ~= nil then
			field.Write(buf, v3, v4)
			v3 += field.Size
			total += total2

			if callback then
				callback(name)
			end
		end

		total2 += total2
	end

	contentWriter(buf, value or 0, total)
	return v3
end

function class:Compress(p)
	local clone = table.clone(p)
	local buf = buffer.create(self.TotalBytes)
	local v3 = self:WriteToBuffer(p, buf, 0, function(p2: string)
		clone[p2] = nil
	end)
	local buf2 = buffer.create(v3)
	buffer.copy(buf2, 0, buf, 0, v3)
	clone._b = buf2
	return clone
end

function class:ReadFromBuffer(buf: buffer, value: number, callback)
	local v3 = value or 0
	local contentReader = self.ContentReader(buf, v3)
	local v4 = v3 + self.ContentBytes
	local total = 1

	for _, field in self.Fields do
		if bit32.btest(contentReader, total) then
			local v5 = field.Read(buf, v4)
			callback(field.Name, v5)
			v4 += field.Size
		elseif field.Required then
			callback(field.Name, field.Default)
		end

		total += total
	end

	return v4
end

function class:Decompress(p)
	local _b = p._b
	local clone = table.clone(p)
	clone._b = nil
	self:ReadFromBuffer(_b, 0, function(p2: string, p3)
		clone[p2] = p3
	end)
	return clone
end

function class.Clone(data)
	return (setmetatable({
		FieldsByName = table.clone(data.FieldsByName),
		Fields = table.clone(data.Fields),
		TotalBytes = data.TotalBytes,
		FieldBytes = data.FieldBytes,
		ContentBytes = data.ContentBytes,
		ContentReader = data.ContentReader,
		ContentWriter = data.ContentWriter
	}, class))
end

function CrunchTable.new(items)
	local self = setmetatable({
		FieldsByName = {},
		Fields = {},
		TotalBytes = 0,
		FieldBytes = 0,
		ContentBytes = 0,
		ContentReader = buffer.readu8,
		ContentWriter = buffer.writeu8
	}, class)

	if not items then
		return self
	end

	local v3 = {}

	for k in items do
		table.insert(v3, k)
	end

	self:Begin(false)
	table.sort(v3)

	for _, v4 in v3 do
		self:Add(v4, items[v4])
	end

	self:End()
	return self
end

return CrunchTable