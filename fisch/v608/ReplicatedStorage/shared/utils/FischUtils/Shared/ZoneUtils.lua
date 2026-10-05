local createVector = vector.create

-- equivalent calls inferred from this helper; original call sites unknown
local function getValueObject(instance, childName: string)
	local valueBase = instance:FindFirstChild(childName)

	if valueBase and valueBase:IsA("ValueBase") then
		return valueBase.Value
	end

	return nil
end

local ZoneUtils = {}

function ZoneUtils.GetPlayerZone(player)
	local character = player.Character

	if not character then
		return nil
	end

	local zone = character:FindFirstChild("zone")

	if not (zone and zone:IsA("ObjectValue")) then
		return nil
	end

	local value = zone.Value

	if value then
		return value.Name
	end

	return nil
end

function ZoneUtils.GetZoneName(position)
	if typeof(position) == "CFrame" then
		position = position.Position
	end

	local v = -1e999
	local v2 = nil

	for _, part in workspace:WaitForChild("zones"):WaitForChild("player"):GetChildren() do
		if not (part:IsA("BasePart") and (part:GetClosestPointOnSurface(position) - position).Magnitude <= 0.25) then
			continue
		end

		local v3 = not part:FindFirstChild("priority") and 0 or part:FindFirstChild("priority").Value or 0

		if not (v < v3) then
			continue
		end

		v2 = part
		v = v3
	end

	if v2 and v2:FindFirstChild("zonename") then
		return v2.zonename.Value
	end

	return "Ocean"
end

function ZoneUtils.GetZonesAt(position)
	if typeof(position) == "Instance" then
		local character = position.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		position = humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoidRootPart.Position or createVector(
			0,
			0,
			0
		)
	end

	local result = {}

	for _, part in workspace:WaitForChild("zones"):WaitForChild("player"):GetChildren() do
		if not part:IsA("BasePart") or not ((part:GetClosestPointOnSurface(position) - position).Magnitude <= 0.25) or table.find(
			result,
			part.Name
		) then
			continue
		end

		table.insert(result, part.Name)
	end

	if not table.find(result, "Ocean") then
		table.insert(result, "Ocean")
	end

	return result
end

function ZoneUtils.GetZoneMeta(position)
	if typeof(position) == "Instance" then
		local character = position.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		position = humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoidRootPart.Position or createVector(
			0,
			0,
			0
		)
	end

	local v = -1e999
	local instance = nil

	for _, part in workspace.zones:WaitForChild("player"):GetChildren() do
		if not (part:IsA("BasePart") and (part:GetClosestPointOnSurface(position) - position).Magnitude <= 0.25) then
			continue
		end

		local value = part:FindFirstChild("priority").Value

		if not (v < value) then
			continue
		end

		instance = part
		v = value
	end

	if not (instance and instance:FindFirstChild("zonename")) then
		return {
			Instance = instance,
			Name = "Ocean",
			DisplayName = "Ocean",
			Group = position.X > 12000 and "Northern" or "MainOcean",
			Indoors = false,
			Underground = false,
			Priority = 0,
			DiscoverName = "Ocean",
			Bestiary = "Ocean",
			FakeWater = false
		}
	end

	local valueObject = getValueObject(instance, "discover") -- equivalent call inferred; original call site unknown
	local v3 = {
		Instance = instance,
		Name = instance.Name,
		DisplayName = 0,
		Group = 0,
		Indoors = 0,
		Underground = 0,
		Priority = 0,
		DiscoverName = 0,
		Bestiary = 0,
		FakeWater = 0
	}
	local valueObject2 = getValueObject(instance, "zonename") -- equivalent call inferred; original call site unknown
	v3.DisplayName = valueObject2
	v3.Group = instance:GetAttribute("ZoneGroup")
	local valueObject3 = getValueObject(instance, "indoors") -- equivalent call inferred; original call site unknown
	v3.Indoors = valueObject3 or false
	local valueObject4 = getValueObject(instance, "underground") -- equivalent call inferred; original call site unknown
	v3.Underground = valueObject4 or false
	local valueObject5 = getValueObject(instance, "priority") -- equivalent call inferred; original call site unknown
	v3.Priority = valueObject5 or 0
	v3.DiscoverName = valueObject
	local valueObject6 = getValueObject(instance, "bestiary") -- equivalent call inferred; original call site unknown
	v3.Bestiary = valueObject6 or valueObject or instance.Name
	v3.FakeWater = instance:HasTag("FakeUnderwaterZone")
	return v3
end

function ZoneUtils.FindNearestIsland(vector2: Vector3)
	local active = workspace:FindFirstChild("active")
	local oceanPOIs = active and active:FindFirstChild("OceanPOI's")

	if not oceanPOIs then
		return nil
	end

	local v = 1e999
	local v2 = nil

	for _, child in oceanPOIs:GetChildren() do
		local magnitude = (child.Position - vector2).Magnitude

		if not (magnitude < v) then
			continue
		end

		v2 = child
		v = magnitude
	end

	return v2 and v2.Name or nil
end

return ZoneUtils