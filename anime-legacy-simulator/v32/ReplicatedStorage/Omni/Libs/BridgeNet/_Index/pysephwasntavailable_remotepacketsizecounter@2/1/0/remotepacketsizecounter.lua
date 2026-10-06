local v = {
	["nil"] = 0,
	EnumItem = 4,
	boolean = 1,
	number = 8,
	UDim = 8,
	UDim2 = 16,
	Ray = 24,
	Faces = 6,
	Axes = 6,
	BrickColor = 4,
	Color3 = 12,
	Vector2 = 8,
	Vector3 = 12,
	Instance = 4,
	Vector2int16 = 4,
	Vector3int16 = 6,
	NumberSequenceKeypoint = 12,
	ColorSequenceKeypoint = 16,
	NumberRange = 8,
	Rect = 16,
	PhysicalProperties = 20,
	Color3uint8 = 3
}
local v2 = {
	[CFrame.Angles(0, 0, 0)] = true,
	[CFrame.Angles(0, 3.141592653589793, 0)] = true,
	[CFrame.Angles(1.5707963267948966, 0, 0)] = true,
	[CFrame.Angles(-1.5707963267948966, -3.141592653589793, 0)] = true,
	[CFrame.Angles(0, 3.141592653589793, 3.141592653589793)] = true,
	[CFrame.Angles(0, 0, 3.141592653589793)] = true,
	[CFrame.Angles(-1.5707963267948966, 0, 0)] = true,
	[CFrame.Angles(1.5707963267948966, 3.141592653589793, 0)] = true,
	[CFrame.Angles(0, 3.141592653589793, 1.5707963267948966)] = true,
	[CFrame.Angles(0, 0, -1.5707963267948966)] = true,
	[CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966)] = true,
	[CFrame.Angles(0, -1.5707963267948966, -1.5707963267948966)] = true,
	[CFrame.Angles(0, 0, 1.5707963267948966)] = true,
	[CFrame.Angles(0, -3.141592653589793, -1.5707963267948966)] = true,
	[CFrame.Angles(0, -1.5707963267948966, 1.5707963267948966)] = true,
	[CFrame.Angles(0, 1.5707963267948966, -1.5707963267948966)] = true,
	[CFrame.Angles(-1.5707963267948966, -1.5707963267948966, 0)] = true,
	[CFrame.Angles(1.5707963267948966, 1.5707963267948966, 0)] = true,
	[CFrame.Angles(0, -1.5707963267948966, 0)] = true,
	[CFrame.Angles(0, 1.5707963267948966, 0)] = true,
	[CFrame.Angles(1.5707963267948966, -1.5707963267948966, 0)] = true,
	[CFrame.Angles(-1.5707963267948966, 1.5707963267948966, 0)] = true,
	[CFrame.Angles(0, 1.5707963267948966, 3.141592653589793)] = true,
	[CFrame.Angles(0, -1.5707963267948966, 3.141592653589793)] = true
}
local GetDataByteSize

GetDataByteSize = function(sequence, p)
	local typeName = typeof(sequence)

	if v[typeName] then
		return v[typeName]
	end

	if typeName == "string" then
		return #sequence + 2
	end

	if typeName == "table" then
		if p[sequence] then
			return 0
		end

		p[sequence] = true
		local v3 = 1
		local total = 0
		local total2 = 0
		local v4 = true

		for k, v5 in next, sequence, nil do
			if k == v3 then
				v3 += 1
			else
				v4 = false
			end

			total += GetDataByteSize(k, p) + 1
			total2 += GetDataByteSize(v5, p) + 1
		end

		return 1 + (v4 and #sequence + total2 or total + total2)
	elseif typeName == "CFrame" then
		local flag = false

		for k in next, v2, nil do
			if k ~= sequence.Rotation then
				continue
			end

			flag = true
			break
		end

		if flag then
			return 13
		end

		return 21
	else
		if typeName ~= "NumberSequence" and typeName ~= "ColorSequence" then
			warn("Unsupported data type: " .. typeName)
			return 0
		end

		local total = 4

		for _, keypoint in next, sequence.Keypoints, nil do
			total += GetDataByteSize(keypoint, p)
		end

		return total
	end
end

local Remotepacketsizecounter = {
	RemoteOverhead = 9,
	TypeOverhead = 1,
	GetPacketSize = function(p)
		local v3 = p.IgnoreRemoteOffset and 0 or 9
		local v4 = {}

		for _, v5 in ipairs(p.PacketData) do
			v3 += GetDataByteSize(v5, v4) + 1
		end

		return v3
	end,
	GetDataByteSize = function(p)
		return (GetDataByteSize(p, {}))
	end
}
table.freeze(Remotepacketsizecounter)
return Remotepacketsizecounter