local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Material = {}

for k, v in ItemConfig.Query.select({
	Index = {
		IdType = "Material"
	}
}) do
	local maxStack = v.Inventory.MaxStack
	assert(maxStack, (`bad maxStack for material "{k}"`))
	local rarityValue = v.Quality.RarityValue
	assert(rarityValue, (`no rarity found for material "{k}"`))
	Material[v.Index.StorageKey] = { rarityValue, maxStack }
end

return Material