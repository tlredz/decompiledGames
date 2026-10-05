local ReplicatedStorage = game:GetService("ReplicatedStorage")
local QuaternionUtil = require(ReplicatedStorage.Modules.Shared.Utils.QuaternionUtil)
local BufferUtil = require(ReplicatedStorage.Packages.BufferUtil)
local v = {
	"Root",
	"Waist",
	"Neck",
	"LeftShoulder",
	"LeftElbow",
	"LeftWrist",
	"RightShoulder",
	"RightElbow",
	"RightWrist",
	"LeftHip",
	"LeftKnee",
	"LeftAnkle",
	"RightHip",
	"RightKnee",
	"RightAnkle"
}
local v2 = #v + 1
local CharacterStateSerializer = {
	JOINT_ORDER = v,
	TRANSFORM_COUNT = v2,
	BUFFER_SIZE = 130,
	POSITION_LIMIT = 4096,
	VELOCITY_LIMIT = 4096,
	OFFSET_LIMIT = 8
}
local result = {
	offsetClamps = 0,
	peakPositionComponent = 0,
	peakVelocityComponent = 0,
	peakOffsetComponent = 0,
	peakOffsetJoint = nil
}

function CharacterStateSerializer.getQuantisationStats()
	return result
end

function CharacterStateSerializer.resetQuantisationStats()
	result.offsetClamps = 0
	result.peakPositionComponent = 0
	result.peakVelocityComponent = 0
	result.peakOffsetComponent = 0
	result.peakOffsetJoint = nil
end

local function quantise(p: number, p2: number, p3: number, p4: number)
	local v3 = math.round(p * p2)

	if v3 < p3 then
		return p3, true
	end

	if p4 < v3 then
		return p4, true
	end

	return v3, false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function peakComponent(position: Vector3)
	return (math.max(math.abs(position.X), math.abs(position.Y), (math.abs(position.Z))))
end

local function quantizeComponent(p: number)
	return (math.clamp(math.floor((p / 0.7071067811865476 * 0.5 + 0.5) * 1023 + 0.5), 0, 1023))
end

local function dequantizeComponent(p: number)
	return (p / 1023 - 0.5) * 2 * 0.7071067811865476
end

local function writeRotation(object, cframe: CFrame)
	local encoded = QuaternionUtil.encode(cframe)
	object:WriteUInt32((bit32.bor(
		encoded.maxIdx,
		bit32.lshift(math.clamp(math.floor((encoded.a / 0.7071067811865476 * 0.5 + 0.5) * 1023 + 0.5), 0, 1023), 2),
		bit32.lshift(math.clamp(math.floor((encoded.b / 0.7071067811865476 * 0.5 + 0.5) * 1023 + 0.5), 0, 1023), 12),
		(bit32.lshift(math.clamp(math.floor((encoded.c / 0.7071067811865476 * 0.5 + 0.5) * 1023 + 0.5), 0, 1023), 22))
	)))
end

local function readRotation(object)
	local uInt32 = object:ReadUInt32()
	local v3 = bit32.band(uInt32, 3)
	local v4 = (bit32.band(bit32.rshift(uInt32, 2), 1023) / 1023 - 0.5) * 2 * 0.7071067811865476
	local v5 = (bit32.band(bit32.rshift(uInt32, 12), 1023) / 1023 - 0.5) * 2 * 0.7071067811865476
	local v6 = (bit32.band(bit32.rshift(uInt32, 22), 1023) / 1023 - 0.5) * 2 * 0.7071067811865476
	return QuaternionUtil.decode(v3, v4, v5, v6)
end

function CharacterStateSerializer.getJoints(folder)
	local animationConstraintsByName = {}

	for _, animationConstraint in folder:GetDescendants() do
		if animationConstraint:IsA("AnimationConstraint") then
			animationConstraintsByName[animationConstraint.Name] = animationConstraint
		end
	end

	for _, v3 in v do
		if animationConstraintsByName[v3] == nil then
			return nil
		end
	end

	return animationConstraintsByName
end

