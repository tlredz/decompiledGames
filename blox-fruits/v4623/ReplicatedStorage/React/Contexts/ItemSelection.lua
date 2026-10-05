local React = require(game.ReplicatedStorage.Packages.React)
return React.createContext({
	Selection = nil,
	SetSelection = function(_: number?, _: string?)
		print("Warning: No TileSelection Context Provider found!")
	end
})