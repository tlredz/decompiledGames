local buf = buffer.create(10240)
local Sera = {
	BB = buf,
	Boolean = table.freeze({
		Name = "Boolean",
		Ser = function(buf2: buffer, offset: number, flag: boolean)
			if flag == true then
				buffer.writeu8(buf2, offset, 1)
			elseif flag == false then
				buffer.writeu8(buf2, offset, 0)
			else
				error("Expected boolean")
			end

			return offset + 1
		end,
		Des = function(buf2: buffer, offset: number)
			return buffer.readu8(buf2, offset) == 1, offset + 1
		end
	}),
	Uint8 = table.freeze({
		Name = "Uint8",
		Ser = function(buf2: buffer, offset: number, value: number)
			buffer.writeu8(buf2, offset, value)
			return offset + 1
		end,
		Des = function(buf2: buffer, offset: number)
			return buffer.readu8(buf2, offset), offset + 1
		end
	}),
	Uint16 = table.freeze({
		Name = "Uint16",
		Ser = function(buf2: buffer, offset: number, value: number)
			buffer.writeu16(buf2, offset, value)
			return offset + 2
		end,
		Des = function(buf2: buffer, offset: number)
			return buffer.readu16(buf2, offset), offset + 2
		end
	}),
	Uint32 = table.freeze({
		Name = "Uint32",
		Ser = function(buf2: buffer, offset: number, value: number)
			buffer.writeu32(buf2, offset, value)
			return offset + 4
		end,
		Des = function(buf2: buffer, offset: number)
			return buffer.readu32(buf2, offset), offset + 4
		end
	}),
	Int8 = table.freeze({
		Name = "Int8",
		Ser = function(buf2: buffer, offset: number, value: number)
			buffer.writei8(buf2, offset, value)
			return offset + 1
		end,
		Des = function(buf2: buffer, offset: number)
			return buffer.readi8(buf2, offset), offset + 1
		end
	}),
	Int16 = table.freeze({
		Name = "Int16",
		Ser = function(buf2: buffer, offset: number, value: number)
			buffer.writei16(buf2, offset, value)
			return offset + 2
		end,
		Des = function(buf2: buffer, offset: number)
			return buffer.readi16(buf2, offset), offset + 2
		end
	}),
	Int32 = table.freeze({
		Name = "Int32",
		Ser = function(buf2: buffer, offset: number, value: number)
			buffer.writei32(buf2, offset, value)
			return offset + 4
		end,
		Des = function(buf2: buffer, offset: number)
			return buffer.readi32(buf2, offset), offset + 4
		end
	}),
	Float32 = table.freeze({
		Name = "Float32",
		Ser = function(buf2: buffer, offset: number, value: number)
			buffer.writef32(buf2, offset, value)
			return offset + 4
		end,
		Des = function(buf2: buffer, offset: number)
			return buffer.readf32(buf2, offset), offset + 4
		end
	}),
	Float64 = table.freeze({
		Name = "Float64",
		Ser = function(buf2: buffer, offset: number, value: number)
			buffer.writef64(buf2, offset, value)
			return offset + 8
		end,
		Des = function(buf2: buffer, offset: number)
			return buffer.readf64(buf2, offset), offset + 8
		end
	}),
	CFrame = table.freeze({
		Name = "CFrame",
		Ser = function(buf2: buffer, offset: number, cframe: CFrame)
			local components, v, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11 = cframe:GetComponents()
			buffer.writef32(buf2, offset, components)
			buffer.writef32(buf2, offset + 4, v)
			buffer.writef32(buf2, offset + 8, v2)
			buffer.writef32(buf2, offset + 12, v3)
			buffer.writef32(buf2, offset + 16, v4)
			buffer.writef32(buf2, offset + 20, v5)
			buffer.writef32(buf2, offset + 24, v6)
			buffer.writef32(buf2, offset + 28, v7)
			buffer.writef32(buf2, offset + 32, v8)
			buffer.writef32(buf2, offset + 36, v9)
			buffer.writef32(buf2, offset + 40, v10)
			buffer.writef32(buf2, offset + 44, v11)
			return offset + 48
		end,
		Des = function(buf2: buffer, offset: number)
			return
				CFrame.new(
					buffer.readf32(buf2, offset),
					buffer.readf32(buf2, offset + 4),
					buffer.readf32(buf2, offset + 8),
					buffer.readf32(buf2, offset + 12),
					buffer.readf32(buf2, offset + 16),
					buffer.readf32(buf2, offset + 20),
					buffer.readf32(buf2, offset + 24),
					buffer.readf32(buf2, offset + 28),
					buffer.readf32(buf2, offset + 32),
					buffer.readf32(buf2, offset + 36),
					buffer.readf32(buf2, offset + 40),
					(buffer.readf32(buf2, offset + 44))
				),
				offset + 48
		end
	}),
	LossyCFrame = table.freeze({
		Name = "LossyCFrame",
		Ser = function(buf2: buffer, offset: number, cframe: CFrame)
			local axisAngle, v = cframe:ToAxisAngle()
			buffer.writef32(buf2, offset, cframe.X)
			buffer.writef32(buf2, offset + 4, cframe.Y)
			buffer.writef32(buf2, offset + 8, cframe.Z)
			buffer.writef32(buf2, offset + 12, axisAngle.X)
			buffer.writef32(buf2, offset + 16, axisAngle.Y)
			buffer.writef32(buf2, offset + 20, axisAngle.Z)
			buffer.writef32(buf2, offset + 24, v)
			return offset + 28
		end,
		Des = function(buf2: buffer, offset: number)
			return
				CFrame.fromAxisAngle(
					Vector3.new(
						buffer.readf32(buf2, offset + 12),
						buffer.readf32(buf2, offset + 16),
						(buffer.readf32(buf2, offset + 20))
					),
					(buffer.readf32(buf2, offset + 24))
				) + Vector3.new(
					buffer.readf32(buf2, offset),
					buffer.readf32(buf2, offset + 4),
					(buffer.readf32(buf2, offset + 8))
				),
				offset + 28
		end
	}),
	Vector3 = table.freeze({
		Name = "Vector3",
		Ser = function(buf2: buffer, offset: number, vector: Vector3)
			buffer.writef32(buf2, offset, vector.X)
			buffer.writef32(buf2, offset + 4, vector.Y)
			buffer.writef32(buf2, offset + 8, vector.Z)
			return offset + 12
		end,
		Des = function(buf2: buffer, offset: number)
			return
				Vector3.new(
					buffer.readf32(buf2, offset),
					buffer.readf32(buf2, offset + 4),
					(buffer.readf32(buf2, offset + 8))
				),
				offset + 12
		end
	}),
	Color3 = table.freeze({
		Name = "Color3",
		Ser = function(buf2: buffer, offset: number, color: Color3)
			buffer.writeu8(buf2, offset, color.R * 255)
			buffer.writeu8(buf2, offset + 1, color.G * 255)
			buffer.writeu8(buf2, offset + 2, color.B * 255)
			return offset + 3
		end,
		Des = function(buf2: buffer, offset: number)
			return
				Color3.fromRGB(
					buffer.readu8(buf2, offset),
					buffer.readu8(buf2, offset + 1),
					(buffer.readu8(buf2, offset + 2))
				),
				offset + 3
		end
	}),
	ColorV3 = table.freeze({
		Name = "ColorV3",
		Ser = function(buf2: buffer, offset: number, vector: Vector3)
			buffer.writeu8(buf2, offset, vector.X * 255)
			buffer.writeu8(buf2, offset + 1, vector.Y * 255)
			buffer.writeu8(buf2, offset + 2, vector.Z * 255)
			return offset + 3
		end,
		Des = function(buf2: buffer, offset: number)
			return
				Vector3.new(
					buffer.readu8(buf2, offset) / 255,
					buffer.readu8(buf2, offset + 1) / 255,
					buffer.readu8(buf2, offset + 2) / 255
				),
				offset + 3
		end
	}),
	String8 = table.freeze({
		Name = "String8",
		Ser = function(buf2: buffer, offset: number, str: string)
			local v = str:len()

			if v > 255 then
				error("String too long")
			end

			buffer.writeu8(buf2, offset, v)
			buffer.writestring(buf2, offset + 1, str)
			return offset + 1 + v
		end,
		Des = function(buf2: buffer, offset: number)
			local v = buffer.readu8(buf2, offset)
			return buffer.readstring(buf2, offset + 1, v), offset + 1 + v
		end
	}),
	String16 = table.freeze({
		Name = "String16",
		Ser = function(buf2: buffer, offset: number, str: string)
			local v = str:len()

			if v > 65535 then
				error("String too long")
			end

			buffer.writeu16(buf2, offset, v)
			buffer.writestring(buf2, offset + 2, str)
			return offset + 2 + v
		end,
		Des = function(buf2: buffer, offset: number)
			local v = buffer.readu16(buf2, offset)
			return buffer.readstring(buf2, offset + 2, v), offset + 2 + v
		end
	}),
	String32 = table.freeze({
		Name = "String32",
		Ser = function(buf2: buffer, offset: number, str: string)
			local v = str:len()

			if v > 4294967295 then
				error("String too long")
			end

			buffer.writeu32(buf2, offset, v)
			buffer.writestring(buf2, offset + 4, str)
			return offset + 4 + v
		end,
		Des = function(buf2: buffer, offset: number)
			local v = buffer.readu32(buf2, offset)
			return buffer.readstring(buf2, offset + 4, v), offset + 4 + v
		end
	}),
	Buffer8 = table.freeze({
		Name = "Buffer8",
		Ser = function(buf2: buffer, offset: number, buf3: buffer)
			local v = buffer.len(buf3)

			if v > 255 then
				error("Buffer too long")
			end

			buffer.writeu8(buf2, offset, v)
			buffer.copy(buf2, offset + 1, buf3)
			return offset + 1 + v
		end,
		Des = function(buf2: buffer, offset: number)
			local v = buffer.readu8(buf2, offset)
			local buf3 = buffer.create(v)
			buffer.copy(buf3, 0, buf2, offset + 1, v)
			return buf3, offset + 1 + v
		end
	}),
	Buffer16 = table.freeze({
		Name = "Buffer16",
		Ser = function(buf2: buffer, offset: number, buf3: buffer)
			local v = buffer.len(buf3)

			if v > 65535 then
				error("Buffer too long")
			end

			buffer.writeu16(buf2, offset, v)
			buffer.copy(buf2, offset + 2, buf3)
			return offset + 2 + v
		end,
		Des = function(buf2: buffer, offset: number)
			local v = buffer.readu16(buf2, offset)
			local buf3 = buffer.create(v)
			buffer.copy(buf3, 0, buf2, offset + 2, v)
			return buf3, offset + 2 + v
		end
	}),
	Buffer32 = table.freeze({
		Name = "Buffer32",
		Ser = function(buf2: buffer, offset: number, buf3: buffer)
			local v = buffer.len(buf3)

			if v > 4294967295 then
				error("Buffer too long")
			end

			buffer.writeu32(buf2, offset, v)
			buffer.copy(buf2, offset + 4, buf3)
			return offset + 4 + v
		end,
		Des = function(buf2: buffer, offset: number)
			local v = buffer.readu32(buf2, offset)
			local buf3 = buffer.create(v)
			buffer.copy(buf3, 0, buf2, offset + 4, v)
			return buf3, offset + 4 + v
		end
	})
}

