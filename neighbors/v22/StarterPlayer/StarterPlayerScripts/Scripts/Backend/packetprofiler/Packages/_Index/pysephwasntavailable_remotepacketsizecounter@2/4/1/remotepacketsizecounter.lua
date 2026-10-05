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

local function GetVLQSize(p: number, p2: number)
	return (math.max(math.ceil((math.log(p2 + p, 128))), p))
end

local GetDataByteSize

GetDataByteSize = function(buf, p)
	local typeName = typeof(buf)

	if v[typeName] then
		return v[typeName]
	end

	if typeName == "string" or typeName == "buffer" then
		local v3 = typeName == "string" and #buf or buffer.len(buf)
		return math.max(math.ceil((math.log(v3 + 1, 128))), 1) + v3
	end

	if typeName == "table" then
		if p[buf] then
			return 0
		end

		p[buf] = true
		local v3 = buf[1] ~= nil
		local v4 = 1
		local total = 0
		local total2 = 0

		for k, v5 in next, buf, nil do
			v4 += 1

			if not v3 then
				total2 += GetDataByteSize(k, p) + 1
			end

			total += GetDataByteSize(v5, p) + 1
		end

		if v3 then
			return math.max(math.ceil((math.log(v4 + 1, 128))), 1) + total
		end

		return math.max(math.ceil((math.log(v4 + 1, 128))), 1) + total2 + total
	elseif typeName == "CFrame" then
		local flag = false

		for k in next, v2, nil do
			if k ~= buf.Rotation then
				continue
			end

			flag = true
			break
		end

		if flag then
			return 13
		end

		return 19
	else
		if typeName ~= "NumberSequence" and typeName ~= "ColorSequence" then
			warn("[PacketSizeCounter]: Unsupported data type: " .. typeName)
			return 0
		end

		local total = 4

		for _, keypoint in next, buf.Keypoints, nil do
			total += GetDataByteSize(keypoint, p)
		end

		return total
	end
end

local Remotepacketsizecounter = {
	BaseRemoteOverhead = 9,
	RemoteFunctionOverhead = 2,
	ClientToServerOverhead = 5,
	TypeOverhead = 1,
	GetPacketSize = function(data)
		local total = 9

		if data.RemoteType == "RemoteFunction" then
			total += 2
		end

		if data.RunContext == "Client" then
			total += 5
		end

		local v3 = {}

		for _, v4 in ipairs(data.PacketData) do
			total += GetDataByteSize(v4, v3) + 1
		end

		return total
	end,
	GetDataByteSize = function(p)
		return GetDataByteSize(p, {}) + 1
	end
}
table.freeze(Remotepacketsizecounter)
return Remotepacketsizecounter