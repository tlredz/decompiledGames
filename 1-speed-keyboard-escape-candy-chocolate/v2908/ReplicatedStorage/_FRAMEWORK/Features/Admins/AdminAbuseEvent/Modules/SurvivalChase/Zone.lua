local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.Config)
require(script.Parent.Types)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local SpacialQuery = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.SpacialQuery)
local logger = LoggerManager.createLogger("SurvivalChase.Zone", {
	feature = script:GetFullName()
})
local formatted = `{Config.chaserArchetypeId}Bounds`

local function createZonePart(p, folder)
	local part = Instance.new("Part")
	part.Name = "ZonePart"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = Config.zoneDebugVisible and 0.7 or 1
	part.Color = Color3.fromRGB(255, 80, 80)
	part.Size = p.size
	part.CFrame = p.cframe
	part.Parent = folder
end

local function createZoneFolder(parent, name: string, items)
	local folder = Instance.new("Folder")
	folder.Name = name

	for _, item in items do
		createZonePart(item, folder)
	end

	folder.Parent = parent
	return folder
end

local function findRigGroundY(ancestor, filterDescendantsInstances)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.RespectCanCollide = true

	for _, filterDescendantsInstance in filterDescendantsInstances do
		local v = Config.floorDetectDepthStuds * filterDescendantsInstance:GetScale()
		local raycastResult = Workspace:Raycast(
			filterDescendantsInstance:GetPivot().Position,
			Vector3.new(0, -v, 0),
			raycastParams
		)

		if raycastResult and raycastResult.Instance:IsDescendantOf(ancestor) then
			return raycastResult.Position.Y
		end
	end

	return nil
end

local function collectFloorBoxes(folder, rigGroundY: number)
	local result = {}

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.CanCollide and math.abs(part.Position.Y + part.Size.Y / 2 - rigGroundY) <= Config.floorLevelToleranceStuds) then
			continue
		end

		table.insert(result, {
			cframe = part.CFrame * CFrame.new(
				0,
				part.Size.Y / 2 + Config.zoneHeightStuds / 2 - Config.floorLevelToleranceStuds,
				0
			),
			size = Vector3.new(part.Size.X, Config.zoneHeightStuds, part.Size.Z)
		})
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function collectMapBoundsBoxes(instance)
	local boundingBox, size = instance:GetBoundingBox()
	return {
		{
			cframe = boundingBox,
			size = size
		}
	}
end

local function normalizeZoneBoxHeight(part)
	local v = part.Size.Y / 2
	local v2 = -v - Config.zoneExtendDownStuds
	local v3 = math.max(v, v2 + Config.zoneHeightStuds)
	return {
		cframe = part.CFrame * CFrame.new(0, (v3 + v2) / 2, 0),
		size = Vector3.new(part.Size.X, v3 - v2, part.Size.Z)
	}
end

local function collectZoneBoxes(part)
	local result = {}

	if part:IsA("BasePart") then
		table.insert(result, (normalizeZoneBoxHeight(part)))
	end

	for _, part2 in part:GetDescendants() do
		if part2:IsA("BasePart") then
			table.insert(result, (normalizeZoneBoxHeight(part2)))
		end
	end

	return result
end

local function collectZoneSource(parent, childName: string, filterDescendantsInstances)
	local child = parent:FindFirstChild(childName, true)
	local selected = not child and {} or collectZoneBoxes(child)

	if #selected > 0 then
		return selected, "zone folder"
	end

	if child then
		logger:warn(string.format("'%s' under '%s' has no BasePart; ignored", childName, parent.Name))
	end

	local rigGroundY = findRigGroundY(parent, filterDescendantsInstances)
	local selected2 = not rigGroundY and {} or collectFloorBoxes(parent, rigGroundY)

	if #selected2 > 0 then
		return selected2, "floor level"
	end

	return collectMapBoundsBoxes(parent), "map bounding box"
end