local function DegEncode(p: number)
	return (math.round(p % 6.283185307179586 * 255 / 6.265732014659643))
end

local v = {}

for i = 0, 255 do
	v[i] = i * 6.265732014659643 / 255
end

for i = 0, 315, 45 do
	local v2 = math.rad(i)
	v[math.round(v2 % 6.283185307179586 * 255 / 6.265732014659643)] = v2
end

Sera.Angle8 = table.freeze({
	Name = "Angle8",
	Ser = function(buf2: buffer, offset: number, p: number)
		buffer.writeu8(buf2, offset, (math.round(p % 6.283185307179586 * 255 / 6.265732014659643)))
		return offset + 1
	end,
	Des = function(buf2: buffer, offset: number)
		return v[buffer.readu8(buf2, offset)], offset + 1
	end
})

function Sera.Deserialize(p, buf2: buffer, value: number?)
	local v2 = value or 0
	local result = {}

	for _, v3 in p.Numeric do
		local key = v3.Key
		local v4
		v4, v2 = v3.Des(buf2, v2)
		result[key] = v4
	end

	return result, v2
end

local function SerializeUnsafe(p, p2)
	local v2 = 0

	for _, v3 in p.Numeric do
		v2 = v3.Ser(buf, v2, p2[v3.Key])
	end

	return v2
