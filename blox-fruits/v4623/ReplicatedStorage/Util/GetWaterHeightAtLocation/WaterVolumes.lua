local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Water = require(game.ReplicatedStorage.Modules.World.Water)
local v = {
	[Water.ALLOW_BOATS_ATTRIBUTE] = true,
	[Water.ALLOW_SWIM_ATTRIBUTE] = true,
	[Water.BODY_NAME_ATTRIBUTE] = true,
	[Water.MIN_SWIM_DEPTH_ATTRIBUTE] = true,
	[Water.PRIORITY_ATTRIBUTE] = true,
	[Water.SURFACE_OFFSET_ATTRIBUTE] = true
}
local volumesEnabled = script.Parent:GetAttribute("VolumesEnabled") ~= false
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = 0
local v7 = 0

local function readNumber(instance, attributeName: string, p: number)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) == "number" then
		return attribute
	end

	return p
end

local function readBoolean(instance, attributeName: string, flag: boolean)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) == "boolean" then
		return attribute
	end

	return flag
end

local function removeFromGrid(state)
	if not state.Indexed then
		return
	end

	state.Indexed = false

	for i = state.MinCellX, state.MaxCellX do
		local v8 = v2[i]

		if not v8 then
			continue
		end

		for i2 = state.MinCellZ, state.MaxCellZ do
			local v9 = v8[i2]

			if not v9 then
				continue
			end

			local index = table.find(v9, state)

			if index then
				table.remove(v9, index)
			end

			if #v9 == 0 then
				v8[i2] = nil
			end
		end

		if next(v8) == nil then
			v2[i] = nil
		end
	end
end

local function indexVolume(state)
	local part = state.Part

	if not part:IsDescendantOf(workspace) then
		removeFromGrid(state)
		return
	end

	local cFrame = part.CFrame
	local size = part.Size
	local halfSize = size * 0.5
	state.CFrame = cFrame
	state.HalfSize = halfSize
	state.SizeMagnitude = size.Magnitude
	local v9 = cFrame.RightVector * halfSize.X
	local v10 = cFrame.UpVector * halfSize.Y
	local v11 = cFrame.LookVector * halfSize.Z
	local position = cFrame.Position
	local v12 = math.abs(v9.X) + math.abs(v10.X) + math.abs(v11.X)
	local v13 = math.abs(v9.Y) + math.abs(v10.Y) + math.abs(v11.Y)
	local v14 = math.abs(v9.Z) + math.abs(v10.Z) + math.abs(v11.Z)
	local minX = position.X - v12
	local maxX = position.X + v12
	state.MinX = minX
	state.MaxX = maxX
	local minY = position.Y - v13
	local maxY = position.Y + v13
	state.MinY = minY
	state.MaxY = maxY
	local minZ = position.Z - v14
	local maxZ = position.Z + v14
	state.MinZ = minZ
	state.MaxZ = maxZ
	local minCellX = math.floor(state.MinX / 512)
	local maxCellX = math.floor(state.MaxX / 512)
	local minCellZ = math.floor(state.MinZ / 512)
	local maxCellZ = math.floor(state.MaxZ / 512)

	if state.Indexed and minCellX == state.MinCellX and maxCellX == state.MaxCellX and minCellZ == state.MinCellZ and maxCellZ == state.MaxCellZ then
		return
	end

	removeFromGrid(state)
	state.MinCellX = minCellX
	state.MaxCellX = maxCellX
	state.MinCellZ = minCellZ
	state.MaxCellZ = maxCellZ
	state.Indexed = true

	for i = minCellX, maxCellX do
		local v25 = v2[i]

		if not v25 then
			v25 = {}
			v2[i] = v25
		end

		for i2 = minCellZ, maxCellZ do
			local states = v25[i2]

			if not states then
				states = {}
				v25[i2] = states
			end

			table.insert(states, state)
		end
	end
end

local function refreshAttributes(p)
	local part = p.Part
	local attribute = part:GetAttribute(Water.BODY_NAME_ATTRIBUTE)

	if typeof(attribute) ~= "string" then
		attribute = part.Name
	end

	p.BodyName = attribute
	local attribute2 = part:GetAttribute(Water.ALLOW_BOATS_ATTRIBUTE)

	if typeof(attribute2) ~= "boolean" then
		attribute2 = false
	end

	p.AllowBoats = attribute2
	local attribute3 = part:GetAttribute(Water.ALLOW_SWIM_ATTRIBUTE)
	p.AllowSwim = typeof(attribute3) ~= "boolean" or attribute3
	local MIN_SWIM_DEPTH_ATTRIBUTE = Water.MIN_SWIM_DEPTH_ATTRIBUTE
	local DEFAULT_MIN_SWIM_DEPTH = Water.DEFAULT_MIN_SWIM_DEPTH
	local attribute4 = part:GetAttribute(MIN_SWIM_DEPTH_ATTRIBUTE)

	if typeof(attribute4) ~= "number" then
		attribute4 = DEFAULT_MIN_SWIM_DEPTH
	end

	p.MinSwimDepth = attribute4
	local attribute5 = part:GetAttribute(Water.PRIORITY_ATTRIBUTE)
	p.Priority = typeof(attribute5) ~= "number" and 0 or attribute5
	local attribute6 = part:GetAttribute(Water.SURFACE_OFFSET_ATTRIBUTE)
	p.SurfaceOffset = typeof(attribute6) ~= "number" and 0 or attribute6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function markDirty(p)
	if v5[p] then
		return
	end

	v5[p] = true
	v6 += 1
end

local function flushDirty()
	if v6 == 0 then
		return
	end

	for k in v5 do
		v5[k] = nil
		local v8 = v3[k]

		if not v8 then
			continue
		end

		refreshAttributes(v8)
		indexVolume(v8)
	end

	v6 = 0
