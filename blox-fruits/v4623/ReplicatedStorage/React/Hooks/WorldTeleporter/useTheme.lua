local React = require(game.ReplicatedStorage.Packages.React)
local Theme = require(game.ReplicatedStorage.React.Contexts.WorldTeleporter.Theme)
return function()
	return (React.useContext(Theme))
end