end

function Sera.Serialize(p, p2)
	local success, result = pcall(SerializeUnsafe, p, p2)

	if success then
		local buf2 = buffer.create(result)
		buffer.copy(buf2, 0, buf, 0, result)
		return buf2
	else
		local result2 = 0

		for _, v2 in p.Numeric do
			local v3 = p2[v2.Key]

			if v3 == nil then
				return nil, (`Missing field "{v2.Key}"`)
			end

			local success2
			success2, result2 = pcall(v2.Ser, buf, result2, v3)

			if not success2 then
				return
					nil,
					(`Couldn't serialize field "{v2.Key}" (Expected: {v2.Name};Received: "{typeof(v3)}"); Message: {result2}`)
			end
		end

		return nil, "Unknown error"
	end
end

local function PushUnsafe(p, p2, buf2: buffer, p3: number)
	for _, v2 in p.Numeric do
		p3 = v2.Ser(buf2, p3, p2[v2.Key])
	end

	return p3
end

function Sera.Push(p, p2, buf2: buffer, value: number?)
	local result = value or 0
	local success, result2 = pcall(PushUnsafe, p, p2, buf2, result)

	if success then
		return result2
	end

	for _, v2 in p.Numeric do
		local v3 = p2[v2.Key]

		if v3 == nil then
			return nil, (`Missing field "{v2.Key}"`)
		end

		local success2
		success2, result = pcall(v2.Ser, buf2, result, v3)

		if not success2 then
			return
				nil,
				(`Couldn't serialize field "{v2.Key}" (Expected: {v2.Name};Received: "{typeof(v3)}"); Message: {result}`)
		end
	end

	return nil, "Unknown error"
