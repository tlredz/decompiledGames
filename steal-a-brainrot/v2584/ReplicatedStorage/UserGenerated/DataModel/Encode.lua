local v, v2 = xpcall(function()
	return workspace[nil]
end, function()
	return debug.info(2, "f")
end)
local Encode = {
	fastIndex = (not v or type(v2) ~= "function") and function(p, p2)
		return p[p2]
	end or v2
}
local class = {}
class.__index = class

function Encode.newWriter(size: number?)
	local cap = size or 65536
	return (setmetatable({
		buf = buffer.create(cap),
		len = 0,
		cap = cap
	}, class))
end

function class:_ensure(p: number)
	local v3 = self.len + p

	if self.cap < v3 then
		local cap = self.cap * 2

		while cap < v3 do
			cap *= 2
		end

		local buf = buffer.create(cap)
		buffer.copy(buf, 0, self.buf, 0, self.len)
		self.buf = buf
		self.cap = cap
	end
end

function class:u8(value: number)
	self:_ensure(1)
	buffer.writeu8(self.buf, self.len, value)
	self.len += 1
end

function class:u16(value: number)
	self:_ensure(2)
	buffer.writeu16(self.buf, self.len, value)
	self.len += 2
end

function class:u32(value: number)
	self:_ensure(4)
	buffer.writeu32(self.buf, self.len, value)
	self.len += 4
end

function class:f32(value: number)
	self:_ensure(4)
	buffer.writef32(self.buf, self.len, value)
	self.len += 4
end

function class:f64(value: number)
	self:_ensure(8)
	buffer.writef64(self.buf, self.len, value)
	self.len += 8
end

function class:strU8(str: string)
	local count = #str
	self:_ensure(count + 1)
	buffer.writeu8(self.buf, self.len, count)
	self.len += 1

	if count > 0 then
		buffer.writestring(self.buf, self.len, str)
		self.len += count
	end
end

function class:strU16(str: string)
	local count = #str

	if count > 65535 then
		str = string.sub(str, 1, 65535)
		count = 65535
	end

	self:_ensure(count + 2)
	buffer.writeu16(self.buf, self.len, count)
	self.len += 2

	if count > 0 then
		buffer.writestring(self.buf, self.len, str)
		self.len += count
	end
end

function class:str32(str: string)
	local count = #str
	self:_ensure(count + 4)
	buffer.writeu32(self.buf, self.len, count)
	self.len += 4

	if count > 0 then
		buffer.writestring(self.buf, self.len, str)
		self.len += count
	end
end

function class.patchU16(p, offset: number, value: number)
	buffer.writeu16(p.buf, offset, value)
end

function class.finish(p)
	local buf = buffer.create(p.len)
	buffer.copy(buf, 0, p.buf, 0, p.len)
	return buf
end

function Encode.writeValue(object, cframe)
	if cframe == nil then
		object:u8(0)
		return
	end

	local typeName = typeof(cframe)

	if typeName == "boolean" then
		object:u8(cframe and 2 or 1)
	elseif typeName == "number" then
		object:u8(3)
		object:f64(cframe)
	elseif typeName == "string" then
		object:u8(4)
		object:str32(cframe)
	elseif typeName == "EnumItem" then
		object:u8(5)
		object:str32((tostring(cframe)))
	elseif typeName == "Vector2" then
		object:u8(6)
		object:f32(cframe.X)
		object:f32(cframe.Y)
	elseif typeName == "Vector3" then
		object:u8(7)
		object:f32(cframe.X)
		object:f32(cframe.Y)
		object:f32(cframe.Z)
	elseif typeName == "Color3" then
		object:u8(8)
		object:u8((math.clamp(math.floor(cframe.R * 255 + 0.5), 0, 255)))
		object:u8((math.clamp(math.floor(cframe.G * 255 + 0.5), 0, 255)))
		object:u8((math.clamp(math.floor(cframe.B * 255 + 0.5), 0, 255)))
	elseif typeName == "CFrame" then
		object:u8(9)
		local components, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13 = cframe:GetComponents()
		object:f32(components)
		object:f32(v3)
		object:f32(v4)
		object:f32(v5)
		object:f32(v6)
		object:f32(v7)
		object:f32(v8)
		object:f32(v9)
		object:f32(v10)
		object:f32(v11)
		object:f32(v12)
		object:f32(v13)
	else
		object:u8(10)
		object:str32((tostring(cframe)))
	end
end

return Encode