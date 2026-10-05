local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local EggSkins = require(ReplicatedStorage.Data.EggSkins)
local ScrambleTradeInFlags = require(ReplicatedStorage.Shared.Flags.ScrambleTradeInFlags)
local banners = {
	{
		Id = "Biohazard",
		DisplayName = "Biohazard Pets",
		EggSkin = "Biohazard",
		Weight = 42.5,
		From = "Cosmic",
		To = "Cherry Blossom",
		Pets = {
			{
				AssetId = "Toxic Rat",
				Weight = 45
			},
			{
				AssetId = "Radcoon",
				Weight = 36
			},
			{
				AssetId = "Toucax",
				Weight = 15
			},
			{
				AssetId = "Nuceodille",
				Weight = 3.5
			},
			{
				AssetId = "Nuclear Mantis",
				Weight = 0.5
			}
		}
	},
	{
		Id = "Experimental",
		DisplayName = "Experimental Pets",
		EggSkin = "Experimental",
		Weight = 35.5,
		From = "Cherry Blossom",
		To = "Titan Temple",
		Pets = {
			{
				AssetId = "Wheel Hamster",
				Weight = 45
			},
			{
				AssetId = "Stacked Turtle",
				Weight = 36
			},
			{
				AssetId = "Three Headed Chicken",
				Weight = 15
			},
			{
				AssetId = "Eyeball Crab",
				Weight = 3.5
			},
			{
				AssetId = "Dreadstinger",
				Weight = 0.5
			}
		}
	},
	{
		Id = "UnstableDNA",
		DisplayName = "Unstable DNA",
		EggSkin = "UnstableDNA",
		Weight = 22,
		From = "Titan Temple",
		To = "Light Dark",
		Pets = {
			{
				AssetId = "Frogfly",
				Weight = 45
			},
			{
				AssetId = "Spiderpig",
				Weight = 36
			},
			{
				AssetId = "Sharkodile",
				Weight = 15
			},
			{
				AssetId = "Rhinobear",
				Weight = 3.5
			},
			{
				AssetId = "Octophant",
				Weight = 0.5
			}
		}
	}
}
local v2 = {}
local recipeSlots = {
	{
		Biomes = 4,
		TargetSpawn = 30,
		SpawnSpread = 9
	},
	{
		Biomes = 3,
		TargetSpawn = 16,
		SpawnSpread = 9
	},
	{
		Biomes = 2,
		TargetSpawn = 14,
		SpawnSpread = 9
	}
}

for _, v4 in banners do
	v2[v4.Id] = v4
end

local v4 = {
	RotationOverrideAttribute = "ScrambleTradeInRotationOverride",
	RotationSeconds = function()
		return ScrambleTradeInFlags.RotationSeconds:Get()
	end,
	RequirementCount = #recipeSlots,
	RecipeSlots = recipeSlots,
	Banners = banners,
	GetBanner = function(p: string)
		return v2[p]
	end,
	BannerIds = function()
		local ids = {}

		for _, v5 in banners do
			table.insert(ids, v5.Id)
		end

		return ids
	end,
	GetBannerDisplayName = function(p: string)
		local v5 = v2[p]

		if v5 then
			return v5.DisplayName
		end

		return p
	end,
	GetBannerEggSkin = function(p: string)
		local v5 = v2[p]

		if v5 then
			return v5.EggSkin
		end

		return nil
	end
}

function v4.GetBannerEggIcon(p: string)
	local v5 = EggSkins.Get(v4.GetBannerEggSkin(p))

	if v5 then
		return v5.Icon
	end

	return nil
end

local function effectiveBannerWeights()
	local v5 = ScrambleTradeInFlags.BannerWeights:Get()
	local result = {}
	local total = 0

	for _, v6 in banners do
		local v7 = v5[v6.Id] or v6.Weight
		result[v6.Id] = v7
		total += v7
	end

	if total <= 0 then
		for _, v6 in banners do
			result[v6.Id] = v6.Weight
		end
	else
		for _, v6 in banners do
			if not (total < result[v6.Id] * 2) then
				continue
			end

			for _, v7 in banners do
				result[v7.Id] = v7.Weight
			end

			return result
		end
	end

	return result
