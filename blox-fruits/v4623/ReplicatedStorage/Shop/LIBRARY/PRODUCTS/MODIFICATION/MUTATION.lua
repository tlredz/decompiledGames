local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates

local function fn(p: number)
	local unwrapped = ItemConfig.match(p):unwrap()
	local economy = unwrapped.Economy

	if not economy then
		print(unwrapped)
	end

	assert(economy, (`bad product for {unwrapped.Index.DebugLabel}`))
	assert(economy.ProductId, (`missing product id for {unwrapped.Index.DebugLabel}`))
	local itemId = ItemConfig.Query.selectOne({
		Index = {
			StorageKey = unwrapped.Index.StorageKey,
			IdType = "Mutation"
		}
	}):unwrap().Index.ItemId
	local unwrapped2 = ItemConfig.Query.selectOne({
		Variant = {
			Mutation = itemId
		}
	}):unwrap()
	local variantOf = unwrapped2.Variant.VariantOf
	assert(variantOf, (`bad variant: "{unwrapped2.Index.DebugLabel}"`))
	local unwrapped3 = ItemConfig.match(variantOf):unwrap()
	return templates.Simple.new(
		unwrapped.Index.ItemId,
		{ templates2.Simple.new(templates3.Item.fruitMutation(itemId)) },
		{
			templates5.Item.doesNotOwnFruitMutation(itemId, { "Redeem", "Purchase" }),
			templates5.Item.ownsPermanentFruit(
				unwrapped3.Index.StorageKey,
				Economy.excludeFilters({ "Store", "Trade" })
			)
		},
		templates4.Simple.newRobuxItem(unwrapped.Index.StorageKey, "FruitMutation", false)
	)
end

return (table.freeze({
	fn(IdMap.Redeemable.TIGERMUTWerewolf),
	fn(IdMap.Redeemable.KITSUNEMUTKyukon),
	fn(IdMap.Redeemable.YETIMUTFiend)
}))