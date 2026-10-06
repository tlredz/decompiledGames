local Serializer = {}
local SizeOf

SizeOf = function(p)
	local typeName = typeof(p)

	if not (p ~= nil and typeName ~= "boolean") then
		return 1
	end

	if typeName == "number" then
		if p % 1 == 0 and p >= -2147483648 and p <= 2147483647 then
			return 5
		end

		return 9
	else
		if typeName == "string" then
			return #p + 5
		elseif typeName == "Vector3" then
			return 13
		elseif typeName == "Vector2" then
			return 9
		elseif typeName == "CFrame" then
			return 49
		elseif typeName == "Color3" then
			return 13
		elseif typeName == "BrickColor" then
			return 5
		elseif typeName == "UDim2" then
			return 17
		elseif typeName == "UDim" then
			return 9
		elseif typeName == "NumberRange" then
			return 9
		elseif typeName == "DateTime" then
			return 9
		elseif typeName == "Rect" then
			return 17
		elseif typeName == "EnumItem" then
			return #tostring(p.EnumType) + 5 + #p.Name
		end

		if typeName ~= "table" then
			error((`Serializer: unsupported type "{typeName}"`))
			return
		end

		local total = 5

		for k, v in p do
			total += SizeOf(k) + SizeOf(v)
		end

		return total
	end
end

local WriteValue

