local createVector = vector.create
local EggSpawnRules = {
	RadarRange = 2500,
	BreakDistanceStep = 20,
	BreakSecondsPerStep = 0.1,
	MythicBreakDistanceStep = 200,
	MythicBreakSecondsPerStep = 0.2,
	SpawnType = function(p)
		local spawnType = p and p.SpawnType

		if type(spawnType) ~= "string" or spawnType == "" or not spawnType then
			spawnType = nil
		end

		return spawnType
	end
}

function EggSpawnRules.IsRestricted(p)
	return p ~= nil and (p.SpecificSpawn == true or EggSpawnRules.SpawnType(p) ~= nil)
end

function EggSpawnRules.PadRarity(p)
	return (p.Name:gsub("%-+$", ""))
end

function EggSpawnRules.IsTypedPad(instance)
	for _, v in instance:GetTags() do
		if v ~= "AutoEggSpawn" and v:match("^.+Spawn$") then
			return true
		end
	end

	return false
end

function EggSpawnRules.Matches(value, p, part)
	if not (p and part:IsA("BasePart")) then
		return false
	end

	local type2 = EggSpawnRules.SpawnType(p)

	if type2 then
		if not part:HasTag(type2 .. "Spawn") then
			return false
		end
	elseif EggSpawnRules.IsTypedPad(part) then
		return false
	end

	local padRarity = EggSpawnRules.PadRarity(part)

	if p.SpecificSpawn == true then
		return padRarity == value or padRarity == value:gsub(" Egg$", "")
	end

	return not type2 or padRarity == p.Rarity
end

function EggSpawnRules.RadarAllows(p, p2, p3)
	if not EggSpawnRules.IsRestricted(p) then
		return true
	end

	if typeof(p2) == "Vector3" and typeof(p3) == "Vector3" then
		return ((p2 - p3) * createVector(1, 0, 1)).Magnitude <= EggSpawnRules.RadarRange
	end

	return false
end

function EggSpawnRules.DistanceBonus(p, p2, p3, p4)
	if not EggSpawnRules.IsRestricted(p) or typeof(p2) ~= "Vector3" then
		return 0
	end

	local v = p4 and p4[p.Rarity]
	local maximum = v and tonumber(v.Maximum)

	if not maximum or maximum ~= maximum or maximum == 1e999 then
		return 0
	end

	local magnitude = ((p2 - p3) * createVector(1, 0, 1)).Magnitude
	local breakDistanceStep = EggSpawnRules.BreakDistanceStep
	local breakSecondsPerStep = EggSpawnRules.BreakSecondsPerStep

	if p.Rarity == "Mythic" then
		breakDistanceStep = EggSpawnRules.MythicBreakDistanceStep
		breakSecondsPerStep = EggSpawnRules.MythicBreakSecondsPerStep
	end

	return math.floor(math.max(0, magnitude - maximum) / breakDistanceStep) * breakSecondsPerStep
end

return EggSpawnRules