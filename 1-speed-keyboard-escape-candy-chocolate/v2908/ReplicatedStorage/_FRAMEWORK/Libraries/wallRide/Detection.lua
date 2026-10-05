local CollectionService = game:GetService("CollectionService")
require(script.Parent.Types)
local Detection = {}

local function findAttributeOwner(parent, attributeName: string, p: number)
	while parent ~= nil and parent ~= workspace and p >= 0 do
		if parent:GetAttribute(attributeName) ~= nil then
			return parent
		end

		parent = parent.Parent
		p -= 1
	end

	return nil
end

local function readNumber(p, attributeName: string, p2: number, p3: number)
	local attributeOwner = findAttributeOwner(p, attributeName, p2)
	local attribute

	if attributeOwner ~= nil then
		attribute = attributeOwner:GetAttribute(attributeName)
	end

	if typeof(attribute) == "number" then
		return attribute
	end

	return p3
end

local function readBoolean(p, attributeName: string, p2: number, flag: boolean)
	local attributeOwner = findAttributeOwner(p, attributeName, p2)
	local attribute

	if attributeOwner ~= nil then
		attribute = attributeOwner:GetAttribute(attributeName)
	end

	if typeof(attribute) == "boolean" then
		return attribute
	end

	return flag
end

local function hasTagInAncestry(parent, tagName: string, attributeSearchDepth: number)
	while parent ~= nil and parent ~= workspace and attributeSearchDepth >= 0 do
		if CollectionService:HasTag(parent, tagName) then
			return true
		end

		parent = parent.Parent
		attributeSearchDepth -= 1
	end

	return false
end

local function sideDirection(vector: Vector3, p, vector2: Vector3)
	local cross = vector:Cross(vector2)

	if p == "right" then
		return cross
	end

	return -cross
end

local function cast(vector: Vector3, vector2: Vector3, p, p2, p3: string)
	local raycastResult = workspace:Raycast(vector, vector2, p)
	local onProbe = p2.onProbe

	if onProbe ~= nil then
		onProbe(p3, vector, vector2, raycastResult)
	end

	return raycastResult
end

function Detection.buildParams(p)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { p }
	raycastParams.RespectCanCollide = true
	raycastParams.IgnoreWater = true
	return raycastParams
end

function Detection.isRideable(p, data, callback)
	local attributeNames = data.attributeNames
	local attributeOwner = findAttributeOwner(p, attributeNames.rideable, data.attributeSearchDepth)
	local attribute

	if attributeOwner ~= nil then
		attribute = attributeOwner:GetAttribute(attributeNames.rideable)
	end

	if callback ~= nil then
		return callback(p)
	end

	if typeof(attribute) == "boolean" then
		return attribute
	end

	return data.rideAll or hasTagInAncestry(p, data.tagName, data.attributeSearchDepth)
end

function Detection.isValidHit(raycastResult: RaycastResult, vector: Vector3, data, callback)
	local instance = raycastResult.Instance

	if not (instance:IsA("BasePart") and instance.CanCollide) then
		return false
	end

	local maxAngle = data.attributeNames.maxAngle
	local attributeSearchDepth = data.attributeSearchDepth
	local maxSurfaceAngle = data.maxSurfaceAngle
	local attributeOwner = findAttributeOwner(instance, maxAngle, attributeSearchDepth)
	local attribute

	if attributeOwner ~= nil then
		attribute = attributeOwner:GetAttribute(maxAngle)
	end

	if typeof(attribute) == "number" then
		maxSurfaceAngle = attribute
	end

	local v = math.min(maxSurfaceAngle, 60)
	return math.abs((raycastResult.Normal:Dot(vector))) <= math.sin((math.rad(v))) and Detection.isRideable(
		instance,
		data,
		callback
	)
end

