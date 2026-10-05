local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CaptureTheEgg = require(ReplicatedStorage.Data.CaptureTheEgg)
local GuardAreaGeometry = require(script.Parent.GuardAreaGeometry)
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.Vector3)
local strict2 = t.strict(t.number)
local strict3 = t.strict(t.boolean)
local strict4 = t.strict(t.string)
local v = nil

local function areasFolder()
	local v2 = v

	if v2 ~= nil and v2.Parent ~= nil then
		return v2
	end

	local world = Workspace:FindFirstChild("World")
	assert(world ~= nil, "Workspace.World is missing")
	local areas = world:FindFirstChild("Areas")
	local v3

	if areas == nil then
		v3 = false
	else
		v3 = areas:IsA("Folder")
	end

	assert(v3, "Workspace.World.Areas must be a Folder")
	v = areas
	return areas
end

local function areaPart(childName: string)
	local part = areasFolder():FindFirstChild(childName)
	local v2

	if part == nil then
		v2 = false
	else
		v2 = part:IsA("BasePart")
	end

	assert(v2, (`Workspace.World.Areas.{childName} must be a BasePart`))
	return part
end

-- equivalent calls inferred from this helper; original call sites unknown
local function readBox(instance)
	return {
		CFrame = instance.CFrame,
		HalfSize = instance.Size * 0.5
	}
end

local function depth(vector2: Vector3)
	local signedDistanceToLine = GuardAreaGeometry.SignedDistanceToLine
	local separationLine = areasFolder():FindFirstChild("SeparationLine")
	local v2

	if separationLine == nil then
		v2 = false
	else
		v2 = separationLine:IsA("BasePart")
	end

	assert(v2, "Workspace.World.Areas.SeparationLine must be a BasePart")
	return signedDistanceToLine(separationLine, vector2)
end

local function barrierBoxes(flag: boolean)
	local wallStartCollision = areasFolder():FindFirstChild("WallStartCollision")
	local v2

	if wallStartCollision == nil then
		v2 = false
	else
		v2 = wallStartCollision:IsA("BasePart")
	end

	assert(v2, "Workspace.World.Areas.WallStartCollision must be a BasePart")
	local result = { (readBox(wallStartCollision)) }

	if not flag then
		return result
	end

	local spawnLock = ReplicatedStorage.Assets:FindFirstChild("SpawnLock")

	if spawnLock == nil then
		return result
	end

	if spawnLock:IsA("BasePart") then
		table.insert(result, readBox(spawnLock))
	end

	for _, part in spawnLock:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(result, readBox(part))
		end
	end

	return result
end

local function projectedHalfExtent(p, vector2: Vector3)
	return math.abs((vector2:Dot(p.CFrame.XVector))) * p.HalfSize.X + math.abs((vector2:Dot(p.CFrame.YVector))) * p.HalfSize.Y + math.abs((vector2:Dot(p.CFrame.ZVector))) * p.HalfSize.Z
end

local function boxIntrusion(p, vector2: Vector3, p2: number, vector3: Vector3)
	local pointToObjectSpace = p.CFrame:PointToObjectSpace(vector2)
	local v2 = p.HalfSize + createVector(1, 1, 1) * p2

	if math.abs(pointToObjectSpace.X) > v2.X or math.abs(pointToObjectSpace.Y) > v2.Y or math.abs(pointToObjectSpace.Z) > v2.Z then
		return nil
	end

	local position = p.CFrame.Position
	local signedDistanceToLine = GuardAreaGeometry.SignedDistanceToLine
	local separationLine = areasFolder():FindFirstChild("SeparationLine")
	local v3

	if separationLine == nil then
		v3 = false
	else
		v3 = separationLine:IsA("BasePart")
	end

	assert(v3, "Workspace.World.Areas.SeparationLine must be a BasePart")
	local v4 = signedDistanceToLine(separationLine, position) + projectedHalfExtent(p, vector3) + p2
	local signedDistanceToLine2 = GuardAreaGeometry.SignedDistanceToLine
	local separationLine2 = areasFolder():FindFirstChild("SeparationLine")
	local v5

	if separationLine2 == nil then
		v5 = false
	else
		v5 = separationLine2:IsA("BasePart")
	end

	assert(v5, "Workspace.World.Areas.SeparationLine must be a BasePart")
	local v6 = v4 - signedDistanceToLine2(separationLine2, vector2)

	if v6 > 0 then
		return v6
	end

	return nil
