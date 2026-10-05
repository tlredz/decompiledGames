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

-- equivalent calls inferred from this helper; original call sites unknown
local function rotateAroundAxis(vector: Vector3, vector2: Vector3, p: number)
	return CFrame.fromAxisAngle(vector2, (math.rad(p))) * vector
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

function Detection.isClimbable(p, data, callback)
	local attributeNames = data.attributeNames
	local attributeOwner = findAttributeOwner(p, attributeNames.climbable, data.attributeSearchDepth)
	local attribute

	if attributeOwner ~= nil then
		attribute = attributeOwner:GetAttribute(attributeNames.climbable)
	end

	if callback ~= nil then
		return callback(p)
	end

	if typeof(attribute) == "boolean" then
		return attribute
	end

	return data.climbAll or hasTagInAncestry(p, data.tagName, data.attributeSearchDepth)
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
	return math.abs((raycastResult.Normal:Dot(vector))) <= math.sin((math.rad(v))) and Detection.isClimbable(
		instance,
		data,
		callback
	)
end

function Detection.describeSurface(raycastResult: RaycastResult, p)
	local instance = raycastResult.Instance
	local attributeNames = p.attributeNames
	local attributeSearchDepth = p.attributeSearchDepth
	local v = {
		part = instance,
		normal = raycastResult.Normal,
		position = raycastResult.Position,
		distance = raycastResult.Distance,
		height = 0,
		boostMultiplier = 0,
		noBoost = 0
	}
	local boostMultiplier = attributeNames.boostMultiplier
	local attributeOwner = findAttributeOwner(instance, boostMultiplier, attributeSearchDepth)
	local attribute

	if attributeOwner ~= nil then
		attribute = attributeOwner:GetAttribute(boostMultiplier)
	end

	v.boostMultiplier = typeof(attribute) ~= "number" and 1 or attribute
	local noBoost = attributeNames.noBoost
	local attributeOwner2 = findAttributeOwner(instance, noBoost, attributeSearchDepth)
	local attribute2

	if attributeOwner2 ~= nil then
		attribute2 = attributeOwner2:GetAttribute(noBoost)
	end

	if typeof(attribute2) ~= "boolean" then
		attribute2 = false
	end

	v.noBoost = attribute2
	return v
end

function Detection.measureHeight(p, vector: Vector3, data, p2, callback)
	local v = p.position + p.normal * data.heightProbeOffset
	local v2 = -p.normal * (data.heightProbeOffset * 2)
	local v3 = 0
	local maxWallHeight = data.maxWallHeight
	local v4 = v + vector * maxWallHeight
	local raycastResult = workspace:Raycast(v4, v2, p2)
	local onProbe = data.onProbe

	if onProbe ~= nil then
		onProbe("height:ceiling", v4, v2, raycastResult)
	end

	if raycastResult ~= nil and Detection.isValidHit(raycastResult, vector, data, callback) then
		return maxWallHeight
	end

	for i = 1, data.heightSteps do
		local v5 = (v3 + maxWallHeight) * 0.5
		local v6 = v + vector * v5
		local formatted = `height:{i}`
		local raycastResult2 = workspace:Raycast(v6, v2, p2)
		local onProbe2 = data.onProbe

		if onProbe2 ~= nil then
			onProbe2(formatted, v6, v2, raycastResult2)
		end

		if raycastResult2 == nil or not Detection.isValidHit(raycastResult2, vector, data, callback) then
			maxWallHeight = v5
		else
			v3 = v5
		end
	end

	return v3
end

function Detection.findWall(vector: Vector3, vector2: Vector3, vector3: Vector3, data, p, callback)
	local v = 1e999
	local v2 = nil

	for k, probeAngle in data.probeAngles do
		local v3 = rotateAroundAxis(vector2, vector3, probeAngle) * data.probeDistance

		for k2, probeHeight in data.probeHeights do
			local v4 = vector + vector3 * probeHeight
			local formatted = `fan:{k}:{k2}`
			local raycastResult = workspace:Raycast(v4, v3, p)
			local onProbe = data.onProbe

			if onProbe ~= nil then
				onProbe(formatted, v4, v3, raycastResult)
			end

			if not (raycastResult ~= nil and Detection.isValidHit(raycastResult, vector3, data, callback)) then
				continue
			end

			local v5 = math.abs(probeAngle) * 1000 + raycastResult.Distance

			if not (v5 < v) then
				continue
			end

			v2 = raycastResult
			v = v5
		end
	end

	if v2 == nil then
		return nil
	end

	local describeSurface = Detection.describeSurface(v2, data)
	describeSurface.height = Detection.measureHeight(describeSurface, vector3, data, p, callback)
	return describeSurface
end

function Detection.findImpact(vector: Vector3, vector2: Vector3, p: number, vector3: Vector3, p2, p3, callback)
	local v = vector2 * p
	local raycastResult = workspace:Raycast(vector, v, p3)
	local onProbe = p2.onProbe

	if onProbe ~= nil then
		onProbe("impact", vector, v, raycastResult)
	end

	if raycastResult == nil or not Detection.isValidHit(raycastResult, vector3, p2, callback) then
		return nil
	end

	return (Detection.describeSurface(raycastResult, p2))
end

return Detection