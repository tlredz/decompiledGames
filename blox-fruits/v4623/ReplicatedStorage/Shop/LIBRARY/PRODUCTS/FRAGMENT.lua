require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates

function newEconomyItem(p: string, p2: number)
	local unwrapped = ItemId.getId(p, "Redeemable"):unwrap()
	return templates.Simple.new(
		unwrapped,
		{ templates2.Simple.new(templates3.Currency.fragments(p2)) },
		{ templates5.hasLessFragmentsThan(1000000000 - p2, { "Redeem", "Trade" }), templates5.hasReachedSea("Sea2") },
		templates4.Simple.newRobuxItem(unwrapped, "Currency", false),
		{ "CanTradeDuplicates" }
	)
end

local FRAGMENT = {}

for k, v in pairs({
	["500 Fragments"] = {
		amount = 500
	},
	["2.1K Fragments"] = {
		amount = 2100
	},
	["4.5K Fragments"] = {
		amount = 4500
	},
	["10K Fragments"] = {
		amount = 10000
	},
	["16K Fragments"] = {
		amount = 16000
	}
}) do
	table.insert(FRAGMENT, newEconomyItem(k, v.amount))
end

table.freeze(FRAGMENT)
return FRAGMENT