local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")
game:GetService("RunService")
local IgnoreProperties = require(script:WaitForChild("IgnoreProperties"))
local BrickColors = require(script:WaitForChild("BrickColors"))
local Instances = require(script:WaitForChild("Instances"))
local Enums = require(script:WaitForChild("Enums"))
local v = {}
local buf = buffer.create(6000000)
local buf2 = buffer.create(8)
local buf3 = buffer.create(16)
local buf4 = buffer.create(24)
local buf5 = buffer.create(48)
local _ = {
	Nil = 0,
	Instance = 1,
	Color3 = 2,
	CFrame = 3,
	ColorSequence = 4,
	DateTime = 5,
	Font = 6,
	NumberRange = 7,
	NumberSequence = 8,
	PhysicalProperties = 9,
	Rect = 10,
	Ray = 11,
	UDim = 12,
	UDim2 = 13,
	BrickColor = 14,
	Vector2 = 15,
	Vector3 = 16,
	EnumItem = 17,
	Number = 18,
	Boolean = 19,
	String2 = 20,
	String4 = 21,
	String8 = 22,
	String16 = 23,
	String24 = 24,
	String32 = 25,
	Color3Overflow = 26
}
local v2 = {
	[20] = 2,
	[21] = 4,
	[22] = 8,
	[23] = 16,
	[24] = 24,
	[25] = 32
}
local v3 = {}
local v4 = {}
local IGNORE_PROPERTIES_GENERAL = IgnoreProperties.IGNORE_PROPERTIES_GENERAL
local IGNORE_PROPERTIES_OF_CLASS = IgnoreProperties.IGNORE_PROPERTIES_OF_CLASS
local v5 = {}
local buf6 = buffer.create(6000000)
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}

local function stepElapsedTime(_) end

local function serialiseProperty(cframe)
	local typeName = typeof(cframe)

	if typeName == "Instance" then
		return "Instance"
	elseif typeName == "BrickColor" then
		return cframe.Name
	end

	if typeName == "CFrame" then
		local components, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20 = cframe:GetComponents()
		local v21 = buf5
		buffer.writef32(v21, 0, components)
		buffer.writef32(v21, 4, v10)
		buffer.writef32(v21, 8, v11)
		buffer.writef32(v21, 12, v12)
		buffer.writef32(v21, 16, v13)
		buffer.writef32(v21, 20, v14)
		buffer.writef32(v21, 24, v15)
		buffer.writef32(v21, 28, v16)
		buffer.writef32(v21, 32, v17)
		buffer.writef32(v21, 36, v18)
		buffer.writef32(v21, 40, v19)
		buffer.writef32(v21, 44, v20)
		return buffer.tostring(v21)
	else
		if typeName == "Color3" then
			return (`{cframe.R * 255 // 1}{cframe.G * 255 // 1}{cframe.B * 255 // 1}`)
		elseif typeName == "ColorSequence" then
			return (tostring(cframe))
		elseif typeName == "DateTime" then
			return cframe.UnixTimestamp
		elseif typeName == "Font" then
			return "Font"
		end

		if typeName == "NumberRange" then
			local v10 = buf2
			buffer.writef32(v10, 0, cframe.Min)
			buffer.writef32(v10, 4, cframe.Max)
			return buffer.tostring(v10)
		else
			if typeName == "NumberSequence" then
				return (tostring(cframe))
			elseif typeName == "PhysicalProperties" then
				return (tostring(cframe))
			end

			if typeName == "Ray" then
				local v10 = buf4
				buffer.writef32(v10, 0, cframe.Origin.X)
				buffer.writef32(v10, 4, cframe.Origin.Y)
				buffer.writef32(v10, 8, cframe.Origin.Y)
				buffer.writef32(v10, 12, cframe.Direction.X)
				buffer.writef32(v10, 16, cframe.Direction.Y)
				buffer.writef32(v10, 20, cframe.Direction.Y)
				return buffer.tostring(v10)
			elseif typeName == "Rect" then
				local v10 = buf4
				buffer.writef32(v10, 0, cframe.Min.X)
				buffer.writef32(v10, 4, cframe.Min.Y)
				buffer.writef32(v10, 8, cframe.Max.X)
				buffer.writef32(v10, 12, cframe.Max.Y)
				buffer.writef32(v10, 16, cframe.Width)
				buffer.writef32(v10, 20, cframe.Height)
				return buffer.tostring(v10)
			elseif typeName == "UDim" then
				local v10 = buf2
				buffer.writef32(v10, 0, cframe.Scale)
				buffer.writef32(v10, 4, cframe.Offset)
				return buffer.tostring(v10)
			elseif typeName == "UDim2" then
				local v10 = buf3
				buffer.writef32(v10, 0, cframe.X.Scale)
				buffer.writef32(v10, 4, cframe.X.Offset)
				buffer.writef32(v10, 8, cframe.Y.Scale)
				buffer.writef32(v10, 12, cframe.Y.Offset)
				return buffer.tostring(v10)
			else
				if typeName == "Vector2" then
					return cframe
				elseif typeName == "Vector3" then
					return cframe
				elseif typeName == "EnumItem" then
					return Enums[cframe]
				elseif typeName == "number" then
					return cframe
				elseif typeName == "boolean" then
					return cframe
				elseif typeName == "string" then
					return cframe
				elseif typeName == "nil" then
					return "nil"
				end

				error((`[xisd] Unsupported input type "{typeName}"`))
			end
		end
	end
