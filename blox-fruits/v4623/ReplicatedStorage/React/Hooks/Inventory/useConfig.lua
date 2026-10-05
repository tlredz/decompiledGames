local React = require(game.ReplicatedStorage.Packages.React)
local Config = require(game.ReplicatedStorage.React.Contexts.Inventory.Config)
return function()
	return React.useContext(Config)
end