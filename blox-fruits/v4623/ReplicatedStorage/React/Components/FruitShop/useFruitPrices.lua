local React = require(game.ReplicatedStorage.Packages.React)
local PriceService = require(game.ReplicatedStorage.PriceService)
require(script.Parent.Types)
return function(items)
	local state, setState = React.useState((table.freeze({})))
	local ifInitialized = PriceService:GetIfInitialized()
	React.useEffect(function()
		if not ifInitialized then
			return
		end

		local v = {}
		local pricesByName = {}

		for _, item in items do
			local name = item.Name
			local itemId = item.Item.ItemId
			table.insert(v, PriceService:ScheduleCallback(itemId, function(p: number?)
				setState(function(p2)
					if p2[name] == p then
						return p2
					end

					local clone = table.clone(p2)
					rawset(clone, name, p)
					return table.freeze(clone)
				end)
			end))
			local price = PriceService.getPrice(itemId)

			if price ~= nil then
				pricesByName[name] = price
			end
		end

		setState(table.freeze(pricesByName))
		return function()
			for _, v2 in v do
				v2()
			end
		end
	end, { items, ifInitialized })
	return state
end