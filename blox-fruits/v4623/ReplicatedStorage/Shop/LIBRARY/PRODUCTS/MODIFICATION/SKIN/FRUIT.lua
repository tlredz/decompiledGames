require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.SaleService)
local IdMap = require(game.ReplicatedStorage.IdMap)
local v = {
	[IdMap.Redeemable.FALCSKINparrot] = { "EagleChromatics2025" }
}
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates

function newEconomyItem(p: number, p2, items, _: number?, _: boolean?)
	local simples = {}
	local v2 = {}
	local clone

	if v[p] then
		clone = table.clone(v[p])
		assert(clone, "bad sales")

		for _, v3 in clone do
			table.insert(v2, templates5.saleIsActive(v3, { "Purchase" }, nil))
		end
	end

	for _, item in items do
		table.insert(v2, templates5.Item.doesNotOwnFruitSkin(item, Economy.excludeFilters({ "Store" })))
		local unwrapped = ItemConfig.match(item):unwrap()
		assert(unwrapped.Skin and unwrapped.Skin.Adornee, (`bad skin config: "{unwrapped.Index.DebugLabel}"`))
		local unwrapped2 = ItemConfig.match(unwrapped.Skin.Adornee):unwrap()
		assert(unwrapped2.Moveset and unwrapped2.Moveset.Physical, (`bad base config: "{unwrapped2.Index.DebugLabel}"`))
		local unwrapped3 = ItemConfig.match(unwrapped2.Moveset.Physical):unwrap()
		local v3 = { "Trade", "Redeem", "Purchase" }
		table.insert(
			v2,
			templates5.Item.ownsPermanentFruit(
				unwrapped2.Index.StorageKey,
				v3,
				templates5.Item.hasFruitEquipped(unwrapped3.Index.StorageKey, v3)
			)
		)
		table.insert(simples, templates2.Simple.new(templates3.Item.fruitSkin(item)))
	end

	return templates.Simple.new(p, simples, v2, templates4.Simple.newRobuxItem(p, p2, false), {}, clone)
end

local FRUIT = {}

for _, v2 in ItemConfig.Query.select({
	Index = {
		IdType = "Skin"
	},
	Skin = {
		Type = "Fruit",
		Physical = {
			Operation = "EQ",
			Value = nil
		}
	},
	Economy = {
		PurchaseWith = {
			Operation = "NEQ",
			Value = nil
		}
	}
}) do
	local purchaseWith = v2.Economy and v2.Economy.PurchaseWith
	assert(purchaseWith, (`bad purchaseWith for "{v2.Index.DebugLabel}"`))

	if #ItemConfig.Query.select({
		Index = {
			IdType = "Skin"
		},
		Skin = {
			Type = "Fruit"
		},
		Economy = {
			PurchaseWith = purchaseWith
		}
	}) ~= 1 then
		continue
	end

	local unwrapped = ItemConfig.match(purchaseWith):unwrap()
	local tradeReducer = unwrapped.Economy and unwrapped.Economy.TradeReducer
	table.insert(FRUIT, newEconomyItem(unwrapped.Index.ItemId, "FruitSkin", { v2.Index.ItemId }, tradeReducer))
end

table.freeze(FRUIT)
return FRUIT