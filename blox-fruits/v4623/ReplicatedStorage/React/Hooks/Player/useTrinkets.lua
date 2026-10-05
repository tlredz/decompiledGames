local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local AccessoriesShared = require(game.ReplicatedStorage.AccessoriesShared)
local useDynamicAccessories = require(game.ReplicatedStorage.React.Hooks.Player.useDynamicAccessories)
return function()
	local v = useDynamicAccessories()
	return (React.useMemo(function()
		if not v then
			return nil
		end

		local itemIds = {}

		for k, v2 in v do
			if not (v2.Type == "Trinket" and v2.Equipped) then
				continue
			end

			local itemId = AccessoriesShared.getItemId(v2.Name, v2.Grade)

			if itemId then
				itemIds[k] = ItemConfig.match(itemId):unwrap().Index.ItemId
			end
		end

		table.freeze(itemIds)
		return itemIds
	end, { v }))
end