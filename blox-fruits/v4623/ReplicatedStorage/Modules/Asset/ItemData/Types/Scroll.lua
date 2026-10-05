require(game.ReplicatedStorage.Economy.ItemId)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local Scroll = {}

for _, v in ItemConfig.Query.select({
	Index = {
		IdType = "Scroll"
	}
}) do
	local maxStack = v.Inventory.MaxStack
	assert(maxStack, (`bad maxStack for "{v.Index.StorageKey}"`))
	local rarity = v.Quality.Rarity
	assert(rarity, (`bad rarity for "{v.Index.StorageKey}"`))
	local unwrapped = RarityUtil.matchRarity(rarity):unwrap()
	Scroll[v.Index.StorageKey] = { unwrapped.Value, maxStack }
end

return Scroll