end

local function writeFloat32ToBuffer(buf7: buffer, bitOffset: number, p: number)
	local v10

	if p < 0 then
		p = -p
		v10 = 1
	else
		v10 = 0
	end

	local v11, v12

	if p == 0 then
		v11 = 0
		v12 = 0
	elseif p == 1e999 then
		v11 = 255
		v12 = 0
	else
		local v13 = math.log(p, 2) // 1
		v11 = v13 + 127
		v12 = (p / 2 ^ v13 - 1) * 8388608 // 1
	end

	buffer.writebits(buf7, bitOffset, 32, (bit32.bor(bit32.lshift(v10, 31), bit32.lshift(v11, 23), v12)))
	return bitOffset + 32
end

local function readFloat32FromBuffer(buf7: buffer, bitOffset: number)
	local v10 = buffer.readbits(buf7, bitOffset, 32)
	local v11 = bitOffset + 32
	local v12 = bit32.band(bit32.rshift(v10, 31), 1)
	local v13 = bit32.band(bit32.rshift(v10, 23), 255)
	local v14 = bit32.band(v10, 8388607)

	if v13 == 0 then
		if v14 ~= 0 then
			return v11, (v12 == 1 and -1 or 1) * (v14 / 8388608) * 1.1754943508222875e-38
		end

		if v12 == 1 then
			return v11, -0
		end

		return v11, 0
	else
		if v13 ~= 255 then
			local v15 = v14 / 8388608 + 1
			return v11, (v12 == 1 and -1 or 1) * v15 * 2 ^ (v13 - 127)
		end

		if v14 ~= 0 then
			return v11, (0 / 0)
		end

		if v12 == 1 then
			return v11, -1e999
		end

		return v11, 1e999
	end
end

