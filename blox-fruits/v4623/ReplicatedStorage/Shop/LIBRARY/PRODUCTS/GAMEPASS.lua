require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local IdMap = require(game.ReplicatedStorage.IdMap)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates

function newEconomyItem(p: string, p2, p3)
	local unwrapped = ItemId.getId(p, "Redeemable"):unwrap()
	return templates.Simple.new(
		unwrapped,
		{ templates2.Simple.new(p2) },
		{ p3 },
		templates4.Simple.newRobuxItem(unwrapped, "Gamepass")
	)
end

local GAMEPASS = {}

for k, v in pairs({
	["2x Money"] = {
		settlement = templates3.Special.moneyBoost(),
		qualification = templates5.Special.no2xMoney("Recipient", { "Redeem", "Purchase", "Trade" })
	},
	["2x Mastery"] = {
		settlement = templates3.Special.masteryBoost(),
		qualification = templates5.Special.no2xMastery("Recipient", { "Redeem", "Purchase", "Trade" })
	},
	["2x Boss Drops"] = {
		settlement = templates3.Special.bossBoost(),
		qualification = templates5.Special.no2xBossDrops("Recipient", { "Redeem", "Purchase", "Trade" })
	},
	["Dark Blade"] = {
		settlement = templates3.Special.permanentDarkBlade(),
		qualification = templates5.Item.notAlreadyRedeemed(
			IdMap.Redeemable["Dark Blade"],
			{ "Redeem", "Purchase", "Trade" }
		)
	},
	["Fast Boats"] = {
		settlement = templates3.Special.fastBoats(),
		qualification = templates5.Special.noFastBoats("Recipient", { "Redeem", "Purchase", "Trade" })
	},
	["Fruit Notifier"] = {
		settlement = templates3.Special.fruitNotifier(),
		qualification = templates5.Special.noFruitNotifier("Recipient", { "Redeem", "Purchase", "Trade" })
	}
}) do
	table.insert(GAMEPASS, newEconomyItem(k, v.settlement, v.qualification))
end

table.freeze(GAMEPASS)
return GAMEPASS