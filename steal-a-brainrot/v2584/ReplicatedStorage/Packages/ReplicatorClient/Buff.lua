local v = {}
local v2 = {
	Axes = 64,
	BrickColor = 65,
	CFrame = 66,
	Color3 = 67,
	ColorSequenceKeypoint = 68,
	ColorSequence = 69,
	DateTime = 70,
	Faces = 71,
	Font = 72,
	NumberRange = 73,
	NumberSequenceKeypoint = 74,
	NumberSequence = 75,
	PhysicalProperties = 76,
	Ray = 77,
	Rect = 78,
	Region3 = 79,
	Region3int16 = 80,
	TweenInfo = 81,
	UDim = 82,
	UDim2 = 83,
	Vector2 = 84,
	Vector2int16 = 85,
	Vector3 = 86,
	Vector3int16 = 87,
	PathWaypoint = 88,
	FloatCurveKey = 89,
	RotationCurveKey = 90,
	Path2DControlPoint = 91,
	Enum = 14,
	EnumItem = 15
}
local buf = buffer.create(256)
local v3 = 0
local v4 = 256

-- equivalent calls inferred from this helper; original call sites unknown
local function grow(p: number)
	local v5 = v3 + p
	local v6 = v4

	repeat
		v6 *= 2
	until v5 <= v6

	local buf2 = buffer.create(v6)
	buffer.copy(buf2, 0, buf, 0, v3)
	buf = buf2
	v4 = v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reserve(p: number)
	local v5 = v3 + p

	if v4 < v5 then
		grow(p) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wu8(value: number)
	reserve(1) -- equivalent call inferred; original call site unknown
	buffer.writeu8(buf, v3, value)
	v3 += 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wu16(value: number)
	reserve(2) -- equivalent call inferred; original call site unknown
	buffer.writeu16(buf, v3, value)
	v3 += 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wu32(value: number)
	reserve(4) -- equivalent call inferred; original call site unknown
	buffer.writeu32(buf, v3, value)
	v3 += 4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wi8(value: number)
	reserve(1) -- equivalent call inferred; original call site unknown
	buffer.writei8(buf, v3, value)
	v3 += 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wi16(value: number)
	reserve(2) -- equivalent call inferred; original call site unknown
	buffer.writei16(buf, v3, value)
	v3 += 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wi32(value: number)
	reserve(4) -- equivalent call inferred; original call site unknown
	buffer.writei32(buf, v3, value)
	v3 += 4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wf32(time: number)
	reserve(4) -- equivalent call inferred; original call site unknown
	buffer.writef32(buf, v3, time)
	v3 += 4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wf64(value: number)
	reserve(8) -- equivalent call inferred; original call site unknown
	buffer.writef64(buf, v3, value)
	v3 += 8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wstr(str: string)
	local count = #str
	reserve(count) -- equivalent call inferred; original call site unknown
	buffer.writestring(buf, v3, str)
	v3 += count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wlstr(list: string)
	local count = #list
	wu32(count) -- equivalent call inferred; original call site unknown

	if count > 0 then
		wstr(list) -- equivalent call inferred; original call site unknown
	end
end

local v5 = nil
local v6 = nil
local buf2 = buffer.create(0)
local v7 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function ru8()
	local v8 = buffer.readu8(buf2, v7)
	v7 += 1
	return v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ru16()
	local v8 = buffer.readu16(buf2, v7)
	v7 += 2
	return v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ru32()
	local v8 = buffer.readu32(buf2, v7)
	v7 += 4
	return v8
end

local function ri8()
	local v8 = buffer.readi8(buf2, v7)
	v7 += 1
	return v8
end

local function ri16()
	local v8 = buffer.readi16(buf2, v7)
	v7 += 2
	return v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ri32()
	local v8 = buffer.readi32(buf2, v7)
	v7 += 4
	return v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rf32()
	local v8 = buffer.readf32(buf2, v7)
	v7 += 4
	return v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rf64()
	local v8 = buffer.readf64(buf2, v7)
	v7 += 8
	return v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rstr(count: number)
	local v8 = buffer.readstring(buf2, v7, count)
	v7 += count
	return v8
end

local function rlstr()
	local v8 = ru32() -- equivalent call inferred; original call site unknown

	if v8 == 0 then
		return ""
	end

	return rstr(v8)
end

local callback = nil
local fn
local v8 = {}
local v9 = {}

v8[0] = function() end

v8[1] = function() end

v8[2] = function() end

v8[3] = function(value)
	wu8(value) -- equivalent call inferred; original call site unknown
end

v8[4] = function(value)
	wu16(value) -- equivalent call inferred; original call site unknown
end

v8[5] = function(value)
	wu32(value) -- equivalent call inferred; original call site unknown
end

v8[6] = function(value)
	wi8(value) -- equivalent call inferred; original call site unknown
end

v8[7] = function(value)
	wi16(value) -- equivalent call inferred; original call site unknown
end

v8[8] = function(value)
	wi32(value) -- equivalent call inferred; original call site unknown
end

v8[9] = function(value)
	wf64(value) -- equivalent call inferred; original call site unknown
end

