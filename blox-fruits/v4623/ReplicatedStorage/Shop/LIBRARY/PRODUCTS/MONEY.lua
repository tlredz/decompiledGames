require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates

function newEconomyItem(p: string, p2: number, p3: string?)
	local unwrapped = ItemId.getId(p, "Redeemable"):unwrap()
	local new = templates.Simple.new
	local v = { templates2.Simple.new(templates3.Currency.money(p2)) }
	local lessMoneyThan = templates5.hasLessMoneyThan(1000000000 - p2, { "Redeem", "Trade" })
	local v3

	if p3 then
		v3 = templates5.hasReachedSea(p3, { "Gift", "Purchase" })
	end

	return new(
		unwrapped,
		v,
		{ lessMoneyThan, v3 },
		templates4.Simple.newRobuxItem(unwrapped, "Currency", false),
		{ "CanTradeDuplicates" }
	)
end

local MONEY = {}

for k, v in pairs({
	["10K Money"] = {
		amount = 10000
	},
	["20K Money"] = {
		amount = 20000
	},
	["50K Money"] = {
		amount = 50000
	},
	["135K Money"] = {
		amount = 135000
	},
	["300K Money"] = {
		amount = 300000
	},
	["500K Money"] = {
		amount = 500000
	},
	["30K Money"] = {
		amount = 30000,
		sea = "Sea2"
	},
	["150K Money"] = {
		amount = 150000,
		sea = "Sea2"
	},
	["405K Money"] = {
		amount = 405000,
		sea = "Sea2"
	},
	["900K Money"] = {
		amount = 900000,
		sea = "Sea2"
	},
	["1.5M Money"] = {
		amount = 1500000,
		sea = "Sea2"
	},
	["60K Money"] = {
		amount = 60000,
		sea = "Sea3"
	},
	["305K Money"] = {
		amount = 305000,
		sea = "Sea3"
	},
	["810K Money"] = {
		amount = 810000,
		sea = "Sea3"
	},
	["1.8M Money"] = {
		amount = 1800000,
		sea = "Sea3"
	},
	["3M Money"] = {
		amount = 3000000,
		sea = "Sea3"
	},
	["600K Money"] = {
		amount = 600000
	}
}) do
	table.insert(MONEY, newEconomyItem(k, v.amount, v.sea))
end

table.freeze(MONEY)
return MONEY