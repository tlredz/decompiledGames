local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local GravityController = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.GravityController)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local v = {
	X = createVector(1, 0, 0),
	Y = createVector(0, 1, 0),
	Z = createVector(0, 0, 1)
}
local v2 = {
	Left = Vector3.FromNormalId(Enum.NormalId.Left),
	Right = Vector3.FromNormalId(Enum.NormalId.Right),
	Bottom = Vector3.FromNormalId(Enum.NormalId.Bottom),
	Top = Vector3.FromNormalId(Enum.NormalId.Top),
	Back = Vector3.FromNormalId(Enum.NormalId.Back),
	Front = Vector3.FromNormalId(Enum.NormalId.Front)
}
local GravityZone = {}
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.RespectCanCollide = false
raycastParams.IgnoreWater = true
local parts = {}
local flag = false
local instance = nil
local v3 = nil
local v4 = 0
local v5 = nil
local v6 = nil

local function reportProbe(p: string, vector2: Vector3, vector3: Vector3, raycastResult: RaycastResult?)
	local v7 = v5

	if v7 ~= nil then
		v7(p, vector2, vector3, raycastResult)
	end
end

local function refreshTaggedParts()
	table.clear(parts)

	for _, part in CollectionService:GetTagged("GravityZone") do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	raycastParams.FilterDescendantsInstances = parts
	flag = false
end

local function validatePresets(part)
	local gravitySide = part:GetAttribute("GravitySide")
	local gravityAxis = part:GetAttribute("GravityAxis")

	if gravitySide ~= nil and gravitySide ~= "Inside" and gravitySide ~= "Outside" then
		logger:warn(
			"GravitySide attribute is neither \"Inside\" nor \"Outside\", every surface counts:",
			part:GetFullName(),
			gravitySide
		)
	end

	if gravityAxis ~= nil and (typeof(gravityAxis) ~= "string" or v[gravityAxis] == nil) then
		logger:warn(
			"GravityAxis attribute is not \"X\", \"Y\" or \"Z\", the part's centre is used:",
			part:GetFullName(),
			gravityAxis
		)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onTagAdded(part)
	flag = true

	if part:IsA("BasePart") then
		validatePresets(part)
	else
		logger:warn("tagged instance is not a BasePart, skipping", part:GetFullName(), part.ClassName)
	end
end

local function towardReference(instance2, position: Vector3)
	local vector2 = instance2.Position - position
	local gravityAxis = instance2:GetAttribute("GravityAxis")
	local v7

	if typeof(gravityAxis) == "string" then
		v7 = v[gravityAxis]
	end

	if v7 == nil then
		return vector2
	end

	local vectorToWorldSpace = instance2.CFrame:VectorToWorldSpace(v7)
	return vector2 - vectorToWorldSpace * vector2:Dot(vectorToWorldSpace)
end

local function isOnAllowedSide(raycastResult: RaycastResult)
	local instance2 = raycastResult.Instance
	local gravitySide = instance2:GetAttribute("GravitySide")

	if gravitySide ~= "Inside" and gravitySide ~= "Outside" then
		return true
	end

	local v7 = towardReference(instance2, raycastResult.Position)
	local v8 = not (v7.Magnitude > 0) and 0 or raycastResult.Normal:Dot(v7.Unit)

	if gravitySide == "Inside" then
		return v8 >= 0.3
	end

	return v8 <= -0.3
end

local function acceptSurface(raycastResult: RaycastResult?)
	if raycastResult == nil or not isOnAllowedSide(raycastResult) then
		return nil
	end

	return raycastResult
end

local function resolveNormal(raycastResult: RaycastResult)
	local instance2 = raycastResult.Instance
	local restrictedToFace = instance2:GetAttribute("RestrictedToFace")

	if typeof(restrictedToFace) ~= "string" then
		return raycastResult.Normal
	end

	local v7 = v2[restrictedToFace]

	if v7 ~= nil then
		return instance2.CFrame:VectorToWorldSpace(v7)
	end

	logger:warn("RestrictedToFace attribute is not a valid face name:", instance2:GetFullName(), restrictedToFace)
	return raycastResult.Normal
