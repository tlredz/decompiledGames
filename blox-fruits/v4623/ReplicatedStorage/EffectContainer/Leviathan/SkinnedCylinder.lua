local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local skinnedPrimitives = FX:WaitForChild("Leviathan").SkinnedPrimitives
local cylinder = skinnedPrimitives:WaitForChild("Cylinder")
local cylinderDoubleSided = skinnedPrimitives:WaitForChild("CylinderDoubleSided")
local Array2D = require(script.Array2D)
local SkinnedCylinder = {}
SkinnedCylinder.__index = SkinnedCylinder
local Players = game:GetService("Players")
local v = {}
local cframe = CFrame.new(0, 1000000000, 0)

local function pushCache(p, p2)
	local v2 = v[p]

	if v2 == nil then
		v[p] = {}
		v2 = v[p]
	end

	if #v2 >= 0 or p2.cylinderPart.Parent == nil then
		return false
	end

	table.insert(v2, p2)
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popCache(castingPlayer)
	local v2 = v[castingPlayer]

	if v2 and #v2 > 0 then
		return (table.remove(v2, #v2))
	end

	return nil
end

Players.PlayerRemoving:Connect(function(player)
	local v2 = v[player]

	if v2 then
		for _, v3 in pairs(v2) do
			v3:_forceDestroy()
		end

		v[player] = nil
	end
end)

function SkinnedCylinder.new(parent, cFrame: CFrame, vector: Vector3, castingPlayer, flag: boolean?)
	local v2 = vector or cylinder.Size
	local v3 = popCache(castingPlayer) -- equivalent call inferred; original call site unknown

	if v3 == nil then
		v3 = setmetatable({}, SkinnedCylinder)
	end

	v3.castingPlayer = castingPlayer

	if v3.cylinderPart == nil then
		local cylinderPart

		if flag then
			cylinderPart = cylinderDoubleSided:Clone()
		else
			cylinderPart = cylinder:Clone()
		end

		v3.cylinderPart = cylinderPart
	end

	v3.sizeMultiplier = v2 / v3.cylinderPart.Size

	if v3.boneInstanceMap == nil then
		v3.boneInstanceMap = v3:_genBoneInstanceMap(v3.cylinderPart)
	end

	v3.defaultBonePosMap = v3:_genDefaultBonePosMap(v3.boneInstanceMap)
	v3.cylinderPart.CFrame = cFrame
	v3.cylinderPart.Transparency = 1
	v3.cylinderPart.Name = "SkinnedCylinderCastBy" .. castingPlayer.Name

	if v3.cylinderPart.Parent ~= parent then
		v3.cylinderPart.Parent = parent
	end

	return v3
end

function SkinnedCylinder:_forceDestroy()
	if self.cylinderPart and self.cylinderPart.Parent ~= nil then
		self.cylinderPart:Destroy()
	end
end

function SkinnedCylinder:destroy()
	local castingPlayer = self.castingPlayer
	local v2 = v[castingPlayer]

	if v2 == nil then
		v[castingPlayer] = {}
		v2 = v[castingPlayer]
	end

	local v3

	if #v2 >= 0 or self.cylinderPart.Parent == nil then
		v3 = false
	else
		table.insert(v2, self)
		v3 = true
	end

	if v3 == false then
		self:_forceDestroy()
		return
	end

	self.cylinderPart.CFrame = cframe

	for _, bone in ipairs(self.cylinderPart:GetChildren()) do
		if bone:IsA("Bone") then
			bone.Position = cylinder[bone.Name].Position
		else
			bone:Destroy()
		end
	end
end

function SkinnedCylinder:_genBoneInstanceMap(instance)
	local children = instance:GetChildren()
	local count = 0

	for _ = 1, #children, 12 do
		count += 1
	end

	local v2 = Array2D.new(12, count)

	for _, v3 in ipairs(children) do
		local v4 = math.floor((v3.Position.Y + 40.5) / 2) + 1
		v2:set(
			math.floor(0.5 + (math.atan2(v3.Position.Z, v3.Position.X) - 1.5707963267948966) / 0.5235987755982988) % 12 + 1,
			v4,
			v3
		)
	end

	for i = 1, v2.maxY do
		for i2 = 1, v2.maxX do
			if v2:get(i2, i) ~= nil then
				continue
			end

			warn("The faulty map is ", v2)
			error("SkinnedCylinder._genBoneInstanceMap: Failed to fully populate a map of all bone instances")
		end
	end

	return v2
end

function SkinnedCylinder:_genDefaultBonePosMap(object)
	local v2 = Array2D.new(object.maxX, object.maxY)
	local sizeMultiplier = self.sizeMultiplier

	for i = 1, v2.maxY do
		for i2 = 1, v2.maxX do
			v2:set(i2, i, object:get(i2, i).CFrame.Position * sizeMultiplier)
		end
	end

	return v2
end

SkinnedCylinder.VERSION = 1.1
return SkinnedCylinder