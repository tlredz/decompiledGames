require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates

function newEconomyItem(p: number)
	local formatted = `{p} Simulation Data`
	local unwrapped = ItemId.getId(formatted, "Redeemable"):unwrap()
	local simulationData = IdMap.Material["Simulation Data"]
	local unwrapped2 = ItemConfig.match(simulationData):unwrap()
	local maxStack = unwrapped2.Inventory.MaxStack
	assert(maxStack, (`bad maxStack for material "{unwrapped2.Index.DebugLabel}"`))
	local v = maxStack - p
	return templates.Simple.new(
		unwrapped,
		{ templates2.Simple.new(templates3.Currency.simulationData(p)) },
		{
			templates5.Item.new(simulationData, "StorageLimit", "Recipient", nil, v, { "Redeem" }, nil),
			templates5.hasReachedSea("Sea2", { "Purchase" })
		},
		templates4.Simple.newRobuxItem(unwrapped, "DungeonProduct", false),
		{}
	)
end

local DUNGEON = {}

for _, v in {
	200,
	1000,
	2700,
	6000,
	10000
} do
	table.insert(DUNGEON, newEconomyItem(v))
end

table.freeze(DUNGEON)
return DUNGEON