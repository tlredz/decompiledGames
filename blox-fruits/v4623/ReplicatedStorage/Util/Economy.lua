local EconomyItem = require(game.ReplicatedStorage.Economy.EconomyItem)
local Product = require(game.ReplicatedStorage.Util.Economy.Product)
local Qualification = require(game.ReplicatedStorage.Util.Economy.Qualification)
local LegacyInfo = require(game.ReplicatedStorage.Util.Economy.LegacyInfo)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Economy = {
	Modules = {
		LegacyInfo = LegacyInfo,
		Qualification = Qualification,
		Product = Product
	},
	excludeFilters = function(list)
		local v = {}

		if not table.find(list, "Redeem") then
			table.insert(v, "Redeem")
		end

		if not table.find(list, "Purchase") then
			table.insert(v, "Purchase")
		end

		if not table.find(list, "Gift") then
			table.insert(v, "Gift")
		end

		if not table.find(list, "Store") then
			table.insert(v, "Store")
		end

		if not table.find(list, "Trade") then
			table.insert(v, "Trade")
		end

		return v
	end,
	Templates = {}
}
Economy.Templates.Simple = {}

function Economy.Templates.Simple.new(p: number, items, items2, p2, options, p3)
	local v = {}

	for _, item in items do
		table.insert(v, item)
	end

	local v2 = {}

	for _, item in items2 do
		table.insert(v2, item)
	end

	local unwrapped = ItemConfig.match(p):unwrap()
	local class = EconomyItem.Class.new(v, v2, p2, p, options or {}, p3)
	local v3, v4 = EconomyItem.Type.check(class)

	if not v3 then
		error((`EconomyItem check failed for "{unwrapped.Index.DebugLabel}" with error: {v4}`))
	end

	return class
end

return Economy