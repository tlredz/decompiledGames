local React = require(game.ReplicatedStorage.Packages.React)
return React.createContext({
	SelectedItems = {},
	SetItemSelected = function(_: string, _: boolean)
		print("WARNING: no context provider for MultiItemSelection")
	end,
	Clear = function()
		print("WARNING: no context provider for MultiItemSelection")
	end
})