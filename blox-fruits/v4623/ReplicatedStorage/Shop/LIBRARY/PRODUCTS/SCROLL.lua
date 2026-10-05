require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates

function newEconomyItem(p: string, p2: number, p3: number, flag: boolean?)
	local unwrapped = ItemId.getId(p, "Redeemable"):unwrap()
	local unwrapped2 = ItemConfig.match(p2):unwrap()
	local maxStack = unwrapped2.Inventory.MaxStack
	assert(maxStack, (`bad maxStack for material "{unwrapped2.Index.DebugLabel}"`))
	maxStack -= p3
	local v = {}

	if flag then
		table.insert(v, templates5.hasReachedSea("Sea3", { "Purchase" }))
	end

	return templates.Simple.new(
		unwrapped,
		{ templates2.Simple.new(templates3.Item.scroll(p2, p3)) },
		v,
		templates4.Simple.newRobuxItem(unwrapped, "StoredProduct", false),
		{ "CanTradeDuplicates" }
	)
end

local SCROLL = {}

for k, v in pairs({
	["Mythical Scroll"] = {
		amount = 1,
		item = IdMap.Scroll["Mythical Scroll"]
	},
	["3x Mythical Scrolls"] = {
		amount = 3,
		item = IdMap.Scroll["Mythical Scroll"],
		sea3 = true
	},
	["Legendary Scroll"] = {
		amount = 1,
		item = IdMap.Scroll["Legendary Scroll"]
	},
	["5x Legendary Scrolls"] = {
		amount = 5,
		item = IdMap.Scroll["Legendary Scroll"],
		sea3 = true
	}
}) do
	table.insert(SCROLL, newEconomyItem(k, v.item, v.amount, v.sea3))
end

table.freeze(SCROLL)
return SCROLL