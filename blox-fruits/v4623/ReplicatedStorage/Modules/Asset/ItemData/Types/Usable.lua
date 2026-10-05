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

local Usable = {
	["Red Flower"] = getArgs(IdMap.Tool["Flower 1"]),
	["Blue Flower"] = getArgs(IdMap.Tool["Flower 2"]),
	["Yellow Flower"] = getArgs(IdMap.Tool["Flower 3"]),
	["Fist of Darkness"] = getArgs(IdMap.Tool["Fist of Darkness"]),
	["God's Chalice"] = getArgs(IdMap.Tool["God's Chalice"]),
	["Sweet Chalice"] = getArgs(IdMap.Tool["Sweet Chalice"]),
	["Special Microchip"] = getArgs(IdMap.Tool["Special Microchip"]),
	["Dragon "] = { 5, 1000000000, false }
}
local rarityValue = getRarityValue(IdMap.Redeemable["Dragon Token (East)"])
local maxStack = getMaxStack(IdMap.Redeemable["Dragon Token (East)"]) -- equivalent call inferred; original call site unknown
Usable["Dragon Token (East)"] = { rarityValue, maxStack, false }
local rarityValue2 = getRarityValue(IdMap.Redeemable["Dragon Token (West)"])
local maxStack2 = getMaxStack(IdMap.Redeemable["Dragon Token (West)"]) -- equivalent call inferred; original call site unknown
Usable["Dragon Token (West)"] = { rarityValue2, maxStack2, false }
local rarityValue3 = getRarityValue(IdMap.Redeemable["Dragon Token (Tradable)"])
local maxStack3 = getMaxStack(IdMap.Redeemable["Dragon Token (Tradable)"]) -- equivalent call inferred; original call site unknown
Usable["Dragon Token (Tradable)"] = { rarityValue3, maxStack3, true }
local rarityValue4 = getRarityValue(IdMap.Redeemable["Dragon Token (Physical)"])
local maxStack4 = getMaxStack(IdMap.Redeemable["Dragon Token (Physical)"]) -- equivalent call inferred; original call site unknown
Usable["Dragon Token (Physical)"] = { rarityValue4, maxStack4, false }
return Usable