end

local function segmentHitsBox(p, vector2: Vector3, vector3: Vector3, p2: number)
	local pointToObjectSpace = p.CFrame:PointToObjectSpace(vector2)
	local v2 = p.CFrame:PointToObjectSpace(vector3) - pointToObjectSpace
	local v3 = p.HalfSize + createVector(1, 1, 1) * p2
	local v4 = { pointToObjectSpace.X, pointToObjectSpace.Y, pointToObjectSpace.Z }
	local v5 = { v2.X, v2.Y, v2.Z }
	local v6 = { v3.X, v3.Y, v3.Z }
	local v7 = 0
	local v8 = 1

	for i = 1, 3 do
		local v9 = v4[i]
		local v10 = v5[i]
		local v11 = v6[i]

		if math.abs(v10) < 0.0001 then
			if v11 < math.abs(v9) then
				return false
			end
		else
			local v12 = (-v11 - v9) / v10
			local v13 = (v11 - v9) / v10

			if v13 < v12 then
				v13, v12 = v12, v13
			end

			v7 = math.max(v7, v12)
			v8 = math.min(v8, v13)

			if v8 < v7 then
				return false
			end
		end
	end

	return true
end

local SafeZoneBarriers = {}

function SafeZoneBarriers.IsFencedUid(p: string)
	strict4(p)
	return Workspace:GetAttribute(CaptureTheEgg.EggUidAttribute) == p
end

function SafeZoneBarriers.Depth(vector2: Vector3)
	strict(vector2)
	return depth(vector2)
end

function SafeZoneBarriers.Intrusion(vector2: Vector3, p: number, flag: boolean, vector3: Vector3)
	strict(vector2)
	strict2(p)
	strict3(flag)
	strict(vector3)
	local v2 = nil

	local function consider(p2: number?)
		if p2 ~= nil and (v2 == nil or v2 < p2) then
			v2 = p2
		end
	end

	local signedDistanceToLine = GuardAreaGeometry.SignedDistanceToLine
	local separationLine = areasFolder():FindFirstChild("SeparationLine")
	local v3

	if separationLine == nil then
		v3 = false
	else
		v3 = separationLine:IsA("BasePart")
	end

	assert(v3, "Workspace.World.Areas.SeparationLine must be a BasePart")
	local v4 = p - signedDistanceToLine(separationLine, vector2)

	if not (v4 > 0) then
		v4 = nil
	end

	if v4 ~= nil and (v2 == nil or v2 < v4) then
		v2 = v4
	end

	for _, v5 in barrierBoxes(flag) do
		local v6 = boxIntrusion(v5, vector2, p, vector3)

		if v6 ~= nil and (v2 == nil or v2 < v6) then
			v2 = v6
		end
	end

	return v2
end

function SafeZoneBarriers.Separates(vector2: Vector3, vector3: Vector3, flag: boolean)
	strict(vector2)
	strict(vector3)
	strict3(flag)
	local signedDistanceToLine = GuardAreaGeometry.SignedDistanceToLine
	local separationLine = areasFolder():FindFirstChild("SeparationLine")
	local v2

	if separationLine == nil then
		v2 = false
	else
		v2 = separationLine:IsA("BasePart")
	end

	assert(v2, "Workspace.World.Areas.SeparationLine must be a BasePart")
	local v3 = signedDistanceToLine(separationLine, vector2) > 0
	local signedDistanceToLine2 = GuardAreaGeometry.SignedDistanceToLine
	local separationLine2 = areasFolder():FindFirstChild("SeparationLine")
	local v4

	if separationLine2 == nil then
		v4 = false
	else
		v4 = separationLine2:IsA("BasePart")
	end

	assert(v4, "Workspace.World.Areas.SeparationLine must be a BasePart")

	if v3 ~= (signedDistanceToLine2(separationLine2, vector3) > 0) then
		return true
	end

	for _, v5 in barrierBoxes(flag) do
		if segmentHitsBox(v5, vector2, vector3, 0) then
			return true
		end
	end

	return false
end

return SafeZoneBarriers