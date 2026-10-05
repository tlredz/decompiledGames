local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.PseudoEnum)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local useCurrentGroup = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentGroup)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
return function(items)
	local v, _ = useCurrentGroup()
	return React.useMemo(function()
		local result = {}

		for _, item in items do
			for _, group in ItemConfig.match(item.ItemId):unwrap().Inventory.Groups do
				if group ~= v then
					continue
				end

				table.insert(result, item)
				break
			end
		end

		return result
	end, { items, v })
end