end

local function unregisterVolume(part)
	local v8 = v3[part]

	if not v8 then
		return
	end

	removeFromGrid(v8)
	v3[part] = nil
	v7 -= 1

	if v5[part] then
		v5[part] = nil
		v6 -= 1
	end

	local v9 = v4[part]

	if v9 then
		for _, connection in v9 do
			connection:Disconnect()
		end

		v4[part] = nil
	end
end

local function registerVolume(part)
	if v3[part] then
		markDirty(part) -- equivalent call inferred; original call site unknown
	else
		local v8 = {
			Part = part,
			BodyName = part.Name,
			AllowBoats = false,
			AllowSwim = true,
			MinSwimDepth = Water.DEFAULT_MIN_SWIM_DEPTH,
			Priority = 0,
			SurfaceOffset = 0,
			CFrame = CFrame.identity,
			HalfSize = createVector(0, 0, 0),
			SizeMagnitude = 0,
			MinX = 0,
			MaxX = 0,
			MinY = 0,
			MaxY = 0,
			MinZ = 0,
			MaxZ = 0,
			MinCellX = 0,
			MaxCellX = 0,
			MinCellZ = 0,
			MaxCellZ = 0,
			Indexed = false
		}
		v3[part] = v8
		v7 += 1
		v4[part] = {
			part:GetPropertyChangedSignal("CFrame"):Connect(function()
				markDirty(part) -- equivalent call inferred; original call site unknown
			end),
			part:GetPropertyChangedSignal("Size"):Connect(function()
				markDirty(part) -- equivalent call inferred; original call site unknown
			end),
			part.AttributeChanged:Connect(function(p)
				if v[p] then
					markDirty(part) -- equivalent call inferred; original call site unknown
				end
			end),
			part.AncestryChanged:Connect(function()
				markDirty(part) -- equivalent call inferred; original call site unknown
			end)
		}
		refreshAttributes(v8)
		indexVolume(v8)
	end
end

local function findBest(vector2: Vector3, flag: boolean, flag2: boolean)
	if v7 == 0 or not volumesEnabled then
		return nil
	end

	flushDirty()
	local X = vector2.X
	local Y = vector2.Y
	local Z = vector2.Z
	local v8 = v2[math.floor(X / 512)]

	if not v8 then
		return nil
	end

	local v9 = v8[math.floor(Z / 512)]

	if not v9 then
		return nil
	end

	local v10 = nil

	for _, v11 in v9 do
		if not (not flag2 or v11.AllowBoats) then
			continue
		end

		if X < v11.MinX or v11.MaxX < X or Z < v11.MinZ or v11.MaxZ < Z then
			continue
		end

		if not (flag or not (Y < v11.MinY or v11.MaxY < Y)) then
			continue
		end

		local pointToObjectSpace = v11.CFrame:PointToObjectSpace(vector2)
		local halfSize = v11.HalfSize

		if math.abs(pointToObjectSpace.X) > halfSize.X or math.abs(pointToObjectSpace.Z) > halfSize.Z then
			continue
		end

		if not (flag or not (math.abs(pointToObjectSpace.Y) > halfSize.Y)) then
			continue
		end

		if v10 then
			if v11.Priority > v10.Priority or v11.Priority == v10.Priority and v11.SizeMagnitude < v10.SizeMagnitude then
				v10 = v11
			end
		else
			v10 = v11
		end
	end

	return v10
end

local WaterVolumes = {
	containsPoint = function(p, vector2: Vector3)
		local pointToObjectSpace = p.CFrame:PointToObjectSpace(vector2)
		local halfSize = p.HalfSize
		return math.abs(pointToObjectSpace.X) <= halfSize.X and math.abs(pointToObjectSpace.Y) <= halfSize.Y and math.abs(pointToObjectSpace.Z) <= halfSize.Z
	end,
	getSurfaceHeight = function(data, vector2: Vector3)
		local cFrame = data.CFrame
		local vector3 = cFrame * Vector3.new(0, data.HalfSize.Y + data.SurfaceOffset, 0)
		local upVector = cFrame.UpVector

		if math.abs(upVector.Y) < 0.0001 then
			return vector3.Y
		end

		return vector3.Y - (upVector.X * (vector2.X - vector3.X) + upVector.Z * (vector2.Z - vector3.Z)) / upVector.Y
	end,
	query = function(vector2: Vector3)
		return (findBest(vector2, false, false))
	end,
	queryBoatColumn = function(vector2: Vector3)
		return (findBest(vector2, true, true))
	end,
	get = function(p)
		return v3[p]
	end,
	isWaterPart = function(instance)
		return instance:HasTag(Water.FISHABLE_TAG) or volumesEnabled and instance:HasTag(Water.VOLUME_TAG)
	end,
	isEnabled = function()
		return volumesEnabled
	end,
	getAll = function()
		if v7 > 0 then
			flushDirty()
		end

		local result = {}

		for _, v8 in v3 do
			table.insert(result, v8)
		end

		return result
	end
}
script.Parent:GetAttributeChangedSignal("VolumesEnabled"):Connect(function()
	volumesEnabled = script.Parent:GetAttribute("VolumesEnabled") ~= false
end)

for _, part in CollectionService:GetTagged(Water.VOLUME_TAG) do
	if part:IsA("BasePart") then
		registerVolume(part)
	end
end

CollectionService:GetInstanceAddedSignal(Water.VOLUME_TAG):Connect(function(part)
	if part:IsA("BasePart") then
		registerVolume(part)
	end
end)
CollectionService:GetInstanceRemovedSignal(Water.VOLUME_TAG):Connect(function(part)
	if part:IsA("BasePart") then
		unregisterVolume(part)
	end
end)
return WaterVolumes