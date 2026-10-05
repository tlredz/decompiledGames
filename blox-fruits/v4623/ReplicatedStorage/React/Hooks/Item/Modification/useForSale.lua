local React = require(game.ReplicatedStorage.Packages.React)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local PriceService = require(game.ReplicatedStorage.PriceService)

function getForSale()
	local itemIds = {}

	for _, v in ItemConfig.map(Modification.getAllModifications()) do
		if not (v.Economy and v.Economy.PurchaseWith and PriceService.getPrice(v.Economy.PurchaseWith)) then
			continue
		end

		table.insert(itemIds, v.Index.ItemId)
	end

	table.freeze(itemIds)
	return itemIds
end

return function()
	local state, setState = React.useState(getForSale())
	React.useEffect(function()
		if PriceService:GetIfInitialized() then
			return PriceService:ScheduleCallback(function()
				setState(getForSale())
			end)
		end

		return function() end
	end, { PriceService:GetIfInitialized() })
	return state
end