local function writeToBuffer(buf7: buffer, bitOffset: number, cframe, flag: boolean?, ...)
	local typeName = typeof(cframe)

	if typeName == "string" then
		local count = #cframe
		local v10 = ... or 16

		if flag then
			local v11 = nil

			if count <= 3 then
				v11 = 20
			elseif count <= 15 then
				v11 = 21
			elseif count <= 255 then
				v11 = 22
			elseif count <= 65535 then
				v11 = 23
			elseif count <= 16777215 then
				v11 = 24
			elseif count <= 4294967295 then
				v11 = 25
			else
				error((`[xisd] String too long ({count})`))
			end

			v10 = v2[v11]
			buffer.writebits(buf7, bitOffset, 5, v11)
			bitOffset += 5
		end

		buffer.writebits(buf7, bitOffset, v10, #cframe)
		local v11 = bitOffset + v10
		local v12 = 2 ^ v10 - 1

		for k, v13 in string.split(cframe, "") do
			if v12 < k then
				warn("[xisd] String content exceeds maximum length, and has been trimmed.")
				return v11
			else
				buffer.writebits(buf7, v11, 8, v3[v13])
				v11 += 8
			end
		end

		return v11
	elseif typeName == "Instance" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 1)
			bitOffset += 5
		end

		local v10, v11 = ...
		buffer.writebits(buf7, bitOffset, v11, v10[cframe] or 0)
		return bitOffset + v11
	elseif typeName == "boolean" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 19)
			bitOffset += 5
		end

		buffer.writebits(buf7, bitOffset, 1, cframe and 1 or 0)
		return bitOffset + 1
	elseif typeName == "BrickColor" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 14)
			bitOffset += 5
		end

		buffer.writebits(buf7, bitOffset, 8, BrickColors.BrickColorToId[cframe.Name])
		return bitOffset + 8
	elseif typeName == "CFrame" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 3)
			bitOffset += 5
		end

		local components, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20 = cframe:GetComponents()
		return (writeFloat32ToBuffer(
			buf7,
			writeFloat32ToBuffer(
				buf7,
				writeFloat32ToBuffer(
					buf7,
					writeFloat32ToBuffer(
						buf7,
						writeFloat32ToBuffer(
							buf7,
							writeFloat32ToBuffer(
								buf7,
								writeFloat32ToBuffer(
									buf7,
									writeFloat32ToBuffer(
										buf7,
										writeFloat32ToBuffer(
											buf7,
											writeFloat32ToBuffer(
												buf7,
												writeFloat32ToBuffer(
													buf7,
													writeFloat32ToBuffer(buf7, bitOffset, components),
													v10
												),
												v11
											),
											v12
										),
										v13
									),
									v14
								),
								v15
							),
							v16
						),
						v17
					),
					v18
				),
				v19
			),
			v20
		))
	elseif typeName == "Color3" then
		if cframe.R > 1 or cframe.G > 1 or cframe.B then
			if flag then
				buffer.writebits(buf7, bitOffset, 5, 26)
				bitOffset += 5
			end

			buffer.writebits(buf7, bitOffset, 32, cframe.R * 255 // 1)
			local v10 = bitOffset + 32
			buffer.writebits(buf7, v10, 32, cframe.G * 255 // 1)
			local v11 = v10 + 32
			buffer.writebits(buf7, v11, 32, cframe.B * 255 // 1)
			return v11 + 32
		else
			if flag then
				buffer.writebits(buf7, bitOffset, 5, 2)
				bitOffset += 5
			end

			buffer.writebits(buf7, bitOffset, 8, cframe.R * 255 // 1)
			local v10 = bitOffset + 8
			buffer.writebits(buf7, v10, 8, cframe.G * 255 // 1)
			local v11 = v10 + 8
			buffer.writebits(buf7, v11, 8, cframe.B * 255 // 1)
			return v11 + 8
		end
	elseif typeName == "ColorSequence" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 4)
			bitOffset += 5
		end

		local keypoints = cframe.Keypoints
		buffer.writebits(buf7, bitOffset, 8, #keypoints)
		local v10 = bitOffset + 8

		for _, keypoint in keypoints do
			local v11 = writeFloat32ToBuffer(buf7, v10, keypoint.Time)
			buffer.writebits(buf7, v11, 8, keypoint.Value.R * 255 // 1)
			local v12 = v11 + 8
			buffer.writebits(buf7, v12, 8, keypoint.Value.G * 255 // 1)
			local v13 = v12 + 8
			buffer.writebits(buf7, v13, 8, keypoint.Value.B * 255 // 1)
			v10 = v13 + 8
		end

		return v10
	elseif typeName == "Font" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 6)
			bitOffset += 5
		end

		local family = cframe.Family
		local style = cframe.Style
		local weight = cframe.Weight
		buffer.writebits(buf7, bitOffset, 16, #family)
		local v10 = bitOffset + 16

		for _, v11 in string.split(family, "") do
			buffer.writebits(buf7, v10, 8, v3[v11])
			v10 += 8
		end

		buffer.writebits(buf7, v10, 12, Enums[style])
		local v11 = v10 + 12
		buffer.writebits(buf7, v11, 12, Enums[weight])
		return v11 + 12
	elseif typeName == "NumberRange" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 7)
			bitOffset += 5
		end

		return (writeFloat32ToBuffer(buf7, writeFloat32ToBuffer(buf7, bitOffset, cframe.Min), cframe.Max))
	elseif typeName == "NumberSequence" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 8)
			bitOffset += 5
		end

		local keypoints = cframe.Keypoints
		buffer.writebits(buf7, bitOffset, 8, #keypoints)
		local v10 = bitOffset + 8

		for _, keypoint in keypoints do
			v10 = writeFloat32ToBuffer(
				buf7,
				writeFloat32ToBuffer(buf7, writeFloat32ToBuffer(buf7, v10, keypoint.Value), keypoint.Time),
				keypoint.Envelope
			)
		end

		return v10
	elseif typeName == "PhysicalProperties" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 9)
			bitOffset += 5
		end

		return (writeFloat32ToBuffer(
			buf7,
			writeFloat32ToBuffer(
				buf7,
				writeFloat32ToBuffer(
					buf7,
					writeFloat32ToBuffer(buf7, writeFloat32ToBuffer(buf7, bitOffset, cframe.Density), cframe.Friction),
					cframe.Elasticity
				),
				cframe.FrictionWeight
			),
			cframe.ElasticityWeight
		))
	elseif typeName == "Ray" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 11)
			bitOffset += 5
		end

		return (writeFloat32ToBuffer(
			buf7,
			writeFloat32ToBuffer(
				buf7,
				writeFloat32ToBuffer(
					buf7,
					writeFloat32ToBuffer(
						buf7,
						writeFloat32ToBuffer(
							buf7,
							writeFloat32ToBuffer(buf7, bitOffset, cframe.Origin.X),
							cframe.Origin.Y
						),
						cframe.Origin.Z
					),
					cframe.Direction.X
				),
				cframe.Direction.Y
			),
			cframe.Direction.Z
		))
	elseif typeName == "Rect" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 10)
			bitOffset += 5
		end

		return (writeFloat32ToBuffer(
			buf7,
			writeFloat32ToBuffer(
				buf7,
				writeFloat32ToBuffer(buf7, writeFloat32ToBuffer(buf7, bitOffset, cframe.Min.X), cframe.Min.Y),
				cframe.Max.X
			),
			cframe.Max.Y
		))
	elseif typeName == "UDim" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 12)
			bitOffset += 5
		end

		local v10 = writeFloat32ToBuffer(buf7, bitOffset, cframe.Scale)
		buffer.writebits(buf7, v10, 32, cframe.Offset)
		return v10 + 32
	elseif typeName == "UDim2" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 13)
			bitOffset += 5
		end

		local v10 = writeFloat32ToBuffer(buf7, bitOffset, cframe.X.Scale)
		buffer.writebits(buf7, v10, 32, cframe.X.Offset)
		local v12 = writeFloat32ToBuffer(buf7, v10 + 32, cframe.Y.Scale)
		buffer.writebits(buf7, v12, 32, cframe.Y.Offset)
		return v12 + 32
	elseif typeName == "Vector2" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 15)
			bitOffset += 5
		end

		return (writeFloat32ToBuffer(buf7, writeFloat32ToBuffer(buf7, bitOffset, cframe.X), cframe.Y))
	elseif typeName == "Vector3" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 16)
			bitOffset += 5
		end

		return (writeFloat32ToBuffer(
			buf7,
			writeFloat32ToBuffer(buf7, writeFloat32ToBuffer(buf7, bitOffset, cframe.X), cframe.Y),
			cframe.Z
		))
	elseif typeName == "EnumItem" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 17)
			bitOffset += 5
		end

		buffer.writebits(buf7, bitOffset, 12, Enums[cframe])
		return bitOffset + 12
	elseif typeName == "number" then
		if flag then
			buffer.writebits(buf7, bitOffset, 5, 18)
			bitOffset += 5
		end

		return (writeFloat32ToBuffer(buf7, bitOffset, cframe))
	else
		if typeName ~= "nil" then
			error((`[xisd] Unsupported input type "{typeName}"`))
			return
		end

		if flag then
			buffer.writebits(buf7, bitOffset, 5, 0)
			bitOffset += 5
		end

		return bitOffset
	end