function CharacterStateSerializer.serialize(p: number, p2: number, instance, p3)
	local writer = BufferUtil.writer(130)
	writer:WriteUInt32(p % 4294967296)
	writer:WriteUInt8((math.floor(p / 4294967296)))
	writer:WriteUInt32((math.round(p2 * 1000)))
	local v3 = table.create(v2)
	v3[1] = instance.CFrame

	for k, v4 in v do
		v3[k + 1] = p3[v4].Transform
	end

	local position = v3[1].Position
	result.peakPositionComponent = math.max(
		result.peakPositionComponent,
		(math.max(math.abs(position.X), math.abs(position.Y), (math.abs(position.Z))))
	)
	writer:WriteUInt16(quantise(position.X + 4096, 8, 0, 65535))
	writer:WriteUInt16(quantise(position.Y + 4096, 8, 0, 65535))
	writer:WriteUInt16(quantise(position.Z + 4096, 8, 0, 65535))
	local assemblyLinearVelocity = instance.AssemblyLinearVelocity
	result.peakVelocityComponent = math.max(
		result.peakVelocityComponent,
		(math.max(
			math.abs(assemblyLinearVelocity.X),
			math.abs(assemblyLinearVelocity.Y),
			(math.abs(assemblyLinearVelocity.Z))
		))
	)
	writer:WriteInt16(quantise(assemblyLinearVelocity.X, 8, -32768, 32767))
	writer:WriteInt16(quantise(assemblyLinearVelocity.Y, 8, -32768, 32767))
	writer:WriteInt16(quantise(assemblyLinearVelocity.Z, 8, -32768, 32767))

	for i = 1, v2 do
		writeRotation(writer, v3[i])
	end

	for i = 2, v2 do
		local position2 = v3[i].Position
		local v4 = math.round(position2.X * 16)
		local v5

		if v4 < -128 then
			v5 = true
			v4 = -128
		elseif v4 > 127 then
			v5 = true
			v4 = 127
		else
			v5 = false
		end

		local v6 = math.round(position2.Y * 16)
		local v7

		if v6 < -128 then
			v7 = true
			v6 = -128
		elseif v6 > 127 then
			v7 = true
			v6 = 127
		else
			v7 = false
		end

		local v8 = math.round(position2.Z * 16)
		local v9

		if v8 < -128 then
			v8 = -128
			v9 = true
		elseif v8 > 127 then
			v8 = 127
			v9 = true
		else
			v9 = false
		end

		if v5 or v7 or v9 then
			result.offsetClamps += 1
		end

		local peakOffsetComponent = peakComponent(position2) -- equivalent call inferred; original call site unknown

		if result.peakOffsetComponent < peakOffsetComponent then
			result.peakOffsetComponent = peakOffsetComponent
			result.peakOffsetJoint = v[i - 1]
		end

		writer:WriteInt8(v4)
		writer:WriteInt8(v6)
		writer:WriteInt8(v8)
	end

	return writer:GetBuffer()
end

function CharacterStateSerializer.deserialize(buf: buffer)
	local reader = BufferUtil.reader(buf)
	local uInt32 = reader:ReadUInt32()
	local uInt8 = reader:ReadUInt8()
	local uInt322 = reader:ReadUInt32()
	local vectors = table.create(v2)
	local rotations = table.create(v2 * 4)
	vectors[1] = Vector3.new(
		reader:ReadUInt16() / 8 - 4096,
		reader:ReadUInt16() / 8 - 4096,
		reader:ReadUInt16() / 8 - 4096
	)
	local v4 = reader:ReadInt16() / 8
	local v5 = reader:ReadInt16() / 8
	local v6 = reader:ReadInt16() / 8

	for i = 1, v2 do
		local v7, v8, v9, v10 = readRotation(reader)
		local v11 = (i - 1) * 4
		rotations[v11 + 1] = v7
		rotations[v11 + 2] = v8
		rotations[v11 + 3] = v9
		rotations[v11 + 4] = v10
	end

	for i = 2, v2 do
		vectors[i] = Vector3.new(reader:ReadInt8() / 16, reader:ReadInt8() / 16, reader:ReadInt8() / 16)
	end

	return {
		userId = uInt8 * 4294967296 + uInt32,
		sampleTime = uInt322 / 1000,
		positions = vectors,
		rotations = rotations,
		rootVelocity = Vector3.new(v4, v5, v6)
	}
end

function CharacterStateSerializer.apply(p, p2, p3, vector: Vector3)
	local positions = p.positions
	local rotations = p.rotations
	local v3 = positions[1] + vector
	p2.CFrame = CFrame.new(v3.X, v3.Y, v3.Z, rotations[1], rotations[2], rotations[3], rotations[4])

	for k, v4 in v do
		local position = positions[k + 1]
		local v5 = k * 4
		p3[v4].Transform = CFrame.new(
			position.X,
			position.Y,
			position.Z,
			rotations[v5 + 1],
			rotations[v5 + 2],
			rotations[v5 + 3],
			rotations[v5 + 4]
		)
	end
end

return CharacterStateSerializer