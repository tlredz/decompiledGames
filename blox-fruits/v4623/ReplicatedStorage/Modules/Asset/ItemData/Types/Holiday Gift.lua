local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)

-- equivalent calls inferred from this helper; original call sites unknown
local function getMaxStack(p: number)
	local unwrapped = ItemConfig.match(p):unwrap()
	local maxStack = unwrapped.Inventory.MaxStack
	assert(maxStack, (`bad maxStack for {unwrapped.Index.StorageKey}`))
	return maxStack
end

local function getRarityValue(p: number)
	local unwrapped = ItemConfig.match(p):unwrap()
	local rarity = unwrapped.Quality.Rarity
	assert(rarity, (`bad rarity for {unwrapped.Index.StorageKey}`))
	return RarityUtil.matchRarity(rarity):unwrap().Value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getArgs(p: number)
	local rarityValue = getRarityValue(p)
	local maxStack = getMaxStack(p) -- equivalent call inferred; original call site unknown
	return { rarityValue, maxStack }
end

return {
	["Admin Holiday Gift"] = getArgs(IdMap.Tool["Admin Holiday Gift"]),
	["Mythical Holiday Gift"] = getArgs(IdMap.Tool["Mythical Holiday Gift"]),
	["Legendary Holiday Gift"] = getArgs(IdMap.Tool["Legendary Holiday Gift"]),
	["Rare Holiday Gift"] = getArgs(IdMap.Tool["Rare Holiday Gift"]),
	["Uncommon Holiday Gift"] = getArgs(IdMap.Tool["Uncommon Holiday Gift"])
}