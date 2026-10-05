require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local Economy = require(game.ReplicatedStorage.Util.Economy)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local templates = Economy.Templates
local templates2 = Economy.Modules.Product.Templates
local templates3 = Economy.Modules.Product.Modules.Settlement.Templates
local templates4 = Economy.Modules.LegacyInfo.Templates
local templates5 = Economy.Modules.Qualification.Templates

function newEconomyItem(p: string, _: number?)
	local unwrapped = ItemConfig.match(p, "Skin"):unwrap()
	local unwrapped2 = ItemConfig.match(p, "Redeemable"):unwrap()
	local v = { templates2.Simple.new(templates3.Item.auraSkin(unwrapped.Index.ItemId)) }
	return templates.Simple.new(
		unwrapped2.Index.ItemId,
		v,
		{
			templates5.Item.doesNotOwnAuraSkin(unwrapped.Index.ItemId, { "Redeem", "Trade" }),
			templates5.Item.hasNotLearnedAuraSkill(Economy.excludeFilters({ "Store" }))
		},
		templates4.Simple.newRobuxItem(unwrapped2.Index.ItemId, "AuraSkin", false)
	)
end

local AURA = {}

for _, v in ItemConfig.Query.select({
	Skin = {
		Type = "Aura"
	}
}) do
	local nullable = ItemConfig.match(v.Index.StorageKey, "Redeemable"):asNullable()

	if nullable then
		table.insert(AURA, newEconomyItem(v.Index.StorageKey, nullable.Economy and nullable.Economy.TradeReducer))
	end
end

table.freeze(AURA)
return AURA