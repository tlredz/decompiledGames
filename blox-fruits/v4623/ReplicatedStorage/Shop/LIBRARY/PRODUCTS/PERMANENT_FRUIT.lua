require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates

function newEconomyItem(p: string)
	local unwrapped = ItemId.getId("Permanent " .. p, "Redeemable"):unwrap()
	local unwrapped2 = ItemId.getId(p, "Moveset"):unwrap()
	return templates.Simple.new(
		unwrapped,
		{ templates2.Simple.new(templates3.Item.permanentFruit(p)) },
		{ templates5.Item.notAlreadyRedeemed(unwrapped2, { "Redeem", "Purchase", "Trade" }) },
		templates4.Simple.newRobuxItem(unwrapped2, "Fruit"),
		{ "BadPurchasesAreStored" }
	)
end

local PERMANENTFRUIT = {}

for _, v in pairs({
	"Bomb-Bomb",
	"Spike-Spike",
	"Blade-Blade",
	"Smoke-Smoke",
	"Spring-Spring",
	"Rocket-Rocket",
	"Spin-Spin",
	"Flame-Flame",
	"Ice-Ice",
	"Sand-Sand",
	"Dark-Dark",
	"Diamond-Diamond",
	"Light-Light",
	"Rubber-Rubber",
	"Ghost-Ghost",
	"Magma-Magma",
	"Portal-Portal",
	"Blizzard-Blizzard",
	"Quake-Quake",
	"Buddha-Buddha",
	"Love-Love",
	"Spider-Spider",
	"Sound-Sound",
	"Phoenix-Phoenix",
	"Pain-Pain",
	"Gravity-Gravity",
	"T-Rex-T-Rex",
	"Mammoth-Mammoth",
	"Dough-Dough",
	"Shadow-Shadow",
	"Venom-Venom",
	"Control-Control",
	"Gas-Gas",
	"Spirit-Spirit",
	"Dragon-Dragon",
	"Yeti-Yeti",
	"Tiger-Tiger",
	"Kitsune-Kitsune",
	"Eagle-Eagle",
	"Creation-Creation",
	"Lightning-Lightning",
	"Magnet-Magnet"
}) do
	table.insert(PERMANENTFRUIT, newEconomyItem(v))
end

table.freeze(PERMANENTFRUIT)
return PERMANENTFRUIT