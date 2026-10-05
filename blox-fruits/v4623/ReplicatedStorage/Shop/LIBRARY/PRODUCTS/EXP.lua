require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local _ = Economy.Modules.Qualification.Templates

function newEconomyItem(p: string, p2: number)
	local unwrapped = ItemId.getId(p, "Redeemable"):unwrap()
	return templates.Simple.new(
		unwrapped,
		{ templates2.Simple.new(templates3.expBoost(p2)) },
		{},
		templates4.Simple.newRobuxItem(unwrapped, "ExpProduct", false),
		{ "StoreOnGiftClaim", "CanTradeDuplicates" }
	)
end

local EXP = {}

for k, v in pairs({
	["2x EXP (15 mins.)"] = {
		duration = 900
	},
	["2x EXP (1 hour)"] = {
		duration = 3600
	},
	["2x EXP (6 hours)"] = {
		duration = 21600
	},
	["2x EXP (12 hours)"] = {
		duration = 43200
	},
	["2x EXP (24 hours)"] = {
		duration = 86400
	}
}) do
	table.insert(EXP, newEconomyItem(k, v.duration))
end

table.freeze(EXP)
return EXP