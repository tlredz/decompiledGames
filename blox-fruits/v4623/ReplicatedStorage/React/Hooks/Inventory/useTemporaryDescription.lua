local React = require(game.ReplicatedStorage.Packages.React)
local TemporaryDescription = require(game.ReplicatedStorage.React.Contexts.Inventory.TemporaryDescription)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
return function()
	local v, v2, _ = useSelection()
	local v3 = React.useContext(TemporaryDescription)
	local description = v3.Description

	if description and description.ItemId == v and description.NetworkedUID == v2 then
		return description.Message, v3.SetDescription
	end

	return nil, v3.SetDescription
end