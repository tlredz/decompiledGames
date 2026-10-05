local createVector = vector.create
local ZonePlacementManager = {}
local CollectionService = game:GetService("CollectionService")
local random = math.random
local new = Vector3.new
local v = {
	WiltedFlowerZone = {
		minDistanceFromSameType = 15,
		minDistanceFromOtherZones = 10,
		maxPerFloor = 3
	},
	IchorPuddleZone = {
		minDistanceFromSameType = 12,
		minDistanceFromOtherZones = 6,
		minDistanceFromWiltedFlowers = 5,
		maxPerFloor = 15
	},
	SpeedBoostZone = {
		minDistanceFromSameType = 12,
		minDistanceFromOtherZones = 8,
		maxPerFloor = 10
	},
	BlotHandZone = {
		minDistanceFromSameType = 8,
		minDistanceFromOtherZones = 6,
		maxPerFloor = 20,
		minDistanceFromSameOwner = 3,
		allowOwnerStacking = false
	}
}
local v2 = nil
local v3 = 0

local function getActiveZones()
	local now = tick()

	if v2 and now - v3 < 1 then
		return v2
	end

	local result = {}

	for tag, _ in pairs(v) do
		local tagged = CollectionService:GetTagged(tag)

		for _, part in ipairs(tagged) do
			if part.Parent then
				table.insert(result, {
					zoneType = tag,
					position = part.Position,
					size = part.Size,
					part = part
				})
			end
		end
	end

	v2 = result
	v3 = now
	return result
end

local function invalidateZoneCache()
	v2 = nil
end

local function isPositionValid(p, p2, p3, p4)
	local v4 = v[p2]

	if not v4 then
		return true
	end

	local activeZones = getActiveZones()
	local v5 = p3 / 2
	local ownerID = p4 and p4.ownerID

	for _, activeZone in ipairs(activeZones) do
		local magnitude = (p - activeZone.position).Magnitude
		local v6 = v5.X + activeZone.size.X / 2
		local v7 = ownerID and activeZone.part:GetAttribute("OwnerID") == ownerID and true or false
		local minDistanceFromSameOwner

		if activeZone.zoneType == p2 then
			if v7 and v4.minDistanceFromSameOwner then
				minDistanceFromSameOwner = v4.minDistanceFromSameOwner
			else
				minDistanceFromSameOwner = v4.minDistanceFromSameType or 15
			end
		else
			minDistanceFromSameOwner = v4.minDistanceFromOtherZones or 10

			if p2 == "IchorPuddleZone" and activeZone.zoneType == "WiltedFlowerZone" then
				minDistanceFromSameOwner = v4.minDistanceFromWiltedFlowers or 8
			end
		end

		if magnitude < minDistanceFromSameOwner or not (v7 and v4.allowOwnerStacking) and magnitude < v6 then
			return false
		end
	end

	return true
end

local function getSpawnPoints()
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		return {}
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		return {}
	end

	local monsterSpawnPoints = model:FindFirstChild("MonsterSpawnPoints")

	if not monsterSpawnPoints then
		return {}
	end

	local positions = {}

	for _, part in ipairs(monsterSpawnPoints:GetChildren()) do
		if part:IsA("BasePart") then
			table.insert(positions, part.Position)
		end
	end

	return positions
end

function ZonePlacementManager.FindValidPositions(p, p2, p3, options)
	local v4 = options or {}
	local maxAttempts = v4.maxAttempts or 50
	local searchRadius = v4.searchRadius or 25
	local spawnPoints = getSpawnPoints()

	if #spawnPoints == 0 then
		warn("ZonePlacementManager: No spawn points found")
		return {}
	end

	local spawnPoints2 = {}
	local count = 0

	while #spawnPoints2 < p2 and count < maxAttempts do
		count += 1
		local spawnPoint = spawnPoints[random(1, #spawnPoints)]

		if searchRadius > 0 then
			spawnPoint += new(random(-searchRadius, searchRadius), 0, random(-searchRadius, searchRadius))
		end

		if isPositionValid(spawnPoint, p, p3, v4) then
			table.insert(spawnPoints2, spawnPoint)
		end
	end

	return spawnPoints2
end

function ZonePlacementManager.CreateZoneBatch(p, list, p2, p3)
	local ZoneModifierManager = require(game.ServerScriptService:WaitForChild("ZoneModifierManager"))
	local zones = {}
	local result = {}

	for _, v4 in ipairs(list) do
		if isPositionValid(v4, p, p2, p3) then
			local zone = ZoneModifierManager.CreateZone(p, v4, p2, p3)

			if zone then
				table.insert(zones, zone)
				v2 = nil
			else
				table.insert(result, v4)
			end
		else
			table.insert(result, v4)
		end
	end

	return zones, result
end

function ZonePlacementManager.CheckZoneOverlap(p, p2, p3, p4)
	return not isPositionValid(p, p3, p2, p4)
end

function ZonePlacementManager.GetNearbyZones(p, p2)
	local activeZones = getActiveZones()
	local activeZones2 = {}

	for _, activeZone in ipairs(activeZones) do
		local magnitude = (p - activeZone.position).Magnitude

		if not (magnitude <= p2) then
			continue
		end

		activeZone.distance = magnitude
		table.insert(activeZones2, activeZone)
	end

	table.sort(activeZones2, function(a, b)
		return a.distance < b.distance
	end)
	return activeZones2
end

function ZonePlacementManager.DebugZoneSpacing(p)
	local activeZones = getActiveZones()
	print("=== ZONE SPACING DEBUG ===")
	print("Total active zones:", #activeZones)

	for i, activeZone in ipairs(activeZones) do
		print(string.format("Zone %d: %s at %s", i, activeZone.zoneType, (tostring(activeZone.position))))

		if not p then
			continue
		end

		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.new(0, 100, 0, 50)
		billboardGui.StudsOffset = createVector(0, 3, 0)
		billboardGui.Parent = activeZone.part
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextScaled = true
		textLabel.Text = activeZone.zoneType
		textLabel.Parent = billboardGui
		local Debris = game:GetService("Debris")
		Debris:AddItem(billboardGui, 10)
	end
end

function ZonePlacementManager.FindNearbyValidPosition(p, p2, p3, p4)
	for i = 1, 20 do
		local v4 = i / 20
		local v5 = v4 * 6.283185307179586
		local v6 = v4 * 10
		local v9 = p + new(math.cos(v5) * v6, 0, math.sin(v5) * v6)

		if not ZonePlacementManager.CheckZoneOverlap(v9, p2, p3, p4) then
			return v9
		end
	end

	return nil
end

function ZonePlacementManager.GetZoneConfig(p)
	return v[p]
end

return ZonePlacementManager