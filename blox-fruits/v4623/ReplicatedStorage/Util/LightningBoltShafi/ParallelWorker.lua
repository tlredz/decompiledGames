local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local actor = script:GetActor()

if actor == nil then
	return
end

local lightningBoltShafi = ReplicatedStorage.Util.LightningBoltShafi
local Geometry = require(lightningBoltShafi.Geometry)
local request = actor:WaitForChild("Request")
local result = actor:WaitForChild("Result")
local ready = actor:WaitForChild("Ready")
local inverse = CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):Inverse()

local function loadRigData(childName: string)
	local meshPart = lightningBoltShafi:FindFirstChild(childName)

	if meshPart == nil then
		return nil
	end

	if not meshPart:IsA("MeshPart") then
		meshPart = meshPart:FindFirstChildWhichIsA("MeshPart", true)
	end

	if meshPart == nil then
		return nil
	end

	local bones = table.create(40)
	local bones2 = table.create(40)
	local ringCount = 0

	for _, bone in meshPart:GetDescendants() do
		if not bone:IsA("Bone") then
			continue
		end

		local v2, v3 = string.match(bone.Name, "^R(%d+)([AB])$")
		local v4

		if v2 ~= nil then
			v4 = tonumber(v2)
		end

		if v4 == nil then
			continue
		end

		ringCount = math.max(ringCount, v4)

		if v3 == "A" then
			bones[v4] = bone
		else
			bones2[v4] = bone
		end
	end

	local v2 = bones[1]
	local v3 = bones[ringCount]

	if ringCount < 3 or v2 == nil or v3 == nil then
		return nil
	end

	local cFrame = meshPart.CFrame
	local unit = (cFrame:ToObjectSpace(v3.WorldCFrame).Position - cFrame:ToObjectSpace(v2.WorldCFrame).Position).Unit
	local rotations = table.create(ringCount)
	local rotations2 = table.create(ringCount)
	local inverses = table.create(ringCount)
	local inverses2 = table.create(ringCount)

	for i = 1, ringCount do
		local v4 = bones[i]
		local v5 = bones2[i]

		if v4 == nil or v5 == nil then
			return nil
		end

		local cframe = cFrame:ToObjectSpace(v4.WorldCFrame)
		local cframe2 = cFrame:ToObjectSpace(v5.WorldCFrame)
		local rotation = cframe.Rotation
		local inverse2 = cframe:Inverse()
		rotations[i] = rotation
		inverses[i] = inverse2
		local rotation2 = cframe2.Rotation
		local inverse3 = cframe2:Inverse()
		rotations2[i] = rotation2
		inverses2[i] = inverse3
	end

	local v4 = math.abs(unit.Y) > 0.99 and createVector(0, 0, 1) or createVector(0, 1, 0)
	return {
		RingCount = ringCount,
		RigAxis = unit,
		RigAlign = (CFrame.lookAt(createVector(0, 0, 0), unit, v4) * inverse):Inverse(),
		BindRotA = rotations,
		BindRotB = rotations2,
		BindInverseA = inverses,
		BindInverseB = inverses2
	}
end

local v = {
	BoltMesh12 = loadRigData("BoltMesh12"),
	BoltMesh40 = loadRigData("BoltMesh40")
}
request.Event:ConnectParallel(function(p: number, list)
	local success, result2 = pcall(function()
		local result3 = table.create(#list)

		for i = 1, #list do
			local v2 = list[i]
			local v3 = v[v2.TemplateName]

			if v3 == nil then
				error("missing rig data for " .. tostring(v2.TemplateName))
			end

			result3[i] = Geometry.computeMesh(v2, v3)
		end

		return result3
	end)

	if success then
		result:Fire(p, result2)
	else
		result:Fire(p, nil, (tostring(result2)))
	end
end)
ready:Fire()