local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Areas = require(ReplicatedStorage.Data.Areas)
local Log = require(ReplicatedStorage.Packages.Log)
local Numeric = require(ReplicatedStorage.Shared.Utils.Numeric)
local rollWeighted = Numeric.RollWeighted
local Rift = require(ReplicatedStorage.Data.Rift)
local RiftFlags = require(ReplicatedStorage.Shared.Flags.RiftFlags)
local RiftZoneLadder = require(ReplicatedStorage.Shared.Modules.RiftZoneLadder)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	Easy = "E",
	Medium = "M",
	Hard = "H",
	Excluded = "X"
}
local v2 = {
	E = 1,
	M = 2,
	H = 3,
	X = 4,
	["?"] = 5
}
local v3 = Log.new()
local random = Random.new()
local v4 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function gaussian(spawnChance: number, targetSpawn: number, spawnSpread: number)
	if spawnSpread <= 0 then
		if spawnChance == targetSpawn then
			return 1
		end

		return 0
	else
		local v5 = spawnChance - targetSpawn
		return (math.exp(-(v5 * v5 / (spawnSpread * 2 * spawnSpread))))
	end
end

function v4.ResolveConfig()
	local excluded = {}

	for _, v6 in RiftFlags.ExcludedPets:Get() do
		excluded[v6] = true
	end

	local slots = {}

	for i = 1, Rift.RequirementCount do
		slots[i] = Rift.GetRecipeSlot(i)
	end

	return {
		MinSpawnChance = RiftFlags.MinSpawnChance:Get(),
		MaxSpawnChance = RiftFlags.MaxSpawnChance:Get(),
		EasyBand = RiftFlags.EasyBand:Get(),
		MediumBand = RiftFlags.MediumBand:Get(),
		HardPenalty = RiftFlags.HardPenalty:Get(),
		ExtendBelow = RiftFlags.ExtendBelow:Get(),
		Slots = slots,
		RequireEasyPet = RiftFlags.RequireEasyPet:Get(),
		MaxEasyPets = RiftFlags.MaxEasyPets:Get(),
		MaxHardPets = RiftFlags.MaxHardPets:Get(),
		MaxNonEasyPets = RiftFlags.MaxNonEasyPets:Get(),
		AllowDuplicatePets = RiftFlags.AllowDuplicatePets:Get(),
		MaxRecipeAttempts = RiftFlags.MaxRecipeAttempts:Get(),
		Excluded = excluded
	}
end

function v4.GetDifficulty(p: number, data)
	if p < data.MinSpawnChance or data.MaxSpawnChance < p then
		return "Excluded"
	end

	if data.EasyBand <= p then
		return "Easy"
	end

	if data.MediumBand <= p then
		return "Medium"
	end

	return "Hard"
end

function v4.ZonePets(p: string)
	local result = {}
	local v5 = Areas.Directory[p]

	if v5 == nil then
		return result
	end

	for _, v6 in v5.DropTable do
		table.insert(result, {
			AssetId = v6[1],
			SpawnChance = v6[2]
		})
	end

	return result
end

function v4.SpawnChanceOf(p: string)
	local spawnChance = nil
	local v5 = nil

	for k in Areas.Directory do
		for _, v6 in v4.ZonePets(k) do
			if not (v6.AssetId == p and (spawnChance == nil or spawnChance < v6.SpawnChance)) then
				continue
			end

			spawnChance = v6.SpawnChance
			v5 = k
		end
	end

	return spawnChance, v5
end

function v4.IsZonePet(p: string)
	return v4.SpawnChanceOf(p) ~= nil
end

function v4.IsEligible(p, p2)
	return p2.Excluded[p.AssetId] ~= true and v4.GetDifficulty(p.SpawnChance, p2) ~= "Excluded"
end

function v4.DifficultyOf(p: string, p2)
	local chanceOf = v4.SpawnChanceOf(p)

	if chanceOf == nil then
		return nil
	end

	return v4.GetDifficulty(chanceOf, p2 or v4.ResolveConfig())
end