end

local function readFromBuffer(buf7: buffer, bitOffset: number, p, bitCount: number)
	if p == true then
		p = buffer.readbits(buf7, bitOffset, 5)
		bitOffset += 5
	end

	if p == 20 or p == 21 or p == 22 or p == 23 or p == 24 or p == 25 then
		local v10 = v2[p]
		local v11 = buffer.readbits(buf7, bitOffset, v10)
		local v12 = bitOffset + v10
		local v13 = table.create(v11)

		for i = 1, v11 do
			v13[i] = v4[buffer.readbits(buf7, v12, 8)]
			v12 += 8
		end

		return v12, table.concat(v13), p
	else
		if p == 1 then
			local v10 = buffer.readbits(buf7, bitOffset, bitCount)
			return bitOffset + bitCount, v10, 1
		elseif p == 19 then
			return bitOffset + 1, buffer.readbits(buf7, bitOffset, 1) == 1, 19
		elseif p == 14 then
			local v10 = buffer.readbits(buf7, bitOffset, 8)
			return bitOffset + 8, BrickColors.IdToBrickColor[v10], 14
		end

		if p == 3 then
			local v10, v11 = readFloat32FromBuffer(buf7, bitOffset)
			local v12, v13 = readFloat32FromBuffer(buf7, v10)
			local v14, v15 = readFloat32FromBuffer(buf7, v12)
			local v16, v17 = readFloat32FromBuffer(buf7, v14)
			local v18, v19 = readFloat32FromBuffer(buf7, v16)
			local v20, v21 = readFloat32FromBuffer(buf7, v18)
			local v22, v23 = readFloat32FromBuffer(buf7, v20)
			local v24, v25 = readFloat32FromBuffer(buf7, v22)
			local v26, v27 = readFloat32FromBuffer(buf7, v24)
			local v28, v29 = readFloat32FromBuffer(buf7, v26)
			local v30, v31 = readFloat32FromBuffer(buf7, v28)
			local v32, v33 = readFloat32FromBuffer(buf7, v30)
			return v32, CFrame.new(v11, v13, v15, v17, v19, v21, v23, v25, v27, v29, v31, v33), 3
		elseif p == 2 then
			local v10 = buffer.readbits(buf7, bitOffset, 8)
			local v11 = bitOffset + 8
			local v12 = buffer.readbits(buf7, v11, 8)
			local v13 = v11 + 8
			local v14 = buffer.readbits(buf7, v13, 8)
			return v13 + 8, Color3.fromRGB(v10, v12, v14), 2
		elseif p == 26 then
			local v10 = buffer.readbits(buf7, bitOffset, 32)
			local v11 = bitOffset + 32
			local v12 = buffer.readbits(buf7, v11, 32)
			local v13 = v11 + 32
			local v14 = buffer.readbits(buf7, v13, 32)
			return v13 + 32, Color3.fromRGB(v10, v12, v14), 26
		elseif p == 4 then
			local v10 = buffer.readbits(buf7, bitOffset, 8)
			local v11 = bitOffset + 8
			local colorSequenceKeypoints = table.create(v10)

			for i = 1, v10 do
				local v12, v13 = readFloat32FromBuffer(buf7, v11)
				local v14 = buffer.readbits(buf7, v12, 8)
				local v15 = v12 + 8
				local v16 = buffer.readbits(buf7, v15, 8)
				local v17 = v15 + 8
				local v18 = buffer.readbits(buf7, v17, 8)
				v11 = v17 + 8
				colorSequenceKeypoints[i] = ColorSequenceKeypoint.new(v13, Color3.fromRGB(v14, v16, v18))
			end

			return v11, ColorSequence.new(colorSequenceKeypoints), 4
		elseif p == 6 then
			local v10 = buffer.readbits(buf7, bitOffset, 16)
			local v11 = bitOffset + 16
			local v12 = table.create(v10)

			for i = 1, v10 do
				v12[i] = v4[buffer.readbits(buf7, v11, 8)]
				v11 += 8
			end

			local v13 = buffer.readbits(buf7, v11, 12)
			local v14 = v11 + 12
			local v15 = buffer.readbits(buf7, v14, 12)
			local v16 = v14 + 12
			local joined = table.concat(v12)
			local v17 = v7[v13]
			local v18 = v7[v15]
			return v16, Font.new(joined, v18, v17), 6
		elseif p == 7 then
			local v10, v11 = readFloat32FromBuffer(buf7, bitOffset)
			local v12, v13 = readFloat32FromBuffer(buf7, v10)
			return v12, NumberRange.new(v11, v13), 7
		elseif p == 8 then
			local v10 = buffer.readbits(buf7, bitOffset, 8)
			local v11 = bitOffset + 8
			local numberSequenceKeypoints = table.create(v10)

			for i = 1, v10 do
				local v12, v13 = readFloat32FromBuffer(buf7, v11)
				local v14, v15 = readFloat32FromBuffer(buf7, v12)
				local v16
				v11, v16 = readFloat32FromBuffer(buf7, v14)
				numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(v15, v13, v16)
			end

			return v11, NumberSequence.new(numberSequenceKeypoints), 8
		elseif p == 9 then
			local v10, v11 = readFloat32FromBuffer(buf7, bitOffset)
			local v12, v13 = readFloat32FromBuffer(buf7, v10)
			local v14, v15 = readFloat32FromBuffer(buf7, v12)
			local v16, v17 = readFloat32FromBuffer(buf7, v14)
			local v18, v19 = readFloat32FromBuffer(buf7, v16)
			return v18, PhysicalProperties.new(v11, v13, v15, v17, v19), 9
		elseif p == 11 then
			local v10, v11 = readFloat32FromBuffer(buf7, bitOffset)
			local v12, v13 = readFloat32FromBuffer(buf7, v10)
			local v14, v15 = readFloat32FromBuffer(buf7, v12)
			local v16, v17 = readFloat32FromBuffer(buf7, v14)
			local v18, v19 = readFloat32FromBuffer(buf7, v16)
			local v20, v21 = readFloat32FromBuffer(buf7, v18)
			return v20, Ray.new(Vector3.new(v11, v13, v15), (Vector3.new(v17, v19, v21))), 11
		elseif p == 10 then
			local v10, v11 = readFloat32FromBuffer(buf7, bitOffset)
			local v12, v13 = readFloat32FromBuffer(buf7, v10)
			local v14, v15 = readFloat32FromBuffer(buf7, v12)
			local v16, v17 = readFloat32FromBuffer(buf7, v14)
			return v16, Rect.new(v11, v13, v15, v17), 10
		elseif p == 12 then
			local v10, v11 = readFloat32FromBuffer(buf7, bitOffset)
			local v12 = buffer.readbits(buf7, v10, 32)
			return v10 + 32, UDim.new(v11, v12), 12
		elseif p == 13 then
			local v10, v11 = readFloat32FromBuffer(buf7, bitOffset)
			local v12 = buffer.readbits(buf7, v10, 32)
			local v14, v15 = readFloat32FromBuffer(buf7, v10 + 32)
			local v16 = buffer.readbits(buf7, v14, 32)
			return v14 + 32, UDim2.new(v11, v12, v15, v16), 13
		elseif p == 15 then
			local v10, v11 = readFloat32FromBuffer(buf7, bitOffset)
			local v12, v13 = readFloat32FromBuffer(buf7, v10)
			return v12, Vector2.new(v11, v13), 15
		elseif p == 16 then
			local v10, v11 = readFloat32FromBuffer(buf7, bitOffset)
			local v12, v13 = readFloat32FromBuffer(buf7, v10)
			local v14, v15 = readFloat32FromBuffer(buf7, v12)
			return v14, Vector3.new(v11, v13, v15), 16
		else
			if p == 17 then
				local v10 = buffer.readbits(buf7, bitOffset, 12)
				return bitOffset + 12, v7[v10], 17
			elseif p == 18 then
				local v10, v11 = readFloat32FromBuffer(buf7, bitOffset)
				return v10, v11, 18
			elseif p == 0 then
				return bitOffset, nil, 0
			end

			error((`[xisd] Unsupported input type "{p}"`))
		end
	end