end

local function castProbe(p: string, vector2: Vector3, vector3: Vector3)
	local raycastResult = workspace:Raycast(vector2, vector3, raycastParams)
	local v7 = v5

	if v7 ~= nil then
		v7(p, vector2, vector3, raycastResult)
	end

	return raycastResult
end

local function probeSurface(position: Vector3, up: Vector3, lookVector: Vector3)
	local v7 = lookVector * 3
	local raycastResult = workspace:Raycast(position, v7, raycastParams)
	local v8 = v5

	if v8 ~= nil then
		v8("zoneForward", position, v7, raycastResult)
	end

	local v9 = -up * 8
	local raycastResult2 = workspace:Raycast(position, v9, raycastParams)
	local v10 = v5

	if v10 ~= nil then
		v10("zoneDown", position, v9, raycastResult2)
	end

	local v11 = (lookVector - up).Unit * 8
	local raycastResult3 = workspace:Raycast(position, v11, raycastParams)
	local v12 = v5

	if v12 ~= nil then
		v12("zoneAhead", position, v11, raycastResult3)
	end

	if raycastResult == nil or not isOnAllowedSide(raycastResult) then
		raycastResult = nil
	end

	if raycastResult then
		raycastResult2 = raycastResult
		return raycastResult2
	end

	if raycastResult2 == nil or not isOnAllowedSide(raycastResult2) then
		raycastResult2 = nil
	end

	if raycastResult2 then
		return raycastResult2
	end

	if raycastResult3 ~= nil and isOnAllowedSide(raycastResult3) then
		return raycastResult3
	end

	raycastResult2 = nil
	return raycastResult2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearSource()
	instance = nil
	v3 = nil
	GravityController.setSource("GravityZone", nil, 0)
end

local function forgetZone()
	v4 = 0
	clearSource() -- equivalent call inferred; original call site unknown
end

local function onTagRemoved(p)
	flag = true

	if p == instance then
		clearSource() -- equivalent call inferred; original call site unknown
	end
end

local function resolveActiveZone()
	if flag then
		refreshTaggedParts()
	end

	local rootPart = GravityController.getRootPart()

	if rootPart == nil or #parts == 0 then
		clearSource() -- equivalent call inferred; original call site unknown
	else
		local up = GravityController.getUp()
		local v7 = probeSurface(rootPart.Position, up, rootPart.CFrame.LookVector)
		local now = os.clock()

		if v7 == nil then
			if not GravityController.isAirborne() and now - v4 > 0.35 then
				clearSource() -- equivalent call inferred; original call site unknown
			end
		else
			instance = v7.Instance
			v3 = resolveNormal(v7)
			v4 = now
		end

		if v3 ~= nil then
			GravityController.setSource("GravityZone", v3, 0)
		end
	end
end

local function startClient()
	for _, v7 in CollectionService:GetTagged("GravityZone") do
		onTagAdded(v7) -- equivalent call inferred; original call site unknown
	end

	refreshTaggedParts()
	local maid = Janitor.new()
	v6 = maid
	maid:Add(CollectionService:GetInstanceAddedSignal("GravityZone"):Connect(onTagAdded))
	maid:Add(CollectionService:GetInstanceRemovedSignal("GravityZone"):Connect(onTagRemoved))
	maid:Add(GravityController.onReset:Connect(forgetZone))
	logger:info("GravityZone client feature started,", #parts, "tagged parts")
end

function GravityZone.getActivePart()
	return instance
end

function GravityZone.getTaggedCount()
	return #parts
end

function GravityZone.setProbeListener(callback)
	v5 = callback
end

FeatureManager.RegisterFeature(script.Name, {
	Priority = -1,
	OnInit = function()
		if Common.IsClient() then
			startClient()
		end
	end,
	OnRender = function()
		if Common.IsClient() then
			resolveActiveZone()
		end
	end
})
return GravityZone