function Detection.describeSurface(raycastResult: RaycastResult, side, p2)
	local instance = raycastResult.Instance
	local attributeNames = p2.attributeNames
	local attributeSearchDepth = p2.attributeSearchDepth
	local v = {
		part = instance,
		normal = raycastResult.Normal,
		position = raycastResult.Position,
		distance = raycastResult.Distance,
		side = side,
		speedMultiplier = 0,
		slideMultiplier = 0,
		jumpMultiplier = 0,
		maxDuration = 0,
		noJump = 0
	}
	local speedMultiplier = attributeNames.speedMultiplier
	local attributeOwner = findAttributeOwner(instance, speedMultiplier, attributeSearchDepth)
	local attribute

	if attributeOwner ~= nil then
		attribute = attributeOwner:GetAttribute(speedMultiplier)
	end

	v.speedMultiplier = typeof(attribute) ~= "number" and 1 or attribute
	local slideMultiplier = attributeNames.slideMultiplier
	local attributeOwner2 = findAttributeOwner(instance, slideMultiplier, attributeSearchDepth)
	local attribute2

	if attributeOwner2 ~= nil then
		attribute2 = attributeOwner2:GetAttribute(slideMultiplier)
	end

	v.slideMultiplier = typeof(attribute2) ~= "number" and 1 or attribute2
	local jumpMultiplier = attributeNames.jumpMultiplier
	local attributeOwner3 = findAttributeOwner(instance, jumpMultiplier, attributeSearchDepth)
	local attribute3

	if attributeOwner3 ~= nil then
		attribute3 = attributeOwner3:GetAttribute(jumpMultiplier)
	end

	v.jumpMultiplier = typeof(attribute3) ~= "number" and 1 or attribute3
	local maxDuration = attributeNames.maxDuration
	local attributeOwner4 = findAttributeOwner(instance, maxDuration, attributeSearchDepth)
	local attribute4

	if attributeOwner4 ~= nil then
		attribute4 = attributeOwner4:GetAttribute(maxDuration)
	end

	v.maxDuration = typeof(attribute4) ~= "number" and 0 or attribute4
	local noJump = attributeNames.noJump
	local attributeOwner5 = findAttributeOwner(instance, noJump, attributeSearchDepth)
	local attribute5

	if attributeOwner5 ~= nil then
		attribute5 = attributeOwner5:GetAttribute(noJump)
	end

	if typeof(attribute5) ~= "boolean" then
		attribute5 = false
	end

	v.noJump = attribute5
	return v
end

function Detection.findSideWall(vector: Vector3, vector2: Vector3, p, vector3: Vector3, data, p2, callback)
	local cross = vector2:Cross(vector3)

	if p ~= "right" then
		cross = -cross
	end

	local v = cross * data.probeDistance
	local v2 = nil

	for k, probeHeight in data.probeHeights do
		local v3 = vector + vector3 * probeHeight
		local formatted = `{p}:{k}`
		local raycastResult = workspace:Raycast(v3, v, p2)
		local onProbe = data.onProbe

		if onProbe ~= nil then
			onProbe(formatted, v3, v, raycastResult)
		end

		if not (raycastResult ~= nil and Detection.isValidHit(raycastResult, vector3, data, callback) and (v2 == nil or raycastResult.Distance < v2.Distance)) then
			continue
		end

		v2 = raycastResult
	end

	if v2 == nil then
		return nil
	end

	return (Detection.describeSurface(v2, p, data))
end

function Detection.findWall(vector: Vector3, vector2: Vector3, vector3: Vector3, p, p2, callback)
	local sideWall = Detection.findSideWall(vector, vector2, "left", vector3, p, p2, callback)
	local sideWall2 = Detection.findSideWall(vector, vector2, "right", vector3, p, p2, callback)

	if sideWall == nil or sideWall2 == nil then
		if sideWall == nil then
			return sideWall2
		end

		return sideWall
	elseif sideWall2.distance < sideWall.distance then
		return sideWall2
	else
		return sideWall
	end
end

function Detection.hasGround(vector: Vector3, vector2: Vector3, p, p2)
	local v = -vector2 * p.groundProbeDistance
	local raycastResult = workspace:Raycast(vector, v, p2)
	local onProbe = p.onProbe

	if onProbe ~= nil then
		onProbe("ground", vector, v, raycastResult)
	end

	return raycastResult ~= nil
end

return Detection