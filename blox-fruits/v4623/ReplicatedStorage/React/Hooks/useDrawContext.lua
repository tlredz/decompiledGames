local React = require(game.ReplicatedStorage.Packages.React)
local DrawContext = require(game.ReplicatedStorage.React.Contexts.DrawContext)
return function()
	return (React.useContext(DrawContext))
end