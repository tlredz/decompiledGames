local React = require(game.ReplicatedStorage.Packages.React)
local ItemSelection = require(game.ReplicatedStorage.React.Contexts.ItemSelection)
return function()
	local v = React.useContext(ItemSelection)

	if v.Selection then
		return v.Selection.ItemId, v.Selection.NetworkedUID, v.SetSelection
	end

	return nil, nil, v.SetSelection
end