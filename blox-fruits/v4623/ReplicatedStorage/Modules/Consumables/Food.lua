local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)

-- equivalent calls inferred from this helper; original call sites unknown
local function getMaxStack(fishKebab: number)
	local unwrapped = ItemConfig.match(fishKebab):unwrap()
	local maxStack = unwrapped.Inventory.MaxStack
	assert(maxStack, (`bad maxStack for {unwrapped.Index.StorageKey}`))
	return maxStack
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRarity(fishKebab: number)
	local unwrapped = ItemConfig.match(fishKebab):unwrap()
	local rarity = unwrapped.Quality.Rarity
	assert(rarity, (`bad rarity for {unwrapped.Index.StorageKey}`))
	return rarity
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDisplayName(fishKebab: number)
	local unwrapped = ItemConfig.match(fishKebab):unwrap()
	return unwrapped.Display.Name or unwrapped.Index.StorageKey
end

local function food(data)
	return {
		EffectType = "Food",
		DisplayName = data.DisplayName,
		Rarity = assert(RarityUtil.tryGetRarity(data.Rarity)).Value,
		Stats = data.Stats,
		Description = data.Description,
		MaxStack = data.MaxStack
	}
end

local v = {
	["Fish Kebab"] = food({
		DisplayName = getDisplayName(IdMap.Consumable["Fish Kebab"]),
		Rarity = getRarity(IdMap.Consumable["Fish Kebab"]),
		Description = function(_)
			return "+60% rapid PvE health regen for 500% hp"
		end,
		Stats = function(_)
			return {
				HealthRegenFood = 0.6
			}
		end,
		MaxStack = getMaxStack(IdMap.Consumable["Fish Kebab"])
	})
}
local food2 = {}

for k, v4 in pairs(v) do
	assert(v4.Rarity, "bad foodIn.Rarity")
	assert(v4.MaxStack, "bad foodIn.MaxStack")
	food2[k] = {
		StorageName = k,
		ToolName = v4.ToolName or k,
		DisplayName = v4.DisplayName,
		Type = "Food",
		EffectType = assert(v4.EffectType),
		Description = v4.Description,
		MaxStack = v4.MaxStack,
		Rarity = v4.Rarity,
		Cost = v4.Cost,
		Stats = v4.Stats
	}
end

table.freeze(food2)
local Food = {
	Food = food2
}
table.freeze(Food)
return Food