end

function Sera.DeltaDeserialize(p, buf2: buffer, value: number?)
	local v2 = (value or 0) + 1
	local v3 = buffer.readu8(buf2, v2 - 1)
	local numeric = p.Numeric
	local result = {}

	for _ = 1, v3 do
		local v4 = numeric[buffer.readu8(buf2, v2)]
		local key = v4.Key
		local v5
		v5, v2 = v4.Des(buf2, v2 + 1)
		result[key] = v5
	end

	return result, v2
end

local function DeltaSerializeUnsafe(p, items)
	local string = p.String
	local count = 0
	local v2 = 1

	for k, _ in items do
		count += 1
		local v3 = string[k]
		buffer.writeu8(buf, v2, v3.Index)
		v2 = v3.Ser(buf, v2 + 1, items[v3.Key])
	end

	buffer.writeu8(buf, 0, count)
	return v2
end

function Sera.DeltaSerialize(p, items)
	local success, result = pcall(DeltaSerializeUnsafe, p, items)

	if success then
		local buf2 = buffer.create(result)
		buffer.copy(buf2, 0, buf, 0, result)
		return buf2
	else
		local string = p.String
		local result2 = 1

		for k, item in items do
			local v2 = string[k]

			if v2 == nil then
				return nil, (`Key "{k}" not specified in schema`)
			end

			buffer.writeu8(buf, result2, v2.Index)
			local success2
			success2, result2 = pcall(v2.Ser, buf, result2 + 1, item)

			if not success2 then
				return
					nil,
					(`Couldn't serialize field "{v2.Key}" (Expected: {v2.Name};Received: "{typeof(item)}"); Message: {result2}`)
			end
		end

		return nil, "Unknown error"
	end
end

local function DeltaPushUnsafe(p, items, buf2: buffer, offset: number)
	local v2 = offset + 1
	local string = p.String
	local count = 0

	for k, _ in items do
		count += 1
		local v3 = string[k]
		buffer.writeu8(buf2, v2, v3.Index)
		v2 = v3.Ser(buf2, v2 + 1, items[v3.Key])
	end

	buffer.writeu8(buf2, offset, count)
	return v2
end

function Sera.DeltaPush(p, items, buf2: buffer, value: number?)
	local success, result = pcall(DeltaPushUnsafe, p, items, buf2, value or 0)

	if success then
		return result
	end

	local string = p.String
	local result2 = 1

	for k, item in items do
		local v2 = string[k]

		if v2 == nil then
			return nil, (`Key "{k}" not specified in schema`)
		end

		buffer.writeu8(buf2, result2, v2.Index)
		local success2
		success2, result2 = pcall(v2.Ser, buf2, result2 + 1, item)

		if not success2 then
			return
				nil,
				(`Couldn't serialize field "{v2.Key}" (Expected: {v2.Name};Received: "{typeof(item)}"); Message: {result2}`)
		end
	end

	return nil, "Unknown error"
end

function Sera.Schema(items)
	local numeric = {}

	for k, item in items do
		if typeof(k) ~= "string" then
			error((`[{script.Name}]: Expected string for field name; Received "{typeof(k)}"`))
		end

		if typeof(item) ~= "table" or typeof(item.Ser) ~= "function" or typeof(item.Des) ~= "function" or typeof(item.Name) ~= "string" then
			error((`[{script.Name}]: Expected SeraType for field "{k}"`))
		end

		table.insert(numeric, {
			Key = k,
			Name = item.Name,
			Ser = item.Ser,
			Des = item.Des,
			Index = 0
		})
	end

	if #numeric == 0 then
		error((`[{script.Name}]: Schema must have fields`))
	end

	if #numeric > 255 then
		error((`[{script.Name}]: Schema exceeded {255} fields; Received {#numeric} fields`))
	end

	table.sort(numeric, function(a, b)
		return a.Key < b.Key
	end)
	local string = {}

	for k, v4 in numeric do
		v4.Index = k
		string[v4.Key] = v4
	end

	return table.freeze({
		Numeric = numeric,
		String = string
	})
end

return Sera