local function newContext(bannerId: string, config)
	local bannerRange, v5 = Rift.GetBannerRange(bannerId)
	local ladder = RiftZoneLadder.Get()
	local v7 = nil
	local top = nil

	for k, v9 in ladder do
		if v9.Id == bannerRange then
			v7 = k
		end

		if v9.Id == v5 then
			top = k
		end
	end

	assert(v7 ~= nil, (`Rift banner {bannerId} names an unknown From zone: {bannerRange}`))
	assert(top ~= nil, (`Rift banner {bannerId} names an unknown To zone: {v5}`))
	assert(v7 <= top, (`Rift banner {bannerId} runs backwards ({bannerRange} -> {v5})`))
	local petsByRung = {}

	for k, v10 in ladder do
		petsByRung[k] = v4.ZonePets(v10.Id)
	end

	return {
		BannerId = bannerId,
		Config = config,
		Ladder = ladder,
		Bottom = math.max(1, v7 - config.ExtendBelow),
		Top = top,
		PetsByRung = petsByRung
	}
end

local function buildSlotPool(data, i: number, p)
	local config = data.Config
	local slot = config.Slots[i]
	local result = {}

	for i2 = math.max(data.Bottom, data.Top - (slot.Biomes - 1)), data.Top do
		local v5 = data.Ladder[i2]

		for _, v6 in data.PetsByRung[i2] do
			if not (v4.IsEligible(v6, config) and (config.AllowDuplicatePets or not p[v6.AssetId])) then
				continue
			end

			local difficulty = v4.GetDifficulty(v6.SpawnChance, config)
			local v7 = difficulty ~= "Hard" and 1 or config.HardPenalty
			local spawnChance = math.sqrt(v6.SpawnChance)
			local v8 = gaussian(v6.SpawnChance, slot.TargetSpawn, slot.SpawnSpread) -- equivalent call inferred; original call site unknown
			local v9 = spawnChance * v8 * v7

			if v9 > 0 then
				table.insert(result, {
					{
						AssetId = v6.AssetId,
						SpawnChance = v6.SpawnChance,
						ZoneId = v5.Id,
						ZoneIndex = i2,
						Difficulty = difficulty
					},
					v9
				})
			end
		end
	end

	return result
end

local function isValidRecipe(list, config)
	if #list ~= #config.Slots then
		return false
	end

	local v5 = {}
	local v6 = {
		Easy = 0,
		Medium = 0,
		Hard = 0,
		Excluded = 0
	}

	for _, v7 in list do
		if config.AllowDuplicatePets or not v5[v7.AssetId] then
			v5[v7.AssetId] = true
			local difficulty = v7.Difficulty
			v6[difficulty] += 1
		else
			return false
		end
	end

	if config.RequireEasyPet and v6.Easy < 1 or v6.Easy > config.MaxEasyPets then
		return false
	end

	return not (v6.Hard > config.MaxHardPets) and not (v6.Medium + v6.Hard > config.MaxNonEasyPets)
end

local function rollRecipe(result, p)
	local config = result.Config

	for _ = 1, config.MaxRecipeAttempts do
		local v5 = {}
		local result2 = {}
		local v6 = true

		for i = 1, #config.Slots do
			local v7 = rollWeighted(buildSlotPool(result, i, v5), p)

			if v7 == nil then
				v6 = false
				break
			else
				table.insert(result2, v7)
				v5[v7.AssetId] = true
			end
		end

		if v6 and isValidRecipe(result2, config) then
			return result2
		end
	end

	return nil
end

function v4.GenerateRecipe(p: string, p2, p3)
	t.strict(t.string)(p)
	local v5 = p3 or v4.ResolveConfig()
	local success, result = pcall(newContext, p, v5)

	if not success then
		return nil, (tostring(result))
	end

	local v6 = rollRecipe(result, p2 or random)

	if v6 == nil then
		return nil, (`no valid recipe for {p} after {v5.MaxRecipeAttempts} attempts`)
	end

	return v6, nil
end

