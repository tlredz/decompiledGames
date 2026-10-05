require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.SaleService)
local IdMap = require(game.ReplicatedStorage.IdMap)
local v = {
	[IdMap.Redeemable.EmberChromaticDragon] = { "HolidayChromatics2024" },
	[IdMap.Redeemable.EclipseChromaticDragon] = { "HolidayChromatics2024" },
	[IdMap.Redeemable.BloodmoonChromaticDragon] = { "HolidayChromatics2024" },
	[IdMap.Redeemable.PhoenixSkyChromaticDragon] = { "HolidayChromatics2024" },
	[IdMap.Redeemable.VioletNightChromaticDragon] = { "HolidayChromatics2024" }
}
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates

function newEconomyItem(p: number, items, _: number?)
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
		table.insert(
			v2,
			templates5.Item.ownsPermanentFruit(unwrapped2.Index.StorageKey, { "Trade", "Redeem", "Purchase" })
		)
		table.insert(simples, templates2.Simple.new(templates3.Item.fruitSkin(item)))
	end

	return templates.Simple.new(p, simples, v2, templates4.Simple.newRobuxItem(p, "SkinBundle", false), {}, clone)
end

local DRAGONSKIN = {}

for k, v3 in {
	[IdMap.Redeemable.EmberChromaticDragon] = { IdMap.Skin.ESTDSKINember, IdMap.Skin.WSTDSKINember },
	[IdMap.Redeemable.EclipseChromaticDragon] = { IdMap.Skin.ESTDSKINeclipse, IdMap.Skin.WSTDSKINeclipse },
	[IdMap.Redeemable.BloodmoonChromaticDragon] = { IdMap.Skin.ESTDSKINbloodmoon, IdMap.Skin.WSTDSKINbloodmoon },
	[IdMap.Redeemable.PhoenixSkyChromaticDragon] = { IdMap.Skin.ESTDSKINphoenixsky, IdMap.Skin.WSTDSKINphoenixsky },
	[IdMap.Redeemable.VioletNightChromaticDragon] = { IdMap.Skin.ESTDSKINvioletnight, IdMap.Skin.WSTDSKINvioletnight }
} do
	local unwrapped = ItemConfig.match(k):unwrap()
	table.insert(DRAGONSKIN, newEconomyItem(k, v3, unwrapped.Economy and unwrapped.Economy.TradeReducer))
end

table.freeze(DRAGONSKIN)
return DRAGONSKIN