end

local serialiseInstanceToBuffer

serialiseInstanceToBuffer = function(buf7: buffer, bitOffset: number, instance, p, flag: boolean, bitCount: number)
	local className = instance.ClassName
	local v10 = v5[className]
	local instance2 = Instances[className]
	local v11 = IGNORE_PROPERTIES_OF_CLASS[className] or v
	local count = 0

	for k, v12 in instance2.P do
		if not (IGNORE_PROPERTIES_GENERAL[k] == nil and v11[k] == nil) then
			continue
		end

		local v13 = instance[k]

		if not (v10[k] ~= serialiseProperty(v13) and (k ~= "Parent" or not flag)) then
			continue
		end

		count += 1
		v8[v12] = v13
	end

	if instance:IsA("Model") then
		local scale = instance:GetScale()

		if scale ~= 1 then
			count += 1
			v8[instance2.P.Scale] = scale
		end
	end

	buffer.writebits(buf7, bitOffset, 9, instance2.I)
	local v12 = bitOffset + 9
	buffer.writebits(buf7, v12, bitCount, p[instance])
	local v13 = v12 + bitCount
	buffer.writebits(buf7, v13, instance2.W, count)
	local v14 = v13 + instance2.W

	for value, v15 in v8 do
		buffer.writebits(buf7, v14, instance2.W, value)
		v14 = writeToBuffer(buf7, v14 + instance2.W, v15, true, p, bitCount)
	end

	table.clear(v8)

	if instance:IsA("SurfaceAppearance") then
		buffer.writebits(buf7, v14, 16, v9[instance] or 0)
		v14 += 16
	end

	local attributes = instance:GetAttributes()
	local count2 = 0

	for k in attributes do
		if string.lower((string.sub(k, 1, 3))) == "rbx" then
			continue
		end

		count2 += 1
	end

	buffer.writebits(buf7, v14, 1, count2 > 0 and 1 or 0)
	local v15 = v14 + 1

	if count2 > 0 then
		buffer.writebits(buf7, v15, 8, count2)
		v15 += 8

		for k, attribute in attributes do
			if string.lower((string.sub(k, 1, 3))) == "rbx" then
				continue
			end

			v15 = writeToBuffer(buf7, writeToBuffer(buf7, v15, k, nil, 8), attribute, true)
		end
	end

	local tags = instance:GetTags()
	local count3 = #tags
	buffer.writebits(buf7, v15, 1, count3 > 0 and 1 or 0)
	local v16 = v15 + 1

	if count3 > 0 then
		buffer.writebits(buf7, v16, 8, count3)
		v16 += 8

		for _, tag in tags do
			v16 = writeToBuffer(buf7, v16, tag, nil, 8)
		end
	end

	local children = instance:GetChildren()
	local count4 = #children
	buffer.writebits(buf7, v16, 1, count4 > 0 and 1 or 0)
	local v17 = v16 + 1

	if count4 > 0 then
		buffer.writebits(buf7, v17, bitCount, #children)
		v17 += bitCount

		for _, v18 in children do
			v17 = serialiseInstanceToBuffer(buf7, v17, v18, p, false, bitCount)
		end
	end

	return v17
end

local deserialiseInstanceFromBuffer

deserialiseInstanceFromBuffer = function(buf7: buffer, bitOffset: number, clones, p, bitCount: number, p2)
	local v10 = buffer.readbits(buf7, bitOffset, 9)
	local v11 = bitOffset + 9
	local v12 = v6[v10]
	local v13 = buffer.readbits(buf7, v11, bitCount)
	local v14 = v11 + bitCount
	local v15 = buffer.readbits(buf7, v14, v12.W)
	local v16 = v14 + v12.W
	local v17 = table.create(v15)

	for _ = 1, v15 do
		local v18 = buffer.readbits(buf7, v16, v12.W)
		local v19 = v16 + v12.W
		local v20 = v12.P[v18]
		local v21, v22
		v16, v21, v22 = readFromBuffer(buf7, v19, true, bitCount)

		if v22 == 1 then
			local v23 = p[v13]

			if v23 == nil then
				p[v13] = {
					[v21] = { v20 }
				}
			else
				local v24 = v23[v21]

				if v24 == nil then
					v23[v21] = { v20 }
				else
					table.insert(v24, v20)
				end
			end
		else
			v17[v20] = v21
		end
	end

	local child

	if v12.N == "SurfaceAppearance" then
		local v18 = buffer.readbits(buf7, v16, 16)
		v16 += 16
		child = ReplicatedStorage.xisd_SurfaceAppearances:FindFirstChild(v18)
	end

	local v18 = buffer.readbits(buf7, v16, 1) == 1
	local v19 = v16 + 1
	local v20 = v

	if v18 then
		local v21 = buffer.readbits(buf7, v19, 8)
		v19 += 8
		v20 = table.create(v21)

		for _ = 1, v21 do
			local v22, v23 = readFromBuffer(buf7, v19, 22, bitCount)
			local v24
			v19, v24 = readFromBuffer(buf7, v22, true, bitCount)
			v20[v23] = v24
		end
	end

	local v21 = buffer.readbits(buf7, v19, 1) == 1
	local v22 = v19 + 1
	local v23 = v

	if v21 then
		local v24 = buffer.readbits(buf7, v22, 8)
		v22 += 8
		v23 = table.create(v24)

		for i = 1, v24 do
			local v25
			v22, v25 = readFromBuffer(buf7, v22, 22, bitCount)
			v23[i] = v25
		end
	end

	local v24 = buffer.readbits(buf7, v22, 1) == 1
	local v25 = v22 + 1

	if v24 then
		local v26 = buffer.readbits(buf7, v25, bitCount)
		v25 += bitCount

		for _ = 1, v26 do
			v25 = deserialiseInstanceFromBuffer(buf7, v25, clones, p, bitCount, p2)
		end
	end

	local clone

	if v12.N == "MeshPart" and v17.MeshId then
		local GUID = HttpService:GenerateGUID(false)
		clone = v17.DoubleSided and script.DoubleSidedHack:Clone() or Instance.new("MeshPart")
		clone.LocalTransparencyModifier = 1
		clone:AddTag(GUID)
		clone:AddTag("_MESH_LOADING_")
		local connection = CollectionService:GetInstanceAddedSignal(GUID):Connect(function(part)
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 1
			end
		end)
		task.spawn(function()
			local success = false
			local result = nil

			for _ = 1, 5 do
				success, result = pcall(
					InsertService.CreateMeshPartAsync,
					InsertService,
					v17.MeshId,
					v17.CollisionFidelity or Enum.CollisionFidelity.Default,
					v17.RenderFidelity or Enum.RenderFidelity.Automatic
				)

				if success then
					break
				end
			end

			if not success then
				warn((`[xisd] ERROR MeshId "{v17.MeshId}" (CollisionFidelity = {tostring(v17.CollisionFidelity or Enum.CollisionFidelity.Default)}, RenderFidelity = {tostring(v17.RenderFidelity or Enum.RenderFidelity.Automatic)}) could not be inserted because {clone}. Falling back to default (invisible) MeshPart`))
				return
			end

			local size = v17.Size
			local meshSize = v17.MeshSize
			local textureID = v17.TextureID or ""

			for _, v26 in CollectionService:GetTagged(GUID) do
				v26:ApplyMesh(result)

				if size then
					local meshSize2 = v26.MeshSize

					if math.abs(meshSize.X - meshSize2.X) > 1 or math.abs(meshSize.Y - meshSize2.Y) > 1 or math.abs(meshSize.Z - meshSize2.Z) > 1 then
						v26.Size = Vector3.new(
							meshSize.X > meshSize2.X and size.X / (meshSize.X / meshSize2.X) or size.X,
							meshSize.Y > meshSize2.Y and size.Y / (meshSize.Y / meshSize2.Y) or size.Y,
							meshSize.Z > meshSize2.Z and size.Z / (meshSize.Z / meshSize2.Z) or size.Z
						)
					else
						v26.Size = size
					end
				end

				if v26.TextureID ~= textureID then
					v26.TextureID = textureID
				end

				v26.LocalTransparencyModifier = 0
				v26:RemoveTag(GUID)
				v26:RemoveTag("_MESH_LOADING_")
			end

			connection:Disconnect()
			connection = nil
		end)
	elseif v12.N == "SurfaceAppearance" and child then
		clone = child:Clone()
		clone.Name = "SurfaceAppearance"
	else
		clone = Instance.new(v12.N)
	end

	local v26 = nil

	for k, scale in v17 do
		if not ((k ~= "MeshId" or v12.N ~= "MeshPart") and k ~= "CollisionFidelity" and k ~= "RenderFidelity" and k ~= "FluidFidelity") then
			continue
		end

		if not (k ~= "MeshSize" and k ~= "DoubleSided" and (k ~= "Size" or not v17.MeshSize)) then
			continue
		end

		if k == "Scale" then
			if type(scale) == "number" then
				v26 = scale
			else
				clone.Scale = scale
			end
		else
			clone[k] = scale
		end
	end

	if v26 then
		clone:ScaleTo(v26)
	end

	for k, v27 in v20 do
		clone:SetAttribute(k, v27)
	end

	for _, tag in v23 do
		clone:AddTag(tag)
	end

	clones[v13] = clone
	return v25
end

local v10 = 1
local Xisd = {}

for i = 0, 255 do
	local v11 = string.char(i)
	v3[v11] = i
	v4[i] = v11
end

for k, instance in Instances do
	local v11 = {
		N = k,
		W = instance.W,
		P = {}
	}

	for k2, v12 in instance.P do
		v11.P[v12] = k2
	end

	v6[instance.I] = v11
end

for k, enum in Enums do
	v7[enum] = k
end

for k, instance in Instances do
	if not (k ~= "Handles" and k ~= "ArcHandles") then
		continue
	end

	local success, result = pcall(Instance.new, k)

	if not (success and result) then
		continue
	end

	local v11 = {}

	for k2 in instance.P do
		local v12 = result
		local v13 = k2
		local success2, result2 = pcall(function()
			return v12[v13]
		end)

		if success2 and typeof(result2) ~= "Content" then
			v11[k2] = serialiseProperty(result2)
		end
	end

	v5[k] = v11
end

function Xisd.ser(folder)
	buffer.copy(buf6, 0, buf, 0)
	local v11 = {
		[folder] = 1
	}
	local v12 = 2

	for _, surfaceAppearance in folder:GetDescendants() do
		v11[surfaceAppearance] = v12
		v12 += 1

		if not (surfaceAppearance:IsA("SurfaceAppearance") and v9[surfaceAppearance] == nil) then
			continue
		end

		local v13 = v10
		v9[surfaceAppearance] = v13
		v10 += 1
		local clone = surfaceAppearance:Clone()
		clone.Name = tostring(v13)
		clone.Parent = ReplicatedStorage.xisd_SurfaceAppearances
	end

	local v13 = math.floor((math.log(v12, 2))) + 1
	local v14 = 0
	buffer.writebits(buf6, v14, 32, v13)
	local v16 = math.ceil(serialiseInstanceToBuffer(buf6, v14 + 32, folder, v11, true, v13) / 8)
	local buf7 = buffer.create(v16)
	buffer.copy(buf7, 0, buf6, 0, v16)
	return buffer.tostring(buf7)
end

function Xisd.de(str: string)
	local v11 = {
		Pauses = 0,
		MaxPauses = 32,
		MinTime = 0.004,
		MaxTime = 0.128,
		LastStep = os.clock()
	}
	local buffer2 = buffer.fromstring(str)
	local v12 = {}
	local v13 = {}
	local v14 = 0
	local v15 = buffer.readbits(buffer2, v14, 32)
	deserialiseInstanceFromBuffer(buffer2, v14 + 32, v12, v13, v15, v11)

	for k, v17 in v13 do
		local v18 = v12[k]

		for k2, v19 in v17 do
			local v20 = v12[k2]

			for _, v21 in v19 do
				v18[v21] = v20
			end
		end
	end

	return v12[1]
end

return Xisd