v8[10] = function(list)
	wu8(#list) -- equivalent call inferred; original call site unknown
	wstr(list) -- equivalent call inferred; original call site unknown
end

v8[11] = function(list)
	wu16(#list) -- equivalent call inferred; original call site unknown
	wstr(list) -- equivalent call inferred; original call site unknown
end

v8[12] = function(list)
	wu32(#list) -- equivalent call inferred; original call site unknown
	wstr(list) -- equivalent call inferred; original call site unknown
end

v8[13] = function(p)
	local v10 = buffer.len(p)
	wu32(v10) -- equivalent call inferred; original call site unknown
	reserve(v10) -- equivalent call inferred; original call site unknown
	buffer.copy(buf, v3, p, 0, v10)
	v3 += v10
end

v9[0] = function()
	return nil
end

v9[1] = function()
	return false
end

v9[2] = function()
	return true
end

v9[3] = ru8
v9[4] = ru16
v9[5] = ru32
v9[6] = ri8
v9[7] = ri16
v9[8] = ri32
v9[9] = rf64

v9[10] = function()
	local v10 = ru8() -- equivalent call inferred; original call site unknown

	if v10 == 0 then
		return ""
	end

	return rstr(v10)
end

v9[11] = function()
	local v10 = ru16() -- equivalent call inferred; original call site unknown

	if v10 == 0 then
		return ""
	end

	return rstr(v10)
end

v9[12] = function()
	local v10 = ru32() -- equivalent call inferred; original call site unknown

	if v10 == 0 then
		return ""
	end

	return rstr(v10)
end

v9[13] = function()
	local v10 = ru32() -- equivalent call inferred; original call site unknown
	local buf3 = buffer.create(v10)
	buffer.copy(buf3, 0, buf2, v7, v10)
	v7 += v10
	return buf3
end

v8[14] = function(p)
	wlstr(tostring(p)) -- equivalent call inferred; original call site unknown
end

v8[15] = function(p)
	wlstr(tostring(p.EnumType)) -- equivalent call inferred; original call site unknown
	wi32(p.Value) -- equivalent call inferred; original call site unknown
end

v9[14] = function()
	local enum = Enum
	local v10 = buffer.readu32(buf2, v7)
	v7 += 4
	local v11

	if v10 == 0 then
		v11 = ""
	else
		v11 = buffer.readstring(buf2, v7, v10)
		v7 += v10
	end

	return enum[v11]
end

v9[15] = function()
	local enum = Enum
	local v10 = buffer.readu32(buf2, v7)
	v7 += 4
	local v11

	if v10 == 0 then
		v11 = ""
	else
		v11 = buffer.readstring(buf2, v7, v10)
		v7 += v10
	end

	return enum[v11]:FromValue(ri32())
end

v8[92] = function(p)
	if not v5 then
		error("Buff: Instance serialization requires enableInstances=true in encode()")
	end

	table.insert(v5, p)
	wu32(#v5) -- equivalent call inferred; original call site unknown
end

v9[92] = function()
	local v10 = ru32() -- equivalent call inferred; original call site unknown

	if not v6 then
		error("Buff: buffer contains Instance refs but no instances array was provided to decode()")
	end

	return v6[v10]
end

v8[64] = function(data)
	local total = 0

	if data.X then
		total += 1
	end

	if data.Y then
		total += 2
	end

	if data.Z then
		total += 4
	end

	wu8(total) -- equivalent call inferred; original call site unknown
end

v9[64] = function()
	local v10 = ru8() -- equivalent call inferred; original call site unknown
	local v11 = {}

	if bit32.band(v10, 1) ~= 0 then
		table.insert(v11, Enum.Axis.X)
	end

	if bit32.band(v10, 2) ~= 0 then
		table.insert(v11, Enum.Axis.Y)
	end

	if bit32.band(v10, 4) ~= 0 then
		table.insert(v11, Enum.Axis.Z)
	end

	return Axes.new(table.unpack(v11))
end

v8[65] = function(p)
	wu16(p.Number) -- equivalent call inferred; original call site unknown
end

v9[65] = function()
	return BrickColor.new(ru16())
end

v8[66] = function(cframe)
	reserve(48) -- equivalent call inferred; original call site unknown
	local v10 = v3
	local buf3 = buf
	local components, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21 = cframe:GetComponents()
	buffer.writef32(buf3, v10, components)
	buffer.writef32(buf3, v10 + 4, v11)
	buffer.writef32(buf3, v10 + 8, v12)
	buffer.writef32(buf3, v10 + 12, v13)
	buffer.writef32(buf3, v10 + 16, v14)
	buffer.writef32(buf3, v10 + 20, v15)
	buffer.writef32(buf3, v10 + 24, v16)
	buffer.writef32(buf3, v10 + 28, v17)
	buffer.writef32(buf3, v10 + 32, v18)
	buffer.writef32(buf3, v10 + 36, v19)
	buffer.writef32(buf3, v10 + 40, v20)
	buffer.writef32(buf3, v10 + 44, v21)
	v3 = v10 + 48
end

v9[66] = function()
	local v10 = v7
	local buf3 = buf2
	local cframe = CFrame.new(
		buffer.readf32(buf3, v10),
		buffer.readf32(buf3, v10 + 4),
		buffer.readf32(buf3, v10 + 8),
		buffer.readf32(buf3, v10 + 12),
		buffer.readf32(buf3, v10 + 16),
		buffer.readf32(buf3, v10 + 20),
		buffer.readf32(buf3, v10 + 24),
		buffer.readf32(buf3, v10 + 28),
		buffer.readf32(buf3, v10 + 32),
		buffer.readf32(buf3, v10 + 36),
		buffer.readf32(buf3, v10 + 40),
		(buffer.readf32(buf3, v10 + 44))
	)
	v7 = v10 + 48
	return cframe
end

v8[67] = function(data)
	reserve(12) -- equivalent call inferred; original call site unknown
	local v10 = v3
	buffer.writef32(buf, v10, data.R)
	buffer.writef32(buf, v10 + 4, data.G)
	buffer.writef32(buf, v10 + 8, data.B)
	v3 = v10 + 12
end

v9[67] = function()
	local v10 = v7
	local color = Color3.new(buffer.readf32(buf2, v10), buffer.readf32(buf2, v10 + 4), (buffer.readf32(buf2, v10 + 8)))
	v7 = v10 + 12
	return color
end

v8[68] = function(p)
	reserve(16) -- equivalent call inferred; original call site unknown
	local v10 = v3
	buffer.writef32(buf, v10, p.Time)
	buffer.writef32(buf, v10 + 4, p.Value.R)
	buffer.writef32(buf, v10 + 8, p.Value.G)
	buffer.writef32(buf, v10 + 12, p.Value.B)
	v3 = v10 + 16
end

v9[68] = function()
	local v10 = v7
	local buf3 = buf2
	local colorSequenceKeypoint = ColorSequenceKeypoint.new(
		buffer.readf32(buf3, v10),
		Color3.new(buffer.readf32(buf3, v10 + 4), buffer.readf32(buf3, v10 + 8), (buffer.readf32(buf3, v10 + 12)))
	)
	v7 = v10 + 16
	return colorSequenceKeypoint
end

v8[69] = function(sequence)
	local keypoints = sequence.Keypoints
	local count = #keypoints
	wu32(count) -- equivalent call inferred; original call site unknown
	reserve(count * 16) -- equivalent call inferred; original call site unknown

	for i = 1, count do
		local keypoint = keypoints[i]
		local v11 = v3
		buffer.writef32(buf, v11, keypoint.Time)
		buffer.writef32(buf, v11 + 4, keypoint.Value.R)
		buffer.writef32(buf, v11 + 8, keypoint.Value.G)
		buffer.writef32(buf, v11 + 12, keypoint.Value.B)
		v3 = v11 + 16
	end
end

v9[69] = function()
	local v10 = ru32() -- equivalent call inferred; original call site unknown
	local colorSequenceKeypoints = table.create(v10)

	for i = 1, v10 do
		local v11 = v7
		local buf3 = buf2
		colorSequenceKeypoints[i] = ColorSequenceKeypoint.new(
			buffer.readf32(buf3, v11),
			Color3.new(buffer.readf32(buf3, v11 + 4), buffer.readf32(buf3, v11 + 8), (buffer.readf32(buf3, v11 + 12)))
		)
		v7 = v11 + 16
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

v8[70] = function(p)
	wf64(p.UnixTimestampMillis) -- equivalent call inferred; original call site unknown
end

v9[70] = function()
	return DateTime.fromUnixTimestampMillis(rf64())
end

v8[71] = function(data)
	local total = 0

	if data.Top then
		total += 1
	end

	if data.Bottom then
		total += 2
	end

	if data.Left then
		total += 4
	end

	if data.Right then
		total += 8
	end

	if data.Front then
		total += 16
	end

	if data.Back then
		total += 32
	end

	wu8(total) -- equivalent call inferred; original call site unknown
end

v9[71] = function()
	local v10 = ru8() -- equivalent call inferred; original call site unknown
	local v11 = {}

	if bit32.band(v10, 1) ~= 0 then
		table.insert(v11, Enum.NormalId.Top)
	end

	if bit32.band(v10, 2) ~= 0 then
		table.insert(v11, Enum.NormalId.Bottom)
	end

	if bit32.band(v10, 4) ~= 0 then
		table.insert(v11, Enum.NormalId.Left)
	end

	if bit32.band(v10, 8) ~= 0 then
		table.insert(v11, Enum.NormalId.Right)
	end

	if bit32.band(v10, 16) ~= 0 then
		table.insert(v11, Enum.NormalId.Front)
	end

	if bit32.band(v10, 32) ~= 0 then
		table.insert(v11, Enum.NormalId.Back)
	end

	return Faces.new(table.unpack(v11))
end

v8[72] = function(data)
	wlstr(data.Family) -- equivalent call inferred; original call site unknown
	wu32(data.Weight.Value) -- equivalent call inferred; original call site unknown
	wu32(data.Style.Value) -- equivalent call inferred; original call site unknown
end

v9[72] = function()
	local v10 = buffer.readu32(buf2, v7)
	v7 += 4
	local v11

	if v10 == 0 then
		v11 = ""
	else
		v11 = buffer.readstring(buf2, v7, v10)
		v7 += v10
	end

	local v12 = Enum.FontWeight:FromValue(ru32())
	local v13 = Enum.FontStyle:FromValue(ru32())
	return Font.new(v11, v12, v13)
end

v8[73] = function(p)
	reserve(8) -- equivalent call inferred; original call site unknown
	buffer.writef32(buf, v3, p.Min)
	buffer.writef32(buf, v3 + 4, p.Max)
	v3 += 8
end

v9[73] = function()
	local v10 = buffer.readf32(buf2, v7)
	local v11 = buffer.readf32(buf2, v7 + 4)
	v7 += 8
	return NumberRange.new(v10, v11)
end

v8[74] = function(data)
	reserve(12) -- equivalent call inferred; original call site unknown
	local v10 = v3
	buffer.writef32(buf, v10, data.Time)
	buffer.writef32(buf, v10 + 4, data.Value)
	buffer.writef32(buf, v10 + 8, data.Envelope)
	v3 = v10 + 12
end

v9[74] = function()
	local v10 = v7
	local buf3 = buf2
	local numberSequenceKeypoint = NumberSequenceKeypoint.new(
		buffer.readf32(buf3, v10),
		buffer.readf32(buf3, v10 + 4),
		(buffer.readf32(buf3, v10 + 8))
	)
	v7 = v10 + 12
	return numberSequenceKeypoint
end

v8[75] = function(sequence)
	local keypoints = sequence.Keypoints
	local count = #keypoints
	wu32(count) -- equivalent call inferred; original call site unknown
	reserve(count * 12) -- equivalent call inferred; original call site unknown

	for i = 1, count do
		local keypoint = keypoints[i]
		local v11 = v3
		buffer.writef32(buf, v11, keypoint.Time)
		buffer.writef32(buf, v11 + 4, keypoint.Value)
		buffer.writef32(buf, v11 + 8, keypoint.Envelope)
		v3 = v11 + 12
	end
end

v9[75] = function()
	local v10 = ru32() -- equivalent call inferred; original call site unknown
	local numberSequenceKeypoints = table.create(v10)

	for i = 1, v10 do
		local v11 = v7
		local buf3 = buf2
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			buffer.readf32(buf3, v11),
			buffer.readf32(buf3, v11 + 4),
			(buffer.readf32(buf3, v11 + 8))
		)
		v7 = v11 + 12
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

v8[76] = function(data)
	reserve(20) -- equivalent call inferred; original call site unknown
	local v10 = v3
	buffer.writef32(buf, v10, data.Density)
	buffer.writef32(buf, v10 + 4, data.Friction)
	buffer.writef32(buf, v10 + 8, data.Elasticity)
	buffer.writef32(buf, v10 + 12, data.FrictionWeight)
	buffer.writef32(buf, v10 + 16, data.ElasticityWeight)
	v3 = v10 + 20
end

v9[76] = function()
	local v10 = v7
	local buf3 = buf2
	local physicalProperties = PhysicalProperties.new(
		buffer.readf32(buf3, v10),
		buffer.readf32(buf3, v10 + 4),
		buffer.readf32(buf3, v10 + 8),
		buffer.readf32(buf3, v10 + 12),
		(buffer.readf32(buf3, v10 + 16))
	)
	v7 = v10 + 20
	return physicalProperties
end

v8[77] = function(p)
	reserve(24) -- equivalent call inferred; original call site unknown
	local v10 = v3
	local origin = p.Origin
	local direction = p.Direction
	buffer.writef32(buf, v10, origin.X)
	buffer.writef32(buf, v10 + 4, origin.Y)
	buffer.writef32(buf, v10 + 8, origin.Z)
	buffer.writef32(buf, v10 + 12, direction.X)
	buffer.writef32(buf, v10 + 16, direction.Y)
	buffer.writef32(buf, v10 + 20, direction.Z)
	v3 = v10 + 24
end

v9[77] = function()
	local v10 = v7
	local buf3 = buf2
	local ray = Ray.new(
		Vector3.new(buffer.readf32(buf3, v10), buffer.readf32(buf3, v10 + 4), (buffer.readf32(buf3, v10 + 8))),
		(Vector3.new(buffer.readf32(buf3, v10 + 12), buffer.readf32(buf3, v10 + 16), (buffer.readf32(buf3, v10 + 20))))
	)
	v7 = v10 + 24
	return ray
end

v8[78] = function(p)
	reserve(16) -- equivalent call inferred; original call site unknown
	local v10 = v3
	buffer.writef32(buf, v10, p.Min.X)
	buffer.writef32(buf, v10 + 4, p.Min.Y)
	buffer.writef32(buf, v10 + 8, p.Max.X)
	buffer.writef32(buf, v10 + 12, p.Max.Y)
	v3 = v10 + 16
end

v9[78] = function()
	local v10 = v7
	local buf3 = buf2
	local rect = Rect.new(
		buffer.readf32(buf3, v10),
		buffer.readf32(buf3, v10 + 4),
		buffer.readf32(buf3, v10 + 8),
		(buffer.readf32(buf3, v10 + 12))
	)
	v7 = v10 + 16
	return rect
end

v8[79] = function(instance)
	reserve(24) -- equivalent call inferred; original call site unknown
	local v10 = v3
	local position = instance.CFrame.Position
	local halfSize = instance.Size / 2
	local v12 = position - halfSize
	local v13 = position + halfSize
	buffer.writef32(buf, v10, v12.X)
	buffer.writef32(buf, v10 + 4, v12.Y)
	buffer.writef32(buf, v10 + 8, v12.Z)
	buffer.writef32(buf, v10 + 12, v13.X)
	buffer.writef32(buf, v10 + 16, v13.Y)
	buffer.writef32(buf, v10 + 20, v13.Z)
	v3 = v10 + 24
end

v9[79] = function()
	local v10 = v7
	local buf3 = buf2
	local region = Region3.new(
		Vector3.new(buffer.readf32(buf3, v10), buffer.readf32(buf3, v10 + 4), (buffer.readf32(buf3, v10 + 8))),
		(Vector3.new(buffer.readf32(buf3, v10 + 12), buffer.readf32(buf3, v10 + 16), (buffer.readf32(buf3, v10 + 20))))
	)
	v7 = v10 + 24
	return region
end

v8[80] = function(p)
	reserve(12) -- equivalent call inferred; original call site unknown
	local v10 = v3
	local min = p.Min
	local max = p.Max
	buffer.writei16(buf, v10, min.X)
	buffer.writei16(buf, v10 + 2, min.Y)
	buffer.writei16(buf, v10 + 4, min.Z)
	buffer.writei16(buf, v10 + 6, max.X)
	buffer.writei16(buf, v10 + 8, max.Y)
	buffer.writei16(buf, v10 + 10, max.Z)
	v3 = v10 + 12
end

v9[80] = function()
	local v10 = v7
	local buf3 = buf2
	local region3int = Region3int16.new(
		Vector3int16.new(buffer.readi16(buf3, v10), buffer.readi16(buf3, v10 + 2), (buffer.readi16(buf3, v10 + 4))),
		Vector3int16.new(buffer.readi16(buf3, v10 + 6), buffer.readi16(buf3, v10 + 8), (buffer.readi16(buf3, v10 + 10)))
	)
	v7 = v10 + 12
	return region3int
end

v8[81] = function(data)
	reserve(21) -- equivalent call inferred; original call site unknown
	local v10 = v3
	buffer.writef32(buf, v10, data.Time)
	buffer.writeu32(buf, v10 + 4, data.EasingStyle.Value)
	buffer.writeu32(buf, v10 + 8, data.EasingDirection.Value)
	buffer.writei32(buf, v10 + 12, data.RepeatCount)
	buffer.writeu8(buf, v10 + 16, data.Reverses and 1 or 0)
	buffer.writef32(buf, v10 + 17, data.DelayTime)
	v3 = v10 + 21
end

v9[81] = function()
	local v10 = v7
	local buf3 = buf2
	local tweenInfo = TweenInfo.new(
		buffer.readf32(buf3, v10),
		Enum.EasingStyle:FromValue((buffer.readu32(buf3, v10 + 4))),
		Enum.EasingDirection:FromValue((buffer.readu32(buf3, v10 + 8))),
		buffer.readi32(buf3, v10 + 12),
		buffer.readu8(buf3, v10 + 16) == 1,
		(buffer.readf32(buf3, v10 + 17))
	)
	v7 = v10 + 21
	return tweenInfo
end

v8[82] = function(p)
	reserve(8) -- equivalent call inferred; original call site unknown
	buffer.writef32(buf, v3, p.Scale)
	buffer.writei32(buf, v3 + 4, p.Offset)
	v3 += 8
end

v9[82] = function()
	local v10 = buffer.readf32(buf2, v7)
	local v11 = buffer.readi32(buf2, v7 + 4)
	v7 += 8
	return UDim.new(v10, v11)
end

v8[83] = function(p)
	reserve(16) -- equivalent call inferred; original call site unknown
	local v10 = v3
	buffer.writef32(buf, v10, p.X.Scale)
	buffer.writei32(buf, v10 + 4, p.X.Offset)
	buffer.writef32(buf, v10 + 8, p.Y.Scale)
	buffer.writei32(buf, v10 + 12, p.Y.Offset)
	v3 = v10 + 16
end

v9[83] = function()
	local v10 = v7
	local buf3 = buf2
	local uDim = UDim2.new(
		UDim.new(buffer.readf32(buf3, v10), (buffer.readi32(buf3, v10 + 4))),
		UDim.new(buffer.readf32(buf3, v10 + 8), (buffer.readi32(buf3, v10 + 12)))
	)
	v7 = v10 + 16
	return uDim
end

v8[84] = function(p)
	reserve(8) -- equivalent call inferred; original call site unknown
	buffer.writef32(buf, v3, p.X)
	buffer.writef32(buf, v3 + 4, p.Y)
	v3 += 8
end

v9[84] = function()
	local v10 = buffer.readf32(buf2, v7)
	local v11 = buffer.readf32(buf2, v7 + 4)
	v7 += 8
	return Vector2.new(v10, v11)
end

v8[85] = function(p)
	reserve(4) -- equivalent call inferred; original call site unknown
	buffer.writei16(buf, v3, p.X)
	buffer.writei16(buf, v3 + 2, p.Y)
	v3 += 4
end

v9[85] = function()
	local v10 = buffer.readi16(buf2, v7)
	local v11 = buffer.readi16(buf2, v7 + 2)
	v7 += 4
	return Vector2int16.new(v10, v11)
end

v8[86] = function(data)
	reserve(12) -- equivalent call inferred; original call site unknown
	local v10 = v3
	buffer.writef32(buf, v10, data.X)
	buffer.writef32(buf, v10 + 4, data.Y)
	buffer.writef32(buf, v10 + 8, data.Z)
	v3 = v10 + 12
end

v9[86] = function()
	local v10 = v7
	local buf3 = buf2
	local vector = Vector3.new(
		buffer.readf32(buf3, v10),
		buffer.readf32(buf3, v10 + 4),
		(buffer.readf32(buf3, v10 + 8))
	)
	v7 = v10 + 12
	return vector
end

v8[87] = function(data)
	reserve(6) -- equivalent call inferred; original call site unknown
	local v10 = v3
	buffer.writei16(buf, v10, data.X)
	buffer.writei16(buf, v10 + 2, data.Y)
	buffer.writei16(buf, v10 + 4, data.Z)
	v3 = v10 + 6
end

v9[87] = function()
	local v10 = v7
	local buf3 = buf2
	local vector3int = Vector3int16.new(
		buffer.readi16(buf3, v10),
		buffer.readi16(buf3, v10 + 2),
		(buffer.readi16(buf3, v10 + 4))
	)
	v7 = v10 + 6
	return vector3int
end

v8[88] = function(p)
	reserve(13) -- equivalent call inferred; original call site unknown
	local v10 = v3
	local position = p.Position
	buffer.writef32(buf, v10, position.X)
	buffer.writef32(buf, v10 + 4, position.Y)
	buffer.writef32(buf, v10 + 8, position.Z)
	buffer.writeu8(buf, v10 + 12, p.Action.Value)
	v3 = v10 + 13
end

v9[88] = function()
	local v10 = v7
	local buf3 = buf2
	local pathWaypoint = PathWaypoint.new(
		Vector3.new(buffer.readf32(buf3, v10), buffer.readf32(buf3, v10 + 4), (buffer.readf32(buf3, v10 + 8))),
		(Enum.PathWaypointAction:FromValue((buffer.readu8(buf3, v10 + 12))))
	)
	v7 = v10 + 13
	return pathWaypoint
end

v8[89] = function(data)
	reserve(9) -- equivalent call inferred; original call site unknown
	local v10 = v3
	buffer.writef32(buf, v10, data.Time)
	buffer.writef32(buf, v10 + 4, data.Value)
	buffer.writeu8(buf, v10 + 8, data.Interpolation.Value)
	v3 = v10 + 9
end

v9[89] = function()
	local v10 = v7
	local buf3 = buf2
	local floatCurveKey = FloatCurveKey.new(
		buffer.readf32(buf3, v10),
		buffer.readf32(buf3, v10 + 4),
		(Enum.KeyInterpolationMode:FromValue((buffer.readu8(buf3, v10 + 8))))
	)
	v7 = v10 + 9
	return floatCurveKey
end

v8[90] = function(data)
	wf32(data.Time) -- equivalent call inferred; original call site unknown
	v8[66](data.Value)
	wu8(data.Interpolation.Value) -- equivalent call inferred; original call site unknown
end

v9[90] = function()
	local v10 = rf32() -- equivalent call inferred; original call site unknown
	local v11 = v9[66]()
	local v12 = Enum.KeyInterpolationMode:FromValue(ru8())
	return RotationCurveKey.new(v10, v11, v12)
end

v8[91] = function(data)
	reserve(48) -- equivalent call inferred; original call site unknown
	local v10 = v3
	local buf3 = buf
	local position = data.Position
	local leftTangent = data.LeftTangent
	local rightTangent = data.RightTangent
	buffer.writef32(buf3, v10, position.X.Scale)
	buffer.writei32(buf3, v10 + 4, position.X.Offset)
	buffer.writef32(buf3, v10 + 8, position.Y.Scale)
	buffer.writei32(buf3, v10 + 12, position.Y.Offset)
	buffer.writef32(buf3, v10 + 16, leftTangent.X.Scale)
	buffer.writei32(buf3, v10 + 20, leftTangent.X.Offset)
	buffer.writef32(buf3, v10 + 24, leftTangent.Y.Scale)
	buffer.writei32(buf3, v10 + 28, leftTangent.Y.Offset)
	buffer.writef32(buf3, v10 + 32, rightTangent.X.Scale)
	buffer.writei32(buf3, v10 + 36, rightTangent.X.Offset)
	buffer.writef32(buf3, v10 + 40, rightTangent.Y.Scale)
	buffer.writei32(buf3, v10 + 44, rightTangent.Y.Offset)
	v3 = v10 + 48
end

v9[91] = function()
	local v10 = v7
	local buf3 = buf2
	local path2DControlPoint = Path2DControlPoint.new(
		UDim2.new(
			UDim.new(buffer.readf32(buf3, v10), (buffer.readi32(buf3, v10 + 4))),
			UDim.new(buffer.readf32(buf3, v10 + 8), (buffer.readi32(buf3, v10 + 12)))
		),
		UDim2.new(
			UDim.new(buffer.readf32(buf3, v10 + 16), (buffer.readi32(buf3, v10 + 20))),
			UDim.new(buffer.readf32(buf3, v10 + 24), (buffer.readi32(buf3, v10 + 28)))
		),
		UDim2.new(
			UDim.new(buffer.readf32(buf3, v10 + 32), (buffer.readi32(buf3, v10 + 36))),
			UDim.new(buffer.readf32(buf3, v10 + 40), (buffer.readi32(buf3, v10 + 44)))
		)
	)
	v7 = v10 + 48
	return path2DControlPoint
end

v9[16] = function()
	return {}
end

v9[17] = function()
	local v10 = ru32() -- equivalent call inferred; original call site unknown
	local result = table.create(v10)

	for i = 1, v10 do
		result[i] = fn()
	end

	return result
end

v9[21] = function()
	local result = {}

	while buffer.readu8(buf2, v7) ~= 255 do
		result[fn()] = fn()
	end

	v7 += 1
	return result
end

local function fn2(list)
	local typeName = typeof(list)

	if typeName == "number" then
		reserve(9) -- equivalent call inferred; original call site unknown
		buffer.writeu8(buf, v3, 9)
		buffer.writef64(buf, v3 + 1, list)
		v3 += 9
	elseif typeName == "string" then
		local count = #list
		local v10 = v3 + 5 + count

		if v4 < v10 then
			grow(count + 5) -- equivalent call inferred; original call site unknown
		end

		buffer.writeu8(buf, v3, 12)
		buffer.writeu32(buf, v3 + 1, count)
		buffer.writestring(buf, v3 + 5, list)
		v3 += count + 5
	elseif typeName == "boolean" then
		reserve(1) -- equivalent call inferred; original call site unknown
		buffer.writeu8(buf, v3, list and 2 or 1)
		v3 += 1
	elseif typeName == "table" then
		local count = #list

		if count > 0 and next(list, count) == nil then
			reserve(5) -- equivalent call inferred; original call site unknown
			buffer.writeu8(buf, v3, 17)
			buffer.writeu32(buf, v3 + 1, count)
			v3 += 5

			for i = 1, count do
				local v10 = list[i]
				local typeName2 = type(v10)

				if typeName2 == "number" then
					reserve(9) -- equivalent call inferred; original call site unknown
					buffer.writeu8(buf, v3, 9)
					buffer.writef64(buf, v3 + 1, v10)
					v3 += 9
				elseif typeName2 == "string" then
					local count2 = #v10
					local v11 = v3 + 5 + count2

					if v4 < v11 then
						grow(count2 + 5) -- equivalent call inferred; original call site unknown
					end

					buffer.writeu8(buf, v3, 12)
					buffer.writeu32(buf, v3 + 1, count2)
					buffer.writestring(buf, v3 + 5, v10)
					v3 += count2 + 5
				elseif typeName2 == "boolean" then
					reserve(1) -- equivalent call inferred; original call site unknown
					buffer.writeu8(buf, v3, v10 and 2 or 1)
					v3 += 1
				else
					callback(v10)
				end
			end
		elseif count == 0 and next(list) == nil then
			wu8(16) -- equivalent call inferred; original call site unknown
		else
			wu8(21) -- equivalent call inferred; original call site unknown

			for k, v10 in list do
				local typeName2 = type(k)

				if typeName2 == "number" then
					reserve(9) -- equivalent call inferred; original call site unknown
					buffer.writeu8(buf, v3, 9)
					buffer.writef64(buf, v3 + 1, k)
					v3 += 9
				elseif typeName2 == "string" then
					local count2 = #k
					local v11 = v3 + 5 + count2

					if v4 < v11 then
						grow(count2 + 5) -- equivalent call inferred; original call site unknown
					end

					buffer.writeu8(buf, v3, 12)
					buffer.writeu32(buf, v3 + 1, count2)
					buffer.writestring(buf, v3 + 5, k)
					v3 += count2 + 5
				else
					callback(k)
				end

				local typeName3 = type(v10)

				if typeName3 == "number" then
					reserve(9) -- equivalent call inferred; original call site unknown
					buffer.writeu8(buf, v3, 9)
					buffer.writef64(buf, v3 + 1, v10)
					v3 += 9
				elseif typeName3 == "string" then
					local count2 = #v10
					local v11 = v3 + 5 + count2

					if v4 < v11 then
						grow(count2 + 5) -- equivalent call inferred; original call site unknown
					end

					buffer.writeu8(buf, v3, 12)
					buffer.writeu32(buf, v3 + 1, count2)
					buffer.writestring(buf, v3 + 5, v10)
					v3 += count2 + 5
				elseif typeName3 == "boolean" then
					reserve(1) -- equivalent call inferred; original call site unknown
					buffer.writeu8(buf, v3, v10 and 2 or 1)
					v3 += 1
				else
					callback(v10)
				end
			end

			wu8(255) -- equivalent call inferred; original call site unknown
		end
	elseif typeName == "buffer" then
		local v10 = buffer.len(list)
		local v11 = v3 + 5 + v10

		if v4 < v11 then
			grow(5 + v10) -- equivalent call inferred; original call site unknown
		end

		buffer.writeu8(buf, v3, 13)
		buffer.writeu32(buf, v3 + 1, v10)
		buffer.copy(buf, v3 + 5, list, 0, v10)
		v3 += 5 + v10
	elseif list == nil then
		wu8(0) -- equivalent call inferred; original call site unknown
	elseif typeName == "Instance" then
		if not v5 then
			error("Buff: Instance serialization requires enableInstances=true in encode()")
		end

		table.insert(v5, list)
		reserve(5) -- equivalent call inferred; original call site unknown
		buffer.writeu8(buf, v3, 92)
		buffer.writeu32(buf, v3 + 1, #v5)
		v3 += 5
	else
		local v10 = v2[typeName]

		if not v10 then
			error((`Buff: unsupported type "{typeName}"`))
		end

		wu8(v10) -- equivalent call inferred; original call site unknown
		v8[v10](list)
	end
end

local function fn3(list)
	local typeName = typeof(list)

	if typeName == "number" then
		if list == list and list % 1 == 0 then
			if list >= 0 then
				if list <= 255 then
					reserve(2) -- equivalent call inferred; original call site unknown
					buffer.writeu8(buf, v3, 3)
					buffer.writeu8(buf, v3 + 1, list)
					v3 += 2
					return
				elseif list <= 65535 then
					reserve(3) -- equivalent call inferred; original call site unknown
					buffer.writeu8(buf, v3, 4)
					buffer.writeu16(buf, v3 + 1, list)
					v3 += 3
					return
				elseif list <= 4294967295 then
					reserve(5) -- equivalent call inferred; original call site unknown
					buffer.writeu8(buf, v3, 5)
					buffer.writeu32(buf, v3 + 1, list)
					v3 += 5
					return
				end
			elseif list >= -128 then
				reserve(2) -- equivalent call inferred; original call site unknown
				buffer.writeu8(buf, v3, 6)
				buffer.writei8(buf, v3 + 1, list)
				v3 += 2
				return
			elseif list >= -32768 then
				reserve(3) -- equivalent call inferred; original call site unknown
				buffer.writeu8(buf, v3, 7)
				buffer.writei16(buf, v3 + 1, list)
				v3 += 3
				return
			elseif list >= -2147483648 then
				reserve(5) -- equivalent call inferred; original call site unknown
				buffer.writeu8(buf, v3, 8)
				buffer.writei32(buf, v3 + 1, list)
				v3 += 5
				return
			end
		end

		reserve(9) -- equivalent call inferred; original call site unknown
		buffer.writeu8(buf, v3, 9)
		buffer.writef64(buf, v3 + 1, list)
		v3 += 9
	elseif typeName == "string" then
		local count = #list

		if count <= 255 then
			local v10 = v3 + 2 + count

			if v4 < v10 then
				grow(count + 2) -- equivalent call inferred; original call site unknown
			end

			buffer.writeu8(buf, v3, 10)
			buffer.writeu8(buf, v3 + 1, count)
			buffer.writestring(buf, v3 + 2, list)
			v3 += count + 2
		elseif count <= 65535 then
			local v10 = v3 + 3 + count

			if v4 < v10 then
				grow(count + 3) -- equivalent call inferred; original call site unknown
			end

			buffer.writeu8(buf, v3, 11)
			buffer.writeu16(buf, v3 + 1, count)
			buffer.writestring(buf, v3 + 3, list)
			v3 += count + 3
		else
			local v10 = v3 + 5 + count

			if v4 < v10 then
				grow(count + 5) -- equivalent call inferred; original call site unknown
			end

			buffer.writeu8(buf, v3, 12)
			buffer.writeu32(buf, v3 + 1, count)
			buffer.writestring(buf, v3 + 5, list)
			v3 += count + 5
		end
	elseif typeName == "boolean" then
		reserve(1) -- equivalent call inferred; original call site unknown
		buffer.writeu8(buf, v3, list and 2 or 1)
		v3 += 1
	elseif typeName == "table" then
		local count = #list

		if count > 0 and next(list, count) == nil then
			reserve(5) -- equivalent call inferred; original call site unknown
			buffer.writeu8(buf, v3, 17)
			buffer.writeu32(buf, v3 + 1, count)
			v3 += 5

			for i = 1, count do
				callback(list[i])
			end
		elseif count == 0 and next(list) == nil then
			wu8(16) -- equivalent call inferred; original call site unknown
		else
			wu8(21) -- equivalent call inferred; original call site unknown

			for k, v10 in list do
				callback(k)
				callback(v10)
			end

			wu8(255) -- equivalent call inferred; original call site unknown
		end
	elseif typeName == "buffer" then
		local v10 = buffer.len(list)
		local v11 = v3 + 5 + v10

		if v4 < v11 then
			grow(5 + v10) -- equivalent call inferred; original call site unknown
		end

		buffer.writeu8(buf, v3, 13)
		buffer.writeu32(buf, v3 + 1, v10)
		buffer.copy(buf, v3 + 5, list, 0, v10)
		v3 += 5 + v10
	elseif list == nil then
		wu8(0) -- equivalent call inferred; original call site unknown
	elseif typeName == "Instance" then
		if not v5 then
			error("Buff: Instance serialization requires enableInstances=true in encode()")
		end

		table.insert(v5, list)
		reserve(5) -- equivalent call inferred; original call site unknown
		buffer.writeu8(buf, v3, 92)
		buffer.writeu32(buf, v3 + 1, #v5)
		v3 += 5
	else
		local v10 = v2[typeName]

		if not v10 then
			error((`Buff: unsupported type "{typeName}"`))
		end

		wu8(v10) -- equivalent call inferred; original call site unknown
		v8[v10](list)
	end
end

callback = fn2

fn = function()
	local v10 = ru8() -- equivalent call inferred; original call site unknown
	local callback2 = v9[v10]

	if not callback2 then
		error((`Buff: unknown type tag {v10} at offset {v7 - 1}`))
	end

	return callback2()
end

function v.encode(p, p2: string?, flag: boolean?)
	v3 = 0
	v5 = flag and {} or nil
	local v10

	if p2 == "size" then
		v10 = fn3
	else
		v10 = fn2
	end

	callback = v10
	callback(p)
	local buf3 = buffer.create(v3)
	buffer.copy(buf3, 0, buf, 0, v3)
	local v11 = v5
	v5 = nil

	if v11 and #v11 > 0 then
		return buf3, v11
	end

	return buf3, nil
end

function v.decode(buf3: buffer, p)
	buf2 = buf3
	v7 = 0
	v6 = p
	local v10 = fn()
	v6 = nil
	return v10
end

function v.analyze(buf3: buffer)
	local total = 0
	local v10 = buffer.len(buf3)
	local v11 = {}
	local v12 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function record(formatted: string, p: number)
		v11[formatted] = (v11[formatted] or 0) + 1
		v12[formatted] = (v12[formatted] or 0) + p
	end

	local walk

	walk = function()
		local v13 = buffer.readu8(buf3, total)
		total += 1

		if v13 == 0 then
			record("nil", 1) -- equivalent call inferred; original call site unknown
		elseif v13 == 1 or v13 == 2 then
			record("boolean", 1) -- equivalent call inferred; original call site unknown
		elseif v13 == 3 then
			record("number (u8)", 2) -- equivalent call inferred; original call site unknown
			total += 1
		elseif v13 == 4 then
			record("number (u16)", 3) -- equivalent call inferred; original call site unknown
			total += 2
		elseif v13 == 5 then
			record("number (u32)", 5) -- equivalent call inferred; original call site unknown
			total += 4
		elseif v13 == 6 then
			record("number (i8)", 2) -- equivalent call inferred; original call site unknown
			total += 1
		elseif v13 == 7 then
			record("number (i16)", 3) -- equivalent call inferred; original call site unknown
			total += 2
		elseif v13 == 8 then
			record("number (i32)", 5) -- equivalent call inferred; original call site unknown
			total += 4
		elseif v13 == 9 then
			record("number (f64)", 9) -- equivalent call inferred; original call site unknown
			total += 8
		elseif v13 == 10 then
			local v14 = buffer.readu8(buf3, total)
			total += v14 + 1
			record("string (u8 hdr)", v14 + 2) -- equivalent call inferred; original call site unknown
		elseif v13 == 11 then
			local v14 = buffer.readu16(buf3, total)
			total += v14 + 2
			record("string (u16 hdr)", v14 + 3) -- equivalent call inferred; original call site unknown
		elseif v13 == 12 then
			local v14 = buffer.readu32(buf3, total)
			total += v14 + 4
			record("string (u32 hdr)", v14 + 5) -- equivalent call inferred; original call site unknown
		elseif v13 == 13 then
			local v14 = buffer.readu32(buf3, total)
			total += v14 + 4
			record("buffer", v14 + 5) -- equivalent call inferred; original call site unknown
		elseif v13 == 14 then
			local v14 = buffer.readu32(buf3, total)
			total += v14 + 4
			record("Enum", v14 + 5) -- equivalent call inferred; original call site unknown
		elseif v13 == 15 then
			local v14 = buffer.readu32(buf3, total)
			total += v14 + 4 + 4
			record("EnumItem", v14 + 9) -- equivalent call inferred; original call site unknown
		elseif v13 == 16 then
			record("table (empty)", 1) -- equivalent call inferred; original call site unknown
		elseif v13 == 17 then
			local v14 = buffer.readu32(buf3, total)
			total += 4
			record("table (array hdr)", 5) -- equivalent call inferred; original call site unknown

			for _ = 1, v14 do
				walk()
			end
		elseif v13 == 21 then
			record("table (dict hdr)", 1) -- equivalent call inferred; original call site unknown

			while buffer.readu8(buf3, total) ~= 255 do
				walk()
				walk()
			end

			total += 1
			record("table (sentinel)", 1) -- equivalent call inferred; original call site unknown
		elseif v13 == 64 then
			record("Axes", 2) -- equivalent call inferred; original call site unknown
			total += 1
		elseif v13 == 65 then
			record("BrickColor", 3) -- equivalent call inferred; original call site unknown
			total += 2
		elseif v13 == 66 then
			record("CFrame", 49) -- equivalent call inferred; original call site unknown
			total += 48
		elseif v13 == 67 then
			record("Color3", 13) -- equivalent call inferred; original call site unknown
			total += 12
		elseif v13 == 68 then
			record("ColorSeqKeypoint", 17) -- equivalent call inferred; original call site unknown
			total += 16
		elseif v13 == 69 then
			local v14 = buffer.readu32(buf3, total)
			total += v14 * 16 + 4
			record("ColorSequence", v14 * 16 + 5) -- equivalent call inferred; original call site unknown
		elseif v13 == 70 then
			record("DateTime", 9) -- equivalent call inferred; original call site unknown
			total += 8
		elseif v13 == 71 then
			record("Faces", 2) -- equivalent call inferred; original call site unknown
			total += 1
		elseif v13 == 72 then
			local v14 = buffer.readu32(buf3, total)
			total += v14 + 4 + 8
			record("Font", v14 + 13) -- equivalent call inferred; original call site unknown
		elseif v13 == 73 then
			record("NumberRange", 9) -- equivalent call inferred; original call site unknown
			total += 8
		elseif v13 == 74 then
			record("NumSeqKeypoint", 13) -- equivalent call inferred; original call site unknown
			total += 12
		elseif v13 == 75 then
			local v14 = buffer.readu32(buf3, total)
			total += v14 * 12 + 4
			record("NumberSequence", v14 * 12 + 5) -- equivalent call inferred; original call site unknown
		elseif v13 == 76 then
			record("PhysicalProperties", 21) -- equivalent call inferred; original call site unknown
			total += 20
		elseif v13 == 77 then
			record("Ray", 25) -- equivalent call inferred; original call site unknown
			total += 24
		elseif v13 == 78 then
			record("Rect", 17) -- equivalent call inferred; original call site unknown
			total += 16
		elseif v13 == 79 then
			record("Region3", 25) -- equivalent call inferred; original call site unknown
			total += 24
		elseif v13 == 80 then
			record("Region3int16", 13) -- equivalent call inferred; original call site unknown
			total += 12
		elseif v13 == 81 then
			record("TweenInfo", 22) -- equivalent call inferred; original call site unknown
			total += 21
		elseif v13 == 82 then
			record("UDim", 9) -- equivalent call inferred; original call site unknown
			total += 8
		elseif v13 == 83 then
			record("UDim2", 17) -- equivalent call inferred; original call site unknown
			total += 16
		elseif v13 == 84 then
			record("Vector2", 9) -- equivalent call inferred; original call site unknown
			total += 8
		elseif v13 == 85 then
			record("Vector2int16", 5) -- equivalent call inferred; original call site unknown
			total += 4
		elseif v13 == 86 then
			record("Vector3", 13) -- equivalent call inferred; original call site unknown
			total += 12
		elseif v13 == 87 then
			record("Vector3int16", 7) -- equivalent call inferred; original call site unknown
			total += 6
		elseif v13 == 88 then
			record("PathWaypoint", 14) -- equivalent call inferred; original call site unknown
			total += 13
		elseif v13 == 89 then
			record("FloatCurveKey", 10) -- equivalent call inferred; original call site unknown
			total += 9
		elseif v13 == 90 then
			record("RotationCurveKey", 54) -- equivalent call inferred; original call site unknown
			total += 53
		elseif v13 == 91 then
			record("Path2DControlPoint", 49) -- equivalent call inferred; original call site unknown
			total += 48
		elseif v13 == 92 then
			record("Instance", 5) -- equivalent call inferred; original call site unknown
			total += 4
		else
			record(`unknown({v13})`, 1) -- equivalent call inferred; original call site unknown
		end
	end

	walk()
	local v13 = {}

	for k, bytes in v12 do
		table.insert(v13, {
			name = k,
			count = v11[k],
			bytes = bytes
		})
	end

	table.sort(v13, function(a, b)
		return a.bytes > b.bytes
	end)
	local v14 = { string.format("Total: %d bytes\n%-25s %8s %8s %6s", v10, "TYPE", "COUNT", "BYTES", "%") }
	table.insert(v14, (string.rep("-", 51)))

	for _, v15 in v13 do
		table.insert(v14, string.format("%-25s %8d %8d %5.1f%%", v15.name, v15.count, v15.bytes, v15.bytes / v10 * 100))
	end

	return table.concat(v14, "\n")
end

function v.reset()
	buf = buffer.create(256)
	v4 = 256
	v3 = 0
end

return table.freeze(v)