end

function v4.GetBannerWeight(p: string)
	return effectiveBannerWeights()[p] or 0
end

function v4.GetBannerRange(p: string)
	local v5 = v2[p]
	assert(v5 ~= nil, (`unknown rift banner {p}`))
	local v6 = ScrambleTradeInFlags.BannerRanges:Get()[p]
	local from

	if v6 == nil or v6.From == nil then
		from = v5.From
	else
		from = v6.From
	end

	if v6 == nil or v6.To == nil then
		return from, v5.To
	end

	return from, v6.To
end

function v4.GetRecipeSlot(p: number)
	local v5 = recipeSlots[p]
	assert(v5 ~= nil, (`the Rift has no recipe slot {p}`))
	local v6 = ScrambleTradeInFlags.SlotOverrides:Get()[tostring(p)]

	if v6 == nil then
		return v5
	end

	return {
		Biomes = v6.Biomes or v5.Biomes,
		TargetSpawn = v6.TargetSpawn or v5.TargetSpawn,
		SpawnSpread = v6.SpawnSpread or v5.SpawnSpread
	}
end

function v4.PetOverrideKey(p: string, p2: string)
	return p .. ":" .. p2
end

function v4.GetPetWeight(p: string, p2: string)
	local v5 = ScrambleTradeInFlags.PetWeights:Get()[v4.PetOverrideKey(p, p2)]

	if v5 ~= nil then
		return v5
	end

	local v6 = v2[p]

	if v6 == nil then
		return 0
	end

	for _, pet in v6.Pets do
		if pet.AssetId == p2 then
			return pet.Weight
		end
	end

	return 0
end

function v4.BannerContainsPet(p: string, p2: string)
	local v5 = v2[p]

	if v5 == nil then
		return false
	end

	for _, pet in v5.Pets do
		if pet.AssetId == p2 then
			return true
		end
	end

	return false
end

function v4.RollPet(p: string, object)
	local v5 = v2[p]

	if v5 == nil then
		return nil
	end

	local petWeights = {}
	local total = 0

	for k, pet in v5.Pets do
		local petWeight = v4.GetPetWeight(p, pet.AssetId)
		petWeights[k] = petWeight

		if petWeight > 0 then
			total += petWeight
		end
	end

	if total <= 0 then
		return nil
	end

	local v6 = object:NextNumber() * total
	local total2 = 0
	local assetId = nil

	for k, pet in v5.Pets do
		local v7 = petWeights[k]

		if v7 <= 0 then
			continue
		end

		total2 += v7
		assetId = pet.AssetId

		if v6 <= total2 then
			return pet.AssetId
		end
	end

	return assetId
end

