local React = require(game.ReplicatedStorage.Packages.React)
local MultiItemSelection = require(game.ReplicatedStorage.React.Contexts.MultiItemSelection)
return function()
	local v = React.useContext(MultiItemSelection)
	return v.SelectedItems, v.SetItemSelected, v.Clear
end