local function clampIntoBox(item, vector: Vector3, p: number)
	local pointToObjectSpace = item.cframe:PointToObjectSpace(vector)
	local v = math.max(0, item.size.X / 2 - p)
	local v2 = math.max(0, item.size.Z / 2 - p)
	local pointToWorldSpace = item.cframe:PointToWorldSpace((Vector3.new(
		math.clamp(pointToObjectSpace.X, -v, v),
		pointToObjectSpace.Y,
		(math.clamp(pointToObjectSpace.Z, -v2, v2))
	)))
	return (Vector3.new(pointToWorldSpace.X, vector.Y, pointToWorldSpace.Z))
end

local Zone = {
	getBoundsFolderName = function()
		return formatted
	end,
	readParts = function(folder)
		local result = {}

		for _, part in folder:GetDescendants() do
			if part:IsA("BasePart") then
				table.insert(result, {
					cframe = part.CFrame,
					size = part.Size
				})
			end
		end

		return result
	end
}

local function footprint(items)
	local v = 1e999
	local v2 = -1e999
	local v3 = 1e999
	local v4 = -1e999

	for _, item in items do
		local v5 = item.size.X / 2
		local v6 = item.size.Z / 2

		for _, v7 in {
			Vector3.new(v5, 0, v6),
			Vector3.new(-v5, 0, v6),
			Vector3.new(v5, 0, -v6),
			(Vector3.new(-v5, 0, -v6))
		} do
			local pointToWorldSpace = item.cframe:PointToWorldSpace(v7)
			v = math.min(v, pointToWorldSpace.X)
			v2 = math.max(v2, pointToWorldSpace.X)
			v3 = math.min(v3, pointToWorldSpace.Z)
			v4 = math.max(v4, pointToWorldSpace.Z)
		end
	end

	return v2 - v, v4 - v3, (v + v2) / 2, (v3 + v4) / 2
end

local function shrinkBoxes(items, zoneShrinkFactor: number)
	local _, _, v, v2 = footprint(items)
	local result = {}

	for _, item in items do
		local position = item.cframe.Position
		local vector = Vector3.new((position.X - v) * zoneShrinkFactor, 0, (position.Z - v2) * zoneShrinkFactor)
		local vector2 = Vector3.new(v + vector.X, position.Y, v2 + vector.Z)
		table.insert(result, {
			cframe = item.cframe.Rotation + vector2,
			size = Vector3.new(item.size.X * zoneShrinkFactor, item.size.Y, item.size.Z * zoneShrinkFactor)
		})
	end

	return result
end

function Zone.resolve(parent, p: string, filterDescendantsInstances)
	local boxes, source = collectZoneSource(parent, p, filterDescendantsInstances)

	if Config.zoneShrinkFactor < 1 then
		boxes = shrinkBoxes(boxes, Config.zoneShrinkFactor)
	end

	local v3 = {
		boxes = boxes,
		source = source,
		engineFolderName = formatted,
		generatedFolder = 0
	}
	local folder = Instance.new("Folder")
	folder.Name = formatted

	for _, v5 in boxes do
		createZonePart(v5, folder)
	end

	folder.Parent = parent
	v3.generatedFolder = folder
	return v3
end

function Zone.isInside(items, vector: Vector3)
	for _, item in items do
		if SpacialQuery.isPointInVolume(vector, item.cframe, item.size, true) then
			return true
		end
	end

	return false
end

function Zone.clamp(items, vector: Vector3, value: number?)
	if Zone.isInside(items, vector) then
		return vector
	end

	local v = Config.zoneMarginStuds * (value or 1)
	local v2 = vector
	local v3 = 1e999

	for _, item in items do
		local v4 = clampIntoBox(item, vector, v)
		local magnitude = (v4 - vector).Magnitude

		if not (magnitude < v3) then
			continue
		end

		v2 = v4
		v3 = magnitude
	end

	return v2
end

function Zone.describeFootprint(p)
	local v, v2 = footprint(p)
	return v, v2
end

function Zone.buildFloorRaycastParams()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true
	raycastParams.IgnoreWater = true
	return raycastParams
end

function Zone.hasFloorBelow(p, vector: Vector3, value: number?)
	local v = value or 1
	local v2 = vector + Vector3.new(0, Config.floorProbeUpStuds * v, 0)
	local v3 = (Config.floorProbeUpStuds + Config.floorProbeDepthStuds) * v
	return Workspace:Raycast(v2, Vector3.new(0, -v3, 0), p) ~= nil
end

return Zone