local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sellRewards = require(ReplicatedStorage.Shared.Flags.GameplayBalance).SellRewards
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage2.Data.Assets)
local AssetEarnings = require(ReplicatedStorage2.Shared.Util.AssetEarnings)
local AssetGender = require(ReplicatedStorage2.Shared.Util.AssetGender)
local AssetItem = require(ReplicatedStorage2.Shared.Types.AssetItem)
local AssetPalette = require(ReplicatedStorage2.Shared.Util.AssetPalette)
local Assets2 = require(ReplicatedStorage2.Data.Assets)
local personalities = Assets2.Personalities
local Numbers = require(ReplicatedStorage2.Shared.Utils.Numbers)
local addCommas = Numbers.AddCommas
local t = require(ReplicatedStorage2.Packages.t)
local strict = t.strict(t.string)
local AssetItems = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function catalogEntry(p: string)
	return Assets.Directory[p]
end

local function isNamedMutation(value)
	return typeof(value) == "string" and value ~= "" and value ~= "None"
end

local function settled(data)
	local mutations = {}

	for _, mutation in ipairs(data.Mutations) do
		local v

		if typeof(mutation) == "string" and mutation ~= "" then
			v = mutation ~= "None"
		else
			v = false
		end

		if v then
			table.insert(mutations, mutation)
		end
	end

	local settleFields = AssetPalette.SettleFields(data.Category, data.EyeColor, data.ColorSeed, data.ColorIndex)
	local gender = AssetGender.Settle(data.Category, data.Gender) == "Male" and "Male" or "Female"
	local v2 = {
		Category = data.Category,
		Mutations = mutations,
		BaseMutation = 0,
		Scale = 0,
		Gender = 0,
		EyeColor = 0,
		ColorSeed = 0,
		ColorIndex = 0,
		IsFavorite = 0,
		GeneratedMoney = 0,
		LastTick = 0,
		PendingEggName = 0,
		Claimed = 0,
		LuckyBlockUnlockTimestamp = 0,
		LuckyBlockUnlockDuration = 0,
		LuckyBlockInstantUnlock = 0,
		InFuse = 0,
		SpecialLuckyBlockColumn = 0,
		SpecialLuckyBlockCapturedAt = 0,
		Personality = 0,
		HasBeenFirstPlaced = 0,
		IsStolenDNA = 0,
		CreatorTemporary = 0
	}
	local baseMutation = data.BaseMutation
	local v3

	if typeof(baseMutation) == "string" and baseMutation ~= "" then
		v3 = baseMutation ~= "None"
	else
		v3 = false
	end

	local baseMutation2

	if v3 then
		baseMutation2 = data.BaseMutation
	else
		baseMutation2 = mutations[1]
	end

	v2.BaseMutation = baseMutation2
	v2.Scale = data.Scale
	v2.Gender = gender
	v2.EyeColor = settleFields.EyeColor
	v2.ColorSeed = settleFields.ColorSeed
	v2.ColorIndex = settleFields.ColorIndex
	v2.IsFavorite = data.IsFavorite
	v2.GeneratedMoney = data.GeneratedMoney
	v2.LastTick = data.LastTick
	v2.PendingEggName = data.PendingEggName
	v2.Claimed = data.Claimed
	v2.LuckyBlockUnlockTimestamp = data.LuckyBlockUnlockTimestamp
	v2.LuckyBlockUnlockDuration = data.LuckyBlockUnlockDuration
	v2.LuckyBlockInstantUnlock = data.LuckyBlockInstantUnlock
	v2.InFuse = data.InFuse or false
	v2.SpecialLuckyBlockColumn = data.SpecialLuckyBlockColumn
	v2.SpecialLuckyBlockCapturedAt = data.SpecialLuckyBlockCapturedAt
	v2.Personality = data.Personality
	v2.HasBeenFirstPlaced = data.HasBeenFirstPlaced
	v2.IsStolenDNA = data.IsStolenDNA
	v2.CreatorTemporary = data.CreatorTemporary
	return v2
end

function AssetItems.Encode(p)
	return (settled(p))
end

function AssetItems.Decode(p)
	return (settled(p))
end

function AssetItems.WeightKg(p)
	assert(AssetItem.AssetItemData(p))
	local category = p.Category
	return Assets.Directory[category].ModelWeight * math.max(p.Scale, 0) ^ sellRewards.WEIGHT_SCALE_POWER
end

function AssetItems.WeightLabel(p)
	local v = math.round(AssetItems.WeightKg(p) * 100)
	return (`{addCommas((math.max(v / 100, 0)))}Kg`)
end

function AssetItems.SalePrice(p)
	assert(AssetItem.AssetItemData(p))
	return AssetEarnings.RatePerSecond(p) * sellRewards.SALE_SECONDS_OF_INCOME
end

function AssetItems.IndexMoneyReward(category: string)
	local v = {
		Category = category,
		Mutations = {},
		Scale = 1,
		Personality = personalities.Personalities.Normal,
		HasBeenFirstPlaced = true
	}
	return (math.round(AssetEarnings.MutationOnlyRatePerSecond(v) * sellRewards.INDEX_REWARD_SECONDS))
end

function AssetItems.IndexSpeedReward(p: string)
	return Assets.Directory[p].IndexSpeedReward
end

function AssetItems.RarityRankForCategory(p: string)
	strict(p)
	local v = catalogEntry(p) -- equivalent call inferred; original call site unknown
	assert(v ~= nil, (`Asset catalog has no entry named {p}`))
	return v.Rarity.Rank
end

function AssetItems.ProfileIncomePerSecond(p, data)
	local inventory = data.Inventory
	local equippedAssets = data.EquippedAssets

	if typeof(inventory) ~= "table" or typeof(equippedAssets) ~= "table" then
		return 0
	end

	local gamepasses

	if typeof(data.Gamepasses) == "table" then
		gamepasses = data.Gamepasses
	end

	local products

	if typeof(data.Products) == "table" then
		products = data.Products
	end

	local total = 0

	for _, equippedAsset in ipairs(equippedAssets) do
		local v = inventory[equippedAsset]

		if typeof(v) ~= "table" then
			continue
		end

		local v2 = settled(v)
		total += math.max(AssetEarnings.LiveRatePerSecond(v2, gamepasses, products, p), 0)
	end

	return total
end

return AssetItems