local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local EggSkins = require(ReplicatedStorage.Data.EggSkins)
local RiftFlags = require(ReplicatedStorage.Shared.Flags.RiftFlags)
local banners = {
	{
		Id = "Verdant",
		DisplayName = "Riftborn",
		EggSkin = "Riftborn",
		Weight = 55,
		From = "Volcano",
		To = "Abyss Ocean",
		Pets = {
			{
				AssetId = "Rift Eye",
				Weight = 45
			},
			{
				AssetId = "Voidmaw",
				Weight = 36
			},
			{
				AssetId = "Ventinal",
				Weight = 15
			},
			{
				AssetId = "Wendigo",
				Weight = 3.5
			},
			{
				AssetId = "World Eater",
				Weight = 0.5
			}
		}
	},
	{
		Id = "Umbral",
		DisplayName = "Riftbeasts",
		EggSkin = "Riftbeasts",
		Weight = 40,
		From = "Prehistoric",
		To = "Cosmic",
		Pets = {
			{
				AssetId = "Void Angler",
				Weight = 45
			},
			{
				AssetId = "Riftwing",
				Weight = 36
			},
			{
				AssetId = "Dreadclaw",
				Weight = 15
			},
			{
				AssetId = "Mawbreaker",
				Weight = 3.5
			},
			{
				AssetId = "Void Serpent",
				Weight = 0.5
			}
		}
	},
	{
		Id = "Radiant",
		DisplayName = "Shattered Rift",
		EggSkin = "ShatteredRift",
		Weight = 5,
		From = "Cherry Blossom",
		To = "Titan Temple",
		Pets = {
			{
				AssetId = "Shardling",
				Weight = 45
			},
			{
				AssetId = "Shattered Ram",
				Weight = 36
			},
			{
				AssetId = "Shardwing",
				Weight = 15
			},
			{
				AssetId = "Shattered Drake",
				Weight = 3.5
			},
			{
				AssetId = "Shattered Colossus",
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
	RotationSeconds = function()
		return RiftFlags.RotationSeconds:Get()
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

function v4.GetBannerWeight(p: string)
	local v5 = RiftFlags.BannerWeights:Get()[p]

	if v5 ~= nil then
		return v5
	end

	local v6 = v2[p]

	if v6 then
		return v6.Weight
	end

	return 0
end

function v4.GetBannerRange(p: string)
	local v5 = v2[p]
	assert(v5 ~= nil, (`unknown rift banner {p}`))
	local v6 = RiftFlags.BannerRanges:Get()[p]
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
	local v6 = RiftFlags.SlotOverrides:Get()[tostring(p)]

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
	local v5 = RiftFlags.PetWeights:Get()[v4.PetOverrideKey(p, p2)]

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

local function petsByWeight(p: string)
	local v5 = v2[p]

	if v5 == nil then
		return {}
	end

	local result = {}

	for _, pet in v5.Pets do
		local petWeight = v4.GetPetWeight(p, pet.AssetId)

		if petWeight > 0 then
			table.insert(result, {
				AssetId = pet.AssetId,
				Weight = petWeight
			})
		end
	end

	table.sort(result, function(a, b)
		if a.Weight == b.Weight then
			return a.AssetId < b.AssetId
		end

		return a.Weight > b.Weight
	end)
	return result
end

function v4.ChasePetId(p: string)
	local v5 = petsByWeight(p)
	local v6 = v5[#v5]

	if v6 then
		return v6.AssetId
	end

	return nil
end

function v4.PityPool(p: string)
	local v5 = petsByWeight(p)
	local v6 = RiftFlags.PityWeights:Get()
	local v7 = math.min(#v6, #v5)
	local result = {}

	for i = 1, v7 do
		table.insert(result, {
			AssetId = v5[#v5 - v7 + i].AssetId,
			Weight = v6[i]
		})
	end

	return result
end

function v4.RollPityPet(p: string, object)
	local pityPool = v4.PityPool(p)
	local total = 0

	for _, v5 in pityPool do
		if v5.Weight > 0 then
			total += v5.Weight
		end
	end

	if total <= 0 then
		return v4.ChasePetId(p)
	end

	local v5 = object:NextNumber() * total
	local total2 = 0
	local assetId = nil

	for _, v6 in pityPool do
		if v6.Weight <= 0 then
			continue
		end

		total2 += v6.Weight
		assetId = v6.AssetId

		if v5 <= total2 then
			return v6.AssetId
		end
	end

	return assetId
end

function v4.CurrentPeriod()
	return (math.floor(Workspace:GetServerTimeNow() / v4.RotationSeconds()))
end

function v4.BannerIdForPeriod(p: number)
	local total = 0

	for _, v5 in banners do
		total += v4.GetBannerWeight(v5.Id)
	end

	if total <= 0 then
		return banners[1].Id
	end

	local v5 = Random.new(p):NextNumber() * total
	local total2 = 0

	for _, v6 in banners do
		total2 += v4.GetBannerWeight(v6.Id)

		if v5 <= total2 then
			return v6.Id
		end
	end

	return banners[#banners].Id
end

function v4.CurrentBannerId()
	return v4.BannerIdForPeriod(v4.CurrentPeriod())
end

function v4.SecondsUntilRotation()
	local serverTimeNow = Workspace:GetServerTimeNow()
	local rotationSeconds = v4.RotationSeconds()
	return rotationSeconds - serverTimeNow % rotationSeconds
end

return table.freeze(v4)