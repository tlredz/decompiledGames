local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.PseudoEnum)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local useCurrentBracket = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentBracket)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
return function(items)
	local v, _ = useCurrentBracket()
	return React.useMemo(function()
		if v == nil then
			return items
		end

		local result = {}

		for _, item in items do
			for _, bracket in ItemConfig.match(item.ItemId):unwrap().Inventory.Brackets do
				if bracket ~= v then
					continue
				end

				table.insert(result, item)
				break
			end
		end

		return result
	end, { items, v })
end