WriteValue = function(buf: buffer, offset: number, cframe)
	local typeName = typeof(cframe)

	if cframe == nil then
		buffer.writeu8(buf, offset, 0)
		return offset + 1
	end

	if typeName == "boolean" then
		buffer.writeu8(buf, offset, cframe and 2 or 1)
		return offset + 1
	end

	if typeName == "number" then
		if cframe % 1 == 0 and cframe >= -2147483648 and cframe <= 2147483647 then
			buffer.writeu8(buf, offset, 4)
			buffer.writei32(buf, offset + 1, cframe)
			return offset + 5
		else
			buffer.writeu8(buf, offset, 3)
			buffer.writef64(buf, offset + 1, cframe)
			return offset + 9
		end
	elseif typeName == "string" then
		buffer.writeu8(buf, offset, 5)
		buffer.writeu32(buf, offset + 1, #cframe)
		buffer.writestring(buf, offset + 5, cframe)
		return offset + 5 + #cframe
	elseif typeName == "Vector3" then
		buffer.writeu8(buf, offset, 7)
		buffer.writef32(buf, offset + 1, cframe.X)
		buffer.writef32(buf, offset + 5, cframe.Y)
		buffer.writef32(buf, offset + 9, cframe.Z)
		return offset + 13
	elseif typeName == "Vector2" then
		buffer.writeu8(buf, offset, 8)
		buffer.writef32(buf, offset + 1, cframe.X)
		buffer.writef32(buf, offset + 5, cframe.Y)
		return offset + 9
	elseif typeName == "CFrame" then
		buffer.writeu8(buf, offset, 9)
		local v = { cframe:GetComponents() }

		for i = 1, 12 do
			buffer.writef32(buf, offset + 1 + (i - 1) * 4, v[i])
		end

		return offset + 49
	elseif typeName == "Color3" then
		buffer.writeu8(buf, offset, 10)
		buffer.writef32(buf, offset + 1, cframe.R)
		buffer.writef32(buf, offset + 5, cframe.G)
		buffer.writef32(buf, offset + 9, cframe.B)
		return offset + 13
	elseif typeName == "BrickColor" then
		buffer.writeu8(buf, offset, 11)
		buffer.writeu32(buf, offset + 1, cframe.Number)
		return offset + 5
	elseif typeName == "UDim2" then
		buffer.writeu8(buf, offset, 12)
		buffer.writef32(buf, offset + 1, cframe.X.Scale)
		buffer.writef32(buf, offset + 5, cframe.X.Offset)
		buffer.writef32(buf, offset + 9, cframe.Y.Scale)
		buffer.writef32(buf, offset + 13, cframe.Y.Offset)
		return offset + 17
	elseif typeName == "UDim" then
		buffer.writeu8(buf, offset, 13)
		buffer.writef32(buf, offset + 1, cframe.Scale)
		buffer.writef32(buf, offset + 5, cframe.Offset)
		return offset + 9
	elseif typeName == "NumberRange" then
		buffer.writeu8(buf, offset, 14)
		buffer.writef32(buf, offset + 1, cframe.Min)
		buffer.writef32(buf, offset + 5, cframe.Max)
		return offset + 9
	elseif typeName == "EnumItem" then
		local enumType = tostring(cframe.EnumType)
		buffer.writeu8(buf, offset, 15)
		buffer.writeu16(buf, offset + 1, #enumType)
		buffer.writestring(buf, offset + 3, enumType)
		local v = offset + (#enumType + 3)
		buffer.writeu16(buf, v, #cframe.Name)
		buffer.writestring(buf, v + 2, cframe.Name)
		return v + 2 + #cframe.Name
	elseif typeName == "DateTime" then
		buffer.writeu8(buf, offset, 16)
		buffer.writef64(buf, offset + 1, cframe.UnixTimestampMillis)
		return offset + 9
	elseif typeName == "Rect" then
		buffer.writeu8(buf, offset, 17)
		buffer.writef32(buf, offset + 1, cframe.Min.X)
		buffer.writef32(buf, offset + 5, cframe.Min.Y)
		buffer.writef32(buf, offset + 9, cframe.Max.X)
		buffer.writef32(buf, offset + 13, cframe.Max.Y)
		return offset + 17
	else
		if typeName ~= "table" then
			error((`Serializer: unsupported type "{typeName}"`))
			return
		end

		buffer.writeu8(buf, offset, 6)
		local count = 0

		for _ in cframe do
			count += 1
		end

		buffer.writeu32(buf, offset + 1, count)
		local v = offset + 5

		for k, v2 in cframe do
			v = WriteValue(buf, WriteValue(buf, v, k), v2)
		end

		return v
	end
end

local ReadValue

ReadValue = function(buf: buffer, offset: number)
	local v = buffer.readu8(buf, offset)
	local v2 = offset + 1

	if v == 0 then
		return nil, v2
	elseif v == 1 then
		return false, v2
	elseif v == 2 then
		return true, v2
	elseif v == 3 then
		return buffer.readf64(buf, v2), v2 + 8
	elseif v == 4 then
		return buffer.readi32(buf, v2), v2 + 4
	elseif v == 5 then
		local v3 = buffer.readu32(buf, v2)
		return buffer.readstring(buf, v2 + 4, v3), v2 + 4 + v3
	elseif v == 7 then
		return Vector3.new(buffer.readf32(buf, v2), buffer.readf32(buf, v2 + 4), (buffer.readf32(buf, v2 + 8))), v2 + 12
	elseif v == 8 then
		return Vector2.new(buffer.readf32(buf, v2), (buffer.readf32(buf, v2 + 4))), v2 + 8
	end

	if v == 9 then
		local v3 = table.create(12)

		for i = 1, 12 do
			v3[i] = buffer.readf32(buf, v2 + (i - 1) * 4)
		end

		return CFrame.new(unpack(v3)), v2 + 48
	else
		if v == 10 then
			return
				Color3.new(buffer.readf32(buf, v2), buffer.readf32(buf, v2 + 4), (buffer.readf32(buf, v2 + 8))),
				v2 + 12
		elseif v == 11 then
			return BrickColor.new((buffer.readu32(buf, v2))), v2 + 4
		elseif v == 12 then
			return
				UDim2.new(
					buffer.readf32(buf, v2),
					buffer.readf32(buf, v2 + 4),
					buffer.readf32(buf, v2 + 8),
					(buffer.readf32(buf, v2 + 12))
				),
				v2 + 16
		elseif v == 13 then
			return UDim.new(buffer.readf32(buf, v2), (buffer.readf32(buf, v2 + 4))), v2 + 8
		elseif v == 14 then
			return NumberRange.new(buffer.readf32(buf, v2), (buffer.readf32(buf, v2 + 4))), v2 + 8
		end

		if v == 15 then
			local v3 = buffer.readu16(buf, v2)
			local v4 = buffer.readstring(buf, v2 + 2, v3)
			local v5 = v2 + (v3 + 2)
			local v6 = buffer.readu16(buf, v5)
			local v7 = buffer.readstring(buf, v5 + 2, v6)
			return Enum[v4][v7], v5 + 2 + v6
		else
			if v == 16 then
				return DateTime.fromUnixTimestampMillis((buffer.readf64(buf, v2))), v2 + 8
			elseif v == 17 then
				return
					Rect.new(
						buffer.readf32(buf, v2),
						buffer.readf32(buf, v2 + 4),
						buffer.readf32(buf, v2 + 8),
						(buffer.readf32(buf, v2 + 12))
					),
					v2 + 16
			end

			if v ~= 6 then
				error((`Serializer: unknown tag {v}`))
				return
			end

			local v3 = buffer.readu32(buf, v2)
			local v4 = v2 + 4
			local result = {}

			for _ = 1, v3 do
				local v5, v6 = ReadValue(buf, v4)
				local v7
				v7, v4 = ReadValue(buf, v6)
				result[v5] = v7
			end

			return result, v4
		end
	end
end

function Serializer.Serialize(p)
	if typeof(p) == "buffer" then
		return p
	end

	local size = SizeOf(p)
	local buf = buffer.create(size)
	WriteValue(buf, 0, p)
	return buf
end

function Serializer.Deserialize(buf: buffer)
	if typeof(buf) == "buffer" then
		return ReadValue(buf, 0)
	end

	return buf
end

return Serializer