local React = require(game.ReplicatedStorage.Packages.React)
local Navigation = require(game.ReplicatedStorage.React.Contexts.Inventory.Navigation)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.PseudoEnum)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
return function()
	local v = useConfig()
	local v2 = React.useContext(Navigation)
	local initialSelection = v2.InitialSelection
	local itemId, networkedUID

	if initialSelection ~= nil then
		itemId = initialSelection.ItemId
		networkedUID = initialSelection.NetworkedUID
	end

	return itemId, networkedUID, function(itemId2: number?, networkedUID2: string?)
		if not itemId2 then
			v2.SetNavigation(v2.Group, v2.Bracket, v2.SortType, nil)
			return
		end

		local unwrapped = ItemConfig.match(itemId2):unwrap()

		for _, group in unwrapped.Inventory.Groups do
			local v3 = v.Layout[group]

			if not v3 then
				continue
			end

			for _, bracket in unwrapped.Inventory.Brackets do
				if not table.find(v3.Brackets, bracket) then
					continue
				end

				local v4 = {
					ItemId = itemId2,
					NetworkedUID = networkedUID2
				}
				table.freeze(v4)
				v2.SetNavigation(group, bracket, v2.SortType, v4)
				return
			end
		end

		warn((`Could not find valid group/bracket for itemId {itemId2}/{networkedUID2}`))
	end
end