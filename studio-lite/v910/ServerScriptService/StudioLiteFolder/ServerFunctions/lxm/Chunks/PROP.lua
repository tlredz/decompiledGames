require(script.Parent.Parent.Types)
local BasicTypes = require(script.Parent.Parent.BasicTypes)
local v = {
	Enum.NormalId.Right,
	Enum.NormalId.Top,
	Enum.NormalId.Back,
	Enum.NormalId.Left,
	Enum.NormalId.Bottom,
	Enum.NormalId.Front
}
local v2 = { Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z }

-- equivalent calls inferred from this helper; original call sites unknown
local function GetEnumValFromNumber(object, p: number)
	local enumItems = object:GetEnumItems()

	for _, enumItem in enumItems do
		if enumItem.Value == p then
			return enumItem
		end
	end

	return enumItems[1]
end

local function parseBitFlag(p: number, p2)
	local v3 = {}

	for i = 0, 7 do
		if bit32.extract(p, i) ~= 0 then
			table.insert(v3, p2[i + 1])
		end
	end

	return unpack(v3)
end

local function PROP(p, data)
	local data2 = p.Data
	local number = data2:readNumber("<I4")
	local classRef = data.ClassRefs[number]
	local refs = classRef.Refs
	local sizeof = classRef.Sizeof
	local string2 = BasicTypes.String(data2)
	local v3 = string.byte(data2:read(1, false)) == 30

	if v3 then
		data2:seek(1)
	end

	local v4 = string.byte(data2:read())
	local v5 = {}

	if v4 == 1 then
		for i = 1, sizeof do
			v5[i] = BasicTypes.String(data2)
		end
	elseif v4 == 2 then
		for i = 1, sizeof do
			v5[i] = data2:read() ~= "\0"
		end
	elseif v4 == 3 then
		v5 = BasicTypes.Int32Array(data2, sizeof)
	elseif v4 == 4 then
		v5 = BasicTypes.RbxF32Array(data2, sizeof)
	elseif v4 == 5 then
		for i = 1, sizeof do
			v5[i] = BasicTypes.Float64(data2)
		end
	elseif v4 == 6 then
		local rbxF32Array = BasicTypes.RbxF32Array(data2, sizeof)
		local int32Array = BasicTypes.Int32Array(data2, sizeof)

		for i = 1, sizeof do
			v5[i] = UDim.new(rbxF32Array[i], int32Array[i])
		end
	elseif v4 == 7 then
		local rbxF32Array = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array2 = BasicTypes.RbxF32Array(data2, sizeof)
		local int32Array = BasicTypes.Int32Array(data2, sizeof)
		local int32Array2 = BasicTypes.Int32Array(data2, sizeof)

		for i = 1, sizeof do
			v5[i] = UDim2.new(rbxF32Array[i], int32Array[i], rbxF32Array2[i], int32Array2[i])
		end
	elseif v4 == 8 then
		for i = 1, sizeof do
			v5[i] = Ray.new(
				Vector3.new(data2:readNumber("<f"), data2:readNumber("<f"), data2:readNumber("<f")),
				(Vector3.new(data2:readNumber("<f"), data2:readNumber("<f"), data2:readNumber("<f")))
			)
		end
	elseif v4 == 9 then
		for i = 1, sizeof do
			local v6 = string.byte(data2:read())
			v5[i] = Faces.new(parseBitFlag(v6, v))
		end
	elseif v4 == 10 then
		for i = 1, sizeof do
			local v6 = string.byte(data2:read())
			v5[i] = Axes.new(parseBitFlag(v6, v2))
		end
	elseif v4 == 11 then
		local unsignedIntArray = BasicTypes.unsignedIntArray(data2, sizeof)

		for i = 1, sizeof do
			v5[i] = BrickColor.new(unsignedIntArray[i])
		end
	elseif v4 == 12 then
		local rbxF32Array = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array2 = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array3 = BasicTypes.RbxF32Array(data2, sizeof)

		for i = 1, sizeof do
			v5[i] = Color3.new(rbxF32Array[i], rbxF32Array2[i], rbxF32Array3[i])
		end
	elseif v4 == 13 then
		local rbxF32Array = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array2 = BasicTypes.RbxF32Array(data2, sizeof)

		for i = 1, sizeof do
			v5[i] = Vector2.new(rbxF32Array[i], rbxF32Array2[i])
		end
	elseif v4 == 14 then
		local rbxF32Array = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array2 = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array3 = BasicTypes.RbxF32Array(data2, sizeof)

		for i = 1, sizeof do
			v5[i] = Vector3.new(rbxF32Array[i], rbxF32Array2[i], rbxF32Array3[i])
		end
	elseif v4 == 16 then
		local v6 = table.create(sizeof)

		for i = 1, sizeof do
			local v7 = string.byte(data2:read())

			if v7 > 0 then
				local v8 = v7 - 1
				local vector = Vector3.fromNormalId(v8 / 6)
				local vector2 = Vector3.fromNormalId(v8 % 6)
				v6[i] = { vector, vector2, (vector:Cross(vector2)) }
			else
				local number2 = data2:readNumber("<f")
				local number3 = data2:readNumber("<f")
				local number4 = data2:readNumber("<f")
				local number5 = data2:readNumber("<f")
				local number6 = data2:readNumber("<f")
				local number7 = data2:readNumber("<f")
				local number8 = data2:readNumber("<f")
				local number9 = data2:readNumber("<f")
				local number10 = data2:readNumber("<f")
				v6[i] = {
					Vector3.new(number2, number5, number8),
					Vector3.new(number3, number6, number9),
					(Vector3.new(number4, number7, number10))
				}
			end
		end

		local rbxF32Array = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array2 = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array3 = BasicTypes.RbxF32Array(data2, sizeof)

		for i = 1, sizeof do
			local v7 = v6[i]
			local vector = Vector3.new(rbxF32Array[i], rbxF32Array2[i], rbxF32Array3[i])
			v5[i] = CFrame.fromMatrix(vector, v7[1], v7[2], v7[3])
		end
	elseif v4 == 17 then
		local v6 = {}

		for i = 1, sizeof do
			v6[i] = {
				x = data2:readNumber("<f"),
				y = data2:readNumber("<f"),
				z = data2:readNumber("<f"),
				w = data2:readNumber("<f")
			}
		end

		local rbxF32Array = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array2 = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array3 = BasicTypes.RbxF32Array(data2, sizeof)

		for i = 1, sizeof do
			local v7 = v6[i]
			v5[i] = CFrame.new(rbxF32Array[i], rbxF32Array2[i], rbxF32Array3[i], v7.x, v7.y, v7.z, v7.w)
		end
	elseif v4 == 18 then
		v5 = BasicTypes.unsignedIntArray(data2, sizeof)
	elseif v4 == 19 then
		v5 = BasicTypes.RefArray(data2, sizeof)
	elseif v4 == 20 then
		for i = 1, sizeof do
			v5[i] = Vector3int16.new(data2:readNumber("<i2"), data2:readNumber("<i2"), data2:readNumber("<i2"))
		end
	elseif v4 == 21 then
		for i = 1, sizeof do
			local number2 = data2:readNumber("<I4")
			local numberSequenceKeypoints = table.create(number2)

			for _ = 1, number2 do
				table.insert(
					numberSequenceKeypoints,
					NumberSequenceKeypoint.new(data2:readNumber("<f"), data2:readNumber("<f"), data2:readNumber("<f"))
				)
			end

			v5[i] = NumberSequence.new(numberSequenceKeypoints)
		end
	elseif v4 == 22 then
		for i = 1, sizeof do
			local number2 = data2:readNumber("<I4")
			local colorSequenceKeypoints = table.create(number2)

			for _ = 1, number2 do
				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(
						data2:readNumber("<f"),
						Color3.new(data2:readNumber("<f"), data2:readNumber("<f"), data2:readNumber("<f"))
					)
				)
				data2:readNumber("<f")
			end

			v5[i] = ColorSequence.new(colorSequenceKeypoints)
		end
	elseif v4 == 23 then
		local _, _ = pcall(function()
			for i = 1, sizeof do
				v5[i] = NumberRange.new(data2:readNumber("<f"), data2:readNumber("<f"))
			end
		end)
	elseif v4 == 24 then
		local rbxF32Array = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array2 = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array3 = BasicTypes.RbxF32Array(data2, sizeof)
		local rbxF32Array4 = BasicTypes.RbxF32Array(data2, sizeof)

		for i = 1, sizeof do
			v5[i] = Rect.new(
				Vector2.new(rbxF32Array[i], rbxF32Array2[i]),
				Vector2.new(rbxF32Array3[i], rbxF32Array4[i])
			)
		end
	elseif v4 == 25 then
		for i = 1, sizeof do
			local v6 = data2:read()

			if v6 == "\1" then
				v5[i] = PhysicalProperties.new(
					math.clamp(data2:readNumber("<f"), 0.0001, 100),
					math.clamp(data2:readNumber("<f"), 0, 2),
					math.clamp(data2:readNumber("<f"), 0, 1),
					math.clamp(data2:readNumber("<f"), 0, 100),
					(math.clamp(data2:readNumber("<f"), 0, 100))
				)
			elseif v6 == "\3" then
				v5[i] = PhysicalProperties.new(
					math.clamp(data2:readNumber("<f"), 0.0001, 100),
					math.clamp(data2:readNumber("<f"), 0, 2),
					math.clamp(data2:readNumber("<f"), 0, 1),
					math.clamp(data2:readNumber("<f"), 0, 100),
					math.clamp(data2:readNumber("<f"), 0, 100),
					(math.clamp(data2:readNumber("<f"), 0, 1))
				)
			end
		end
	elseif v4 == 26 then
		local v6 = string.split(data2:read(sizeof), "")
		local v7 = string.split(data2:read(sizeof), "")
		local v8 = string.split(data2:read(sizeof), "")

		for i = 1, sizeof do
			v5[i] = Color3.fromRGB(string.byte(v6[i]), string.byte(v7[i]), string.byte(v8[i]))
		end
	elseif v4 == 27 then
		v5 = BasicTypes.Int64Array(data2, sizeof)
	elseif v4 == 28 then
		local unsignedIntArray = BasicTypes.unsignedIntArray(data2, sizeof)

		for i = 1, sizeof do
			local v6 = unsignedIntArray[i] + 1
			v5[i] = data.Strings[v6]
		end
	elseif v4 == 29 then
		for i = 1, sizeof do
			v5[i] = buffer.fromstring(BasicTypes.String(data2))
		end
	elseif v4 == 32 then
		for i = 1, sizeof do
			local string3 = BasicTypes.String(data2)
			local enumValFromNumber = GetEnumValFromNumber(Enum.FontWeight, data2:readNumber("<I2")) -- equivalent call inferred; original call site unknown
			local enumValFromNumber2 = GetEnumValFromNumber(Enum.FontStyle, string.byte(data2:read())) -- equivalent call inferred; original call site unknown
			BasicTypes.String(data2)
			v5[i] = Font.new(string3, enumValFromNumber, enumValFromNumber2)
		end
	end

	if v3 then
		data2:read()

		for i = 1, sizeof do
			if data2:read() == "\0" then
				v5[i] = nil
			end
		end
	end

	for k, ref in refs do
		data.InstanceRefs[ref].Properties[string2] = v5[k]
	end
end

return PROP