function v4.ChasePetId(p: string)
	local v5 = v2[p]
	local v6 = v5 and v5.Pets[#v5.Pets]

	if v6 then
		return v6.AssetId
	end

	return nil
end

function v4.PityPool(p: string)
	local chasePetId = v4.ChasePetId(p)

	if chasePetId then
		return {
			{
				AssetId = chasePetId,
				Weight = 1
			}
		}
	end

	return {}
end

function v4.RollPityPet(p: string, _)
	return v4.ChasePetId(p)
end

local function rotationOverride()
	local attribute = Workspace:GetAttribute(v4.RotationOverrideAttribute)

	if typeof(attribute) ~= "string" then
		return nil, nil
	end

	local v5, v6 = string.match(attribute, "^([%d%.]+)|([%w]+)$")
	local v7 = tonumber(v5)

	if v7 == nil or v7 <= 0 or v2[v6] == nil then
		return nil, nil
	end

	return v7, v6
end

function v4.CurrentPeriod()
	local rotationSeconds = v4.RotationSeconds()
	local serverTimeNow = Workspace:GetServerTimeNow()
	local attribute = Workspace:GetAttribute(v4.RotationOverrideAttribute)
	local v5

	if typeof(attribute) == "string" then
		local v6, v7 = string.match(attribute, "^([%d%.]+)|([%w]+)$")
		v5 = tonumber(v6)

		if v5 == nil or v5 <= 0 or v2[v7] == nil then
			v5 = nil
		end
	end

	if v5 == nil or not (v5 <= serverTimeNow) then
		return (math.floor(serverTimeNow / rotationSeconds))
	end

	return math.floor(v5 / rotationSeconds) + math.floor((serverTimeNow - v5) / rotationSeconds)
end

local ids = {}
local v5 = ""
local v6 = -1
local v7 = 0

function v4.BannerIdForPeriod(p: number)
	local rotationSeconds = v4.RotationSeconds()
	local v8 = {
		v4.GetBannerWeight(banners[1].Id),
		v4.GetBannerWeight(banners[2].Id),
		v4.GetBannerWeight(banners[3].Id)
	}
	local attribute = Workspace:GetAttribute(v4.RotationOverrideAttribute)
	local v9, v10

	if typeof(attribute) == "string" then
		local v11
		v11, v9 = string.match(attribute, "^([%d%.]+)|([%w]+)$")
		v10 = tonumber(v11)

		if v10 == nil or v10 <= 0 or v2[v9] == nil then
			v10 = nil
			v9 = nil
		end
	end

	local v11

	if v10 ~= nil then
		v11 = math.floor(v10 / rotationSeconds)
	end

	local v12 = string.format(
		"%d:%.9g:%.9g:%.9g:%s:%s",
		rotationSeconds,
		v8[1],
		v8[2],
		v8[3],
		tostring(v10),
		(tostring(v9))
	)

	if v12 ~= v5 then
		v5 = v12
		table.clear(ids)
		v7 = math.floor(DateTime.fromUniversalTime(2026, 9, 1, 0, 0, 0).UnixTimestamp / rotationSeconds)
		v6 = v7 - 1
	end

	if p < v7 then
		return banners[p % #banners + 1].Id
	end

	for i = v6 + 1, p do
		local random = Random.new(i)
		local index

		if v11 == nil or i ~= v11 then
			if i == v7 then
				local v13 = v8[1] + v8[2] + v8[3]
				local v14 = random:NextNumber() * v13
				index = v14 < v8[1] and 1 or v14 < v8[1] + v8[2] and 2 or 3
			else
				local index2 = table.find(v4.BannerIds(), ids[i - 1])
				local v13 = {}

				if index2 ~= 1 then
					table.insert(v13, 1)
				end

				if index2 ~= 2 then
					table.insert(v13, 2)
				end

				if index2 ~= 3 then
					table.insert(v13, 3)
				end

				local v14 = v13[1]
				index = v13[2]
				local v15 = v8[v14] + v8[index]

				if v15 <= 0 then
					index = v14
				elseif random:NextNumber() < v8[v14] / v15 then
					index = v14
				end
			end
		else
			index = table.find(v4.BannerIds(), v9)
		end

		ids[i] = banners[index].Id
	end

	v6 = math.max(v6, p)
	return ids[p]
end

function v4.CurrentBannerId()
	return v4.BannerIdForPeriod(v4.CurrentPeriod())
end

function v4.SecondsUntilRotation()
	local serverTimeNow = Workspace:GetServerTimeNow()
	local rotationSeconds = v4.RotationSeconds()
	local attribute = Workspace:GetAttribute(v4.RotationOverrideAttribute)
	local v8

	if typeof(attribute) == "string" then
		local v9, v10 = string.match(attribute, "^([%d%.]+)|([%w]+)$")
		v8 = tonumber(v9)

		if v8 == nil or v8 <= 0 or v2[v10] == nil then
			v8 = nil
		end
	end

	if v8 == nil or not (v8 <= serverTimeNow) then
		return rotationSeconds - serverTimeNow % rotationSeconds
	end

	return rotationSeconds - (serverTimeNow - v8) % rotationSeconds
end

return table.freeze(v4)