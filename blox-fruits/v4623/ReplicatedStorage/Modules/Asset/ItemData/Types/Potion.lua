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

local Potions = require(game.ReplicatedStorage.Modules.Consumables.Potions)
local Potion = {}

for _, potion in pairs(Potions.Potions) do
	local args = getArgs(IdMap.Potion[potion.StorageName]) -- equivalent call inferred; original call site unknown
	assert(
		args[1] == potion.Rarity,
		(`Mismatch rarity for "{potion.StorageName}": expected {potion.Rarity}, got {args[1]}`)
	)
	assert(
		args[2] == potion.MaxStack,
		(`Mismatch maxStack for "{potion.StorageName}": expected {potion.MaxStack}, got {args[2]}`)
	)
	Potion[potion.StorageName] = { potion.Rarity, potion.MaxStack }
end

return Potion