local function fallbackAssetIds(p: string, object, config)
	local success, result = pcall(newContext, p, config)

	if not success then
		v3:AtError():Log((`Rift fallback recipe unavailable for {p}: {result}`))
		return {}
	end

	local assetIds = {}

	for i = result.Bottom, result.Top do
		for _, v5 in result.PetsByRung[i] do
			if v4.IsEligible(v5, config) then
				table.insert(assetIds, v5.AssetId)
			end
		end
	end

	local result2 = {}

	for _ = 1, math.min(#config.Slots, #assetIds) do
		local integer = object:NextInteger(1, #assetIds)
		table.insert(result2, assetIds[integer])
		table.remove(assetIds, integer)
	end

	return result2
end

function v4.RollAssetIds(p: string, p2)
	t.strict(t.string)(p)
	local v5 = p2 or random
	local config = v4.ResolveConfig()

	if not RiftFlags.RecipesEnabled:Get() then
		return (fallbackAssetIds(p, v5, config))
	end

	local recipe, v6 = v4.GenerateRecipe(p, v5, config)

	if recipe == nil then
		v3:AtWarning():Log((`Rift recipe engine fell back for {p}: {v6}`))
		return (fallbackAssetIds(p, v5, config))
	end

	local assetIds = {}

	for _, v7 in recipe do
		table.insert(assetIds, v7.AssetId)
	end

	return assetIds
end

function v4.Describe(items, p)
	local v5 = p or v4.ResolveConfig()
	local v6 = {}

	for _, item in items do
		local difficulty = v4.DifficultyOf(item, v5)
		table.insert(v6, not difficulty and "?" or v[difficulty])
	end

	table.sort(v6, function(a: string, b: string)
		return v2[a] < v2[b]
	end)
	return table.concat(v6)
end

function v4.DescribeCandidates(items)
	local v5 = {}

	for _, item in items do
		table.insert(v5, v[item.Difficulty])
	end

	table.sort(v5, function(a: string, b: string)
		return v2[a] < v2[b]
	end)
	return table.concat(v5)
end

function v4.Simulate(bannerId: string, runs: number, p3: number?)
	t.strict(t.string)(bannerId)
	t.strict(t.numberPositive)(runs)
	local config = v4.ResolveConfig()
	local result = {
		BannerId = bannerId,
		Runs = runs,
		Failures = 0,
		NonZonePicks = 0,
		Patterns = {},
		Distinct = 0,
		SlotPicks = {},
		Bands = {
			Easy = 0,
			Medium = 0,
			Hard = 0,
			Excluded = 0
		},
		PoolBottom = nil,
		PoolTop = nil,
		PoolSize = 0,
		Error = nil
	}

	for i = 1, #config.Slots do
		result.SlotPicks[i] = {}
	end

	local success, result2 = pcall(newContext, bannerId, config)

	if not success then
		result.Error = tostring(result2)
		return result
	end

	result.PoolBottom = result2.Ladder[result2.Bottom].Id
	result.PoolTop = result2.Ladder[result2.Top].Id

	for i = result2.Bottom, result2.Top do
		for _, v5 in result2.PetsByRung[i] do
			local v6 = config.Excluded[v5.AssetId] == true and "Excluded" or v4.GetDifficulty(v5.SpawnChance, config)
			result.Bands[v6] += 1
			result.PoolSize += 1
		end
	end

	local random2

	if p3 == nil then
		random2 = Random.new()
	else
		random2 = Random.new(p3)
	end

	local v5 = {}

	for _ = 1, runs do
		local v6 = rollRecipe(result2, random2)

		if v6 == nil then
			result.Failures += 1
		else
			local describeCandidates = v4.DescribeCandidates(v6)
			result.Patterns[describeCandidates] = (result.Patterns[describeCandidates] or 0) + 1
			local assetIds = {}

			for k, v7 in v6 do
				local slotPick = result.SlotPicks[k]
				slotPick[v7.AssetId] = (slotPick[v7.AssetId] or 0) + 1
				table.insert(assetIds, v7.AssetId)

				if not v4.IsZonePet(v7.AssetId) then
					result.NonZonePicks += 1
				end
			end

			table.sort(assetIds)
			v5[table.concat(assetIds, "|")] = true
		end
	end

	for _ in v5 do
		result.Distinct += 1
	end

	return result
end

return table.freeze(v4)