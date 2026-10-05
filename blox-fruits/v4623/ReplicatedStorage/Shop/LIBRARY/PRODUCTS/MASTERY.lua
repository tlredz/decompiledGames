require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates

function newEconomyItem(p: string, p2: string, p3: number)
	local unwrapped = ItemId.getId(p, "Redeemable"):unwrap()
	return templates.Simple.new(
		unwrapped,
		{ templates2.Simple.new(templates3.masteryBoost(p2, p3)) },
		{ templates5.canBoostMastery(p2) },
		templates4.Simple.newRobuxItem(unwrapped, "MasteryProduct", false),
		{ "NoTrade", "NoStore" }
	)
end

local MASTERY = {}

for _, v in {
	"Sword",
	"Gun",
	"Fruit",
	"FightingStyle"
} do
	for _, v2 in {
		50,
		100,
		150,
		200,
		250,
		300,
		350,
		400
	} do
		table.insert(MASTERY, newEconomyItem(`+{v2} {v} Mastery`, v, v2))
	end
end

table.freeze(MASTERY)
return MASTERY