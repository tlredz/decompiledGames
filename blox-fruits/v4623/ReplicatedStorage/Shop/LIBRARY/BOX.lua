require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local _ = Economy.Modules.Qualification.Templates

function newEconomyItem(p: string)
	local unwrapped = ItemId.getId(p, "Redeemable"):unwrap()
	return templates.Simple.new(
		unwrapped,
		{ templates2.Simple.new(templates3.Item.box(unwrapped)) },
		{},
		templates4.Simple.newRobuxItem(unwrapped, "FruitBox"),
		{}
	)
end

local BOX = {}

for _, v in pairs({
	"MysteryBoxS2",
	"UncommonBoxS2",
	"RareBoxS2",
	"LegendaryBoxS2",
	"MythicalBoxS2",
	"PremiumBoxS2",
	"Fruit Box",
	"Super Fruit Box",
	"GachaData",
	"SummerWeek2Gacha",
	"SummerWeek3Gacha",
	"SummerWeek4Gacha",
	"SummerWeek5Gacha",
	"MysteryBoxS3",
	"UncommonBoxS3",
	"RareBoxS3",
	"LegendaryBoxS3",
	"MythicalBoxS3",
	"PremiumBoxS3",
	"LegendaryEasterGift26",
	"RareEasterGift26",
	"DogHouseGacha26",
	"MysteryBoxS4",
	"UncommonBoxS4",
	"RareBoxS4",
	"LegendaryBoxS4",
	"MythicalBoxS4",
	"PremiumBoxS4"
}) do
	table.insert(BOX, newEconomyItem(v))
end

